import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../map/map_view.dart';
import 'passenger_controller.dart';

class PassengerHomeScreen extends ConsumerWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerState = ref.watch(passengerControllerProvider);
    final requestAsync = ref.watch(rideRequestStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.passengerMode)),
      body: Column(
        children: [
          Expanded(
            child: MapView(
              pickupLocation: passengerState.pickupLocation,
              onTap: (location) => ref
                  .read(passengerControllerProvider.notifier)
                  .selectPickupLocation(location),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (passengerState.pickupLocation == null)
                  const Text('Tap the map to select a pickup location.'),
                if (passengerState.activeRequestId != null)
                  requestAsync.when(
                    data: (request) => Text(
                      'Ride status: ${request?.status ?? 'unknown'}',
                    ),
                    loading: () => const Text('Checking ride status...'),
                    error: (_, __) => const Text('Unable to load ride status.'),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: passengerState.isRequesting
                      ? null
                      : () => ref
                          .read(passengerControllerProvider.notifier)
                          .requestRide(),
                  child: passengerState.isRequesting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(AppStrings.requestRide),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
