import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mvp_controller.dart';

class EarningsHistoryScreen extends ConsumerWidget {
  const EarningsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mvpControllerProvider);
    final controller = ref.read(mvpControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings & History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Trips: ${controller.todayTripCount()}'),
                    Text('Earnings: PHP ${controller.todayEarnings().toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state.data.completedRides.length,
                itemBuilder: (context, index) {
                  final ride = state.data.completedRides[index];
                  return Card(
                    child: ListTile(
                      title: Text('PHP ${ride.finalFare.toStringAsFixed(0)} • ${ride.distanceKm.toStringAsFixed(2)} km'),
                      subtitle: Text(
                        '${ride.originLabel} → ${ride.destinationLabel}\nPassenger ${ride.slotIndex} • ${ride.completedAtIso ?? ride.startedAtIso}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
