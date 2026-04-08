import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:parafare_application/map/view.dart';
import 'package:parafare_application/mvp/ctrl.dart';

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

  LatLng? _origin;
  LatLng? _destination;
  bool _pickOriginNext = true;
  bool _showDebugSnap = false;
  FarePreview? _preview;

  @override
  void dispose() {
    _originLabel.dispose();
    _destinationLabel.dispose();
    super.dispose();
  }

  Future<void> _useCurrentGpsAsOrigin() async {
    try {
      final pos = await ref.read(mvpControllerProvider.notifier).getCurrentPosition();
      setState(() {
        _origin = LatLng(pos.latitude, pos.longitude);
        _pickOriginNext = false;
        if (_originLabel.text.isEmpty) {
          _originLabel.text = 'Current GPS';
        }
      });
      _computePreview();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get GPS origin: $e')),
      );
    }
  }

  void _handleMapTap(LatLng location) {
    setState(() {
      if (_pickOriginNext) {
        _origin = location;
        _pickOriginNext = false;
      } else {
        _destination = location;
      }
    });
    _computePreview();
  }

  void _computePreview() {
    if (_origin == null || _destination == null) {
      return;
    }

    final p = ref.read(mvpControllerProvider.notifier).calculatePreview(
          originLat: _origin!.latitude,
          originLng: _origin!.longitude,
          destinationLat: _destination!.latitude,
          destinationLng: _destination!.longitude,
        );

    setState(() => _preview = p);
  }

  Future<void> _assignRide() async {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select both origin and destination on map.')),
      );
      return;
    }

    await ref.read(mvpControllerProvider.notifier).assignRideToSlot(
          slotIndex: widget.slotIndex,
          originLabel: _originLabel.text.trim().isEmpty ? 'Origin' : _originLabel.text.trim(),
          destinationLabel: _destinationLabel.text.trim().isEmpty ? 'Destination' : _destinationLabel.text.trim(),
          originLat: _origin!.latitude,
          originLng: _origin!.longitude,
          destinationLat: _destination!.latitude,
          destinationLng: _destination!.longitude,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Ride • Passenger ${widget.slotIndex}')),
      body: Column(
        children: [
          Expanded(
            child: MapView(
              showLiveLocation: true,
              onTap: _handleMapTap,
              routePoints: [
                if (_origin != null) _origin!,
                if (_destination != null) _destination!,
              ],
              extraMarkers: [
                if (_origin != null)
                  Marker(
                    point: _origin!,
                    child: const Icon(Icons.trip_origin, color: Colors.green, size: 30),
                  ),
                if (_destination != null)
                  Marker(
                    point: _destination!,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 32),
                  ),
                if (_showDebugSnap && _preview != null)
                  Marker(
                    point: LatLng(_preview!.startSnapLat, _preview!.startSnapLng),
                    child: const Icon(Icons.circle, color: Colors.orange, size: 18),
                  ),
                if (_showDebugSnap && _preview != null)
                  Marker(
                    point: LatLng(_preview!.endSnapLat, _preview!.endSnapLng),
                    child: const Icon(Icons.circle, color: Colors.deepOrange, size: 18),
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
                Text(_pickOriginNext
                    ? 'Tap map to choose ORIGIN first.'
                    : 'Tap map to choose DESTINATION.'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _useCurrentGpsAsOrigin,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use Current GPS as Origin'),
                    ),
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _origin = null;
                        _destination = null;
                        _pickOriginNext = true;
                        _preview = null;
                      }),
                      child: const Text('Reset points'),
                    ),
                    FilledButton(
                      onPressed: _assignRide,
                      child: const Text('Assign to Slot'),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Debug snap overlay'),
                  value: _showDebugSnap,
                  onChanged: (v) => setState(() => _showDebugSnap = v),
                ),
                if (_preview != null) ...[
                  const SizedBox(height: 8),
                  Text('Estimated Distance: ${_preview!.distanceKm.toStringAsFixed(2)} km'),
                  Text('Graph Distance: ${_preview!.graphDistanceKm.toStringAsFixed(2)} km'),
                  Text('Snap Offsets: +${_preview!.startOffsetKm.toStringAsFixed(2)} +${_preview!.endOffsetKm.toStringAsFixed(2)} km'),
                  Text('Estimated Time: ${_preview!.estimatedMinutes} min'),
                  Text('Estimated Fare: PHP ${_preview!.suggestedFare.toStringAsFixed(0)}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
