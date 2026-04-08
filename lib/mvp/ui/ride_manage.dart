import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parafare_application/mvp/ctrl.dart';

class RideManageScreen extends ConsumerWidget {
  const RideManageScreen({
    super.key,
    required this.slotIndex,
  });

  final int slotIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(mvpControllerProvider).data.activeRides[slotIndex];
    if (ride == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Passenger $slotIndex')),
        body: const Center(child: Text('No active ride for this slot.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Manage Ride • Passenger $slotIndex')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Origin: ${ride.originLabel}'),
            Text('Destination: ${ride.destinationLabel}'),
            const SizedBox(height: 8),
            Text('Distance: ${ride.distanceKm.toStringAsFixed(2)} km'),
            Text('Estimated Time: ${ride.estimatedMinutes} min'),
            Text('Current Fare: PHP ${ride.finalFare.toStringAsFixed(0)}'),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.go('/mvp/ride/finalize/$slotIndex'),
              icon: const Icon(Icons.check),
              label: const Text('Finish Ride'),
            ),
          ],
        ),
      ),
    );
  }
}
