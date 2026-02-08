import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/providers.dart';
import '../../data/models/ride_request.dart';

class PassengerState {
  const PassengerState({
    this.pickupLocation,
    this.activeRequestId,
    this.isRequesting = false,
  });

  final LatLng? pickupLocation;
  final String? activeRequestId;
  final bool isRequesting;

  PassengerState copyWith({
    LatLng? pickupLocation,
    String? activeRequestId,
    bool? isRequesting,
  }) {
    return PassengerState(
      pickupLocation: pickupLocation ?? this.pickupLocation,
      activeRequestId: activeRequestId ?? this.activeRequestId,
      isRequesting: isRequesting ?? this.isRequesting,
    );
  }
}

class PassengerController extends StateNotifier<PassengerState> {
  PassengerController(this._ref) : super(const PassengerState());

  final Ref _ref;

  void selectPickupLocation(LatLng location) {
    state = state.copyWith(pickupLocation: location);
  }

  Future<void> requestRide() async {
    final pickup = state.pickupLocation;
    if (pickup == null) {
      return;
    }

    state = state.copyWith(isRequesting: true);
    const passengerId = 'passenger-001';
    final request = await _ref
        .read(dispatchRepositoryProvider)
        .createRideRequest(
          passengerId: passengerId,
          pickupLat: pickup.latitude,
          pickupLng: pickup.longitude,
        );

    state = state.copyWith(
      activeRequestId: request.id,
      isRequesting: false,
    );
  }
}

final passengerControllerProvider =
    StateNotifierProvider<PassengerController, PassengerState>((ref) {
  return PassengerController(ref);
});

final rideRequestStreamProvider =
    StreamProvider.autoDispose<RideRequest?>((ref) {
  final requestId = ref.watch(passengerControllerProvider).activeRequestId;
  if (requestId == null) {
    return const Stream.empty();
  }

  return ref.watch(dispatchRepositoryProvider).listenForRideRequest(requestId);
});
