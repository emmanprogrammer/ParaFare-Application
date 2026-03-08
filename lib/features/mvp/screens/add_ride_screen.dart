import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../map/map_view.dart';
import '../mvp_controller.dart';

class AddRideScreen extends ConsumerStatefulWidget {
  const AddRideScreen({
    super.key,
    required this.slotIndex,
  });

  final int slotIndex;

  @override
  ConsumerState<AddRideScreen> createState() => _AddRideScreenState();
}

class _AddRideScreenState extends ConsumerState<AddRideScreen> {
  final _originLabel = TextEditingController();
  final _destinationLabel = TextEditingController();
  final _originLat = TextEditingController();
  final _originLng = TextEditingController();
  final _destinationLat = TextEditingController();
  final _destinationLng = TextEditingController();

  FarePreview? preview;

  @override
  void dispose() {
    _originLabel.dispose();
    _destinationLabel.dispose();
    _originLat.dispose();
    _originLng.dispose();
    _destinationLat.dispose();
    _destinationLng.dispose();
    super.dispose();
  }

  Future<void> _useCurrentGpsAsOrigin() async {
    try {
      final pos = await ref.read(mvpControllerProvider.notifier).getCurrentPosition();
      _originLat.text = pos.latitude.toStringAsFixed(6);
      _originLng.text = pos.longitude.toStringAsFixed(6);
      if (_originLabel.text.isEmpty) {
        _originLabel.text = 'Current GPS';
      }
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get GPS origin: $e')),
      );
    }
  }

  void _computePreview() {
    final oLat = double.tryParse(_originLat.text);
    final oLng = double.tryParse(_originLng.text);
    final dLat = double.tryParse(_destinationLat.text);
    final dLng = double.tryParse(_destinationLng.text);

    if (oLat == null || oLng == null || dLat == null || dLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide valid origin/destination coordinates.')),
      );
      return;
    }

    final p = ref.read(mvpControllerProvider.notifier).calculatePreview(
          originLat: oLat,
          originLng: oLng,
          destinationLat: dLat,
          destinationLng: dLng,
        );

    setState(() => preview = p);
  }

  Future<void> _assignRide() async {
    final p = preview;
    if (p == null) {
      _computePreview();
      if (preview == null) return;
    }

    final oLat = double.parse(_originLat.text);
    final oLng = double.parse(_originLng.text);
    final dLat = double.parse(_destinationLat.text);
    final dLng = double.parse(_destinationLng.text);

    await ref.read(mvpControllerProvider.notifier).assignRideToSlot(
          slotIndex: widget.slotIndex,
          originLabel: _originLabel.text.trim().isEmpty ? 'Origin' : _originLabel.text.trim(),
          destinationLabel: _destinationLabel.text.trim().isEmpty ? 'Destination' : _destinationLabel.text.trim(),
          originLat: oLat,
          originLng: oLng,
          destinationLat: dLat,
          destinationLng: dLng,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final oLat = double.tryParse(_originLat.text);
    final oLng = double.tryParse(_originLng.text);
    final dLat = double.tryParse(_destinationLat.text);
    final dLng = double.tryParse(_destinationLng.text);

    return Scaffold(
      appBar: AppBar(title: Text('Add Ride • Passenger ${widget.slotIndex}')),
      body: Column(
        children: [
          Expanded(
            child: MapView(
              showLiveLocation: true,
              routePoints: [
                if (oLat != null && oLng != null) LatLng(oLat, oLng),
                if (dLat != null && dLng != null) LatLng(dLat, dLng),
              ],
              extraMarkers: [
                if (oLat != null && oLng != null)
                  Marker(
                    point: LatLng(oLat, oLng),
                    child: const Icon(Icons.trip_origin, color: Colors.green, size: 30),
                  ),
                if (dLat != null && dLng != null)
                  Marker(
                    point: LatLng(dLat, dLng),
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 32),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                TextField(controller: _originLabel, decoration: const InputDecoration(labelText: 'Origin label')),
                TextField(controller: _destinationLabel, decoration: const InputDecoration(labelText: 'Destination label')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _originLat, decoration: const InputDecoration(labelText: 'Origin Lat'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _originLng, decoration: const InputDecoration(labelText: 'Origin Lng'))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _destinationLat, decoration: const InputDecoration(labelText: 'Dest Lat'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _destinationLng, decoration: const InputDecoration(labelText: 'Dest Lng'))),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _useCurrentGpsAsOrigin,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use Current GPS as Origin'),
                    ),
                    FilledButton(
                      onPressed: _computePreview,
                      child: const Text('Preview Route/Fare'),
                    ),
                    FilledButton(
                      onPressed: _assignRide,
                      child: const Text('Assign to Slot'),
                    ),
                  ],
                ),
                if (preview != null) ...[
                  const SizedBox(height: 8),
                  Text('Estimated Distance: ${preview!.distanceKm.toStringAsFixed(2)} km'),
                  Text('Estimated Time: ${preview!.estimatedMinutes} min'),
                  Text('Estimated Fare: PHP ${preview!.suggestedFare.toStringAsFixed(0)}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
