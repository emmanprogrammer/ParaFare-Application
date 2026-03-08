import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../map/map_view.dart';
import '../mvp_controller.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mvpControllerProvider);
    final profile = state.data.profile;

    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profile == null) {
      return const Scaffold(body: Center(child: Text('Profile missing. Please re-run onboarding.')));
    }

    final controller = ref.read(mvpControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard • ${profile.tricycleId}'),
        actions: [
          IconButton(
            onPressed: () => context.go('/mvp/history'),
            icon: const Icon(Icons.receipt_long),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: const MapView(showLiveLocation: true),
          ),
          Expanded(
            flex: 3,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.35,
              ),
              itemCount: profile.seatCount,
              itemBuilder: (context, index) {
                final slot = index + 1;
                final ride = controller.activeRideForSlot(slot);
                final occupied = ride != null;

                return Card(
                  child: InkWell(
                    onTap: () {
                      if (occupied) {
                        context.go('/mvp/ride/manage/$slot');
                      } else {
                        context.go('/mvp/ride/new/$slot');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: occupied
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Passenger $slot', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('Fare: PHP ${ride.finalFare.toStringAsFixed(0)}'),
                                Text('${ride.distanceKm.toStringAsFixed(2)} km • ${ride.estimatedMinutes} min'),
                                const Spacer(),
                                const Text('Tap to manage', style: TextStyle(color: Colors.blue)),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Passenger $slot', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                const Text('Empty slot', style: TextStyle(color: Colors.green)),
                                const SizedBox(height: 4),
                                const Text('Tap to add ride'),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
