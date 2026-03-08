import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../map/map_providers.dart';
import '../map/map_view.dart';
import 'trip_simulation_controller.dart';

class TripScreen extends ConsumerWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripSimulationControllerProvider);
    final nodes = ref.watch(tricycleNodesProvider);
    final controller = ref.read(tripSimulationControllerProvider.notifier);
    final tileConfig = ref.watch(mapTileConfigProvider);

    final nodeById = {for (final node in nodes) node.id: node};
    final routePoints = state.routePoints(nodes);

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Simulation')),
      body: Column(
        children: [
          Expanded(
            child: MapView(
              showLiveLocation: false,
              routePoints: routePoints,
              extraMarkers: [
                for (final node in nodes)
                  Marker(
                    point: node.coordinate,
                    width: 160,
                    height: 42,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        node.name,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<MapTileMode>(
                  segments: const [
                    ButtonSegment(
                      value: MapTileMode.online,
                      label: Text('Online Map'),
                      icon: Icon(Icons.public),
                    ),
                    ButtonSegment(
                      value: MapTileMode.offline,
                      label: Text('Offline Map'),
                      icon: Icon(Icons.offline_pin),
                    ),
                  ],
                  selected: {tileConfig.mode},
                  onSelectionChanged: (selection) {
                    controller.setTileMode(selection.first);
                  },
                ),
                const SizedBox(height: 8),
                Text(tileConfig.description),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: state.startNodeId,
                  decoration: const InputDecoration(labelText: 'Origin Node'),
                  items: [
                    for (final node in nodes)
                      DropdownMenuItem(value: node.id, child: Text(node.name)),
                  ],
                  onChanged: controller.setStartNode,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: state.endNodeId,
                  decoration: const InputDecoration(labelText: 'Destination Node'),
                  items: [
                    for (final node in nodes)
                      DropdownMenuItem(value: node.id, child: Text(node.name)),
                  ],
                  onChanged: controller.setEndNode,
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: state.applyDiscount,
                  onChanged: controller.toggleDiscount,
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
                ElevatedButton(
                  onPressed: controller.computeTrip,
                  child: const Text('Compute Shortest Path & Fare'),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                if (state.pathResult != null && state.fareBreakdown != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Path: ${state.pathResult!.nodeIds.map((id) => nodeById[id]?.name ?? id).join(' → ')}',
                  ),
                  Text('Distance: ${state.pathResult!.totalDistanceKm.toStringAsFixed(2)} km'),
                  Text('Base Fare: PHP ${state.fareBreakdown!.baseFare.toStringAsFixed(0)}'),
                  Text('Discount: PHP ${state.fareBreakdown!.discountAmount.toStringAsFixed(0)}'),
                  Text(
                    'Final Fare: PHP ${state.fareBreakdown!.finalFare.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
