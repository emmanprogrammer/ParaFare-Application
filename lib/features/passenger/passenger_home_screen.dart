import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../map/map_view.dart';
import '../mvp/mvp_controller.dart';

class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen> {
  LatLng? _origin;
  LatLng? _destination;
  bool _pickOrigin = true;
  bool _debugOverlay = false;
  FarePreview? _preview;

  void _onMapTap(LatLng point) {
    setState(() {
      if (_pickOrigin) {
        _origin = point;
        _pickOrigin = false;
      } else {
        _destination = point;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Price Check')),
      body: Column(
        children: [
          Expanded(
            child: MapView(
              onTap: _onMapTap,
              showLiveLocation: true,
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
                if (_debugOverlay && _preview != null)
                  Marker(
                    point: LatLng(_preview!.startSnapLat, _preview!.startSnapLng),
                    child: const Icon(Icons.circle, color: Colors.orange, size: 16),
                  ),
                if (_debugOverlay && _preview != null)
                  Marker(
                    point: LatLng(_preview!.endSnapLat, _preview!.endSnapLng),
                    child: const Icon(Icons.circle, color: Colors.deepOrange, size: 16),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_pickOrigin ? 'Tap map to select origin.' : 'Tap map to select destination.'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _origin = null;
                        _destination = null;
                        _pickOrigin = true;
                        _preview = null;
                      }),
                      child: const Text('Reset'),
                    ),
                    OutlinedButton(
                      onPressed: () => setState(() => _pickOrigin = !_pickOrigin),
                      child: Text(_pickOrigin ? 'Switch to Destination' : 'Switch to Origin'),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Debug snap overlay'),
                  value: _debugOverlay,
                  onChanged: (value) => setState(() => _debugOverlay = value),
                ),
                if (_preview != null) ...[
                  Text('Estimated distance: ${_preview!.distanceKm.toStringAsFixed(2)} km'),
                  Text('Estimated time: ${_preview!.estimatedMinutes} min'),
                  Text('Estimated fare: PHP ${_preview!.suggestedFare.toStringAsFixed(0)}'),
                  Text('Route core: ${_preview!.graphDistanceKm.toStringAsFixed(2)} km'),
                  Text(
                    'Snap offsets: ${_preview!.startOffsetKm.toStringAsFixed(2)} + ${_preview!.endOffsetKm.toStringAsFixed(2)} km',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
