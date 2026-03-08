import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:parafare_application/features/map/map_view.dart';
import 'package:parafare_application/features/dispatch/live_trip_controller.dart';

class LiveTripScreen extends ConsumerWidget {
  const LiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveTripControllerProvider);
    final controller = ref.read(liveTripControllerProvider.notifier);

    final start = state.startPosition;
    final end = state.endPosition;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Trip Mode (GPS)')),
      body: Column(
        children: [
          Expanded(
            child: MapView(
              showLiveLocation: true,
              routePoints: [
                if (start != null) LatLng(start.latitude, start.longitude),
                if (end != null) LatLng(end.latitude, end.longitude),
              ],
              extraMarkers: [
                if (start != null)
                  Marker(
                    point: LatLng(start.latitude, start.longitude),
                    child: const Icon(Icons.play_arrow, color: Colors.green, size: 30),
                  ),
                if (end != null)
                  Marker(
                    point: LatLng(end.latitude, end.longitude),
                    child: const Icon(Icons.flag, color: Colors.red, size: 30),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.errorMessage != null)
                  Text(
                    state.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                Text('Graph nodes loaded: ${state.graph?.nodes.length ?? 0}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: state.isLoading ? null : controller.captureTripStart,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Capture Start GPS'),
                    ),
                    ElevatedButton.icon(
                      onPressed: state.isLoading ? null : controller.captureTripEndAndCompute,
                      icon: const Icon(Icons.flag),
                      label: const Text('Capture End + Compute'),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isLoading ? null : controller.completeTrip,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Completed Trip'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: state.discountApplied,
                  onChanged: controller.setDiscountApplied,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Apply 20% discount'),
                ),
                Row(
                  children: [
                    const Text('Manual Adjustment (PHP)'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: state.manualAdjustment,
                        min: -20,
                        max: 20,
                        divisions: 40,
                        label: state.manualAdjustment.toStringAsFixed(0),
                        onChanged: controller.setManualAdjustment,
                      ),
                    ),
                    Text(state.manualAdjustment.toStringAsFixed(0)),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.startSnap != null)
                  Text('Start snapped node: ${state.startSnap!.node.id}'),
                if (state.endSnap != null)
                  Text('End snapped node: ${state.endSnap!.node.id}'),
                if (state.fareBreakdown != null) ...[
                  Text('Distance: ${state.fareBreakdown!.distanceKm.toStringAsFixed(2)} km'),
                  Text('Base Fare: PHP ${state.fareBreakdown!.baseFare.toStringAsFixed(0)}'),
                  Text('Discount: PHP ${state.fareBreakdown!.discountAmount.toStringAsFixed(0)}'),
                  Text(
                    'Final Fare: PHP ${state.fareBreakdown!.finalFare.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                const Divider(height: 24),
                Text('Local Trip History (${state.history.length})', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final trip in state.history.take(10))
                  Card(
                    child: ListTile(
                      dense: true,
                      title: Text('PHP ${trip.finalFare.toStringAsFixed(0)} • ${trip.distanceKm.toStringAsFixed(2)} km'),
                      subtitle: Text('${trip.startNodeId} → ${trip.endNodeId}\n${trip.completedAtIso}'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
