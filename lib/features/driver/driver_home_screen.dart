import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers.dart';
import '../map/map_view.dart';
import 'driver_controller.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(incomingRideRequestProvider, (previous, next) {
      next.whenData((request) {
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Incoming Ride Request'),
              content: Text(
                'Pickup at (${request.pickupLat.toStringAsFixed(5)}, '
                '${request.pickupLng.toStringAsFixed(5)})',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(dispatchRepositoryProvider)
                        .updateRideStatus(
                          requestId: request.id,
                          status: 'declined',
                        );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Decline'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(dispatchRepositoryProvider)
                        .updateRideStatus(
                          requestId: request.id,
                          status: 'accepted',
                        );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Accept'),
                ),
              ],
            );
          },
        );
      });
    });

    final driverState = ref.watch(driverControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.driverMode)),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(driverState.isOnline ? 'Online' : 'Offline'),
            subtitle: const Text('Toggle to publish location and accept rides.'),
            value: driverState.isOnline,
            onChanged: (value) {
              ref.read(driverControllerProvider.notifier).toggleOnline(value);
            },
          ),
          const Expanded(child: MapView()),
        ],
      ),
    );
  }
}
