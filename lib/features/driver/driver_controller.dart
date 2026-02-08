import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers.dart';
import '../../data/models/driver.dart';
import '../../data/models/ride_request.dart';

class DriverState {
  const DriverState({
    required this.isOnline,
    this.position,
  });

  final bool isOnline;
  final Position? position;

  DriverState copyWith({bool? isOnline, Position? position}) {
    return DriverState(
      isOnline: isOnline ?? this.isOnline,
      position: position ?? this.position,
    );
  }
}

class DriverController extends StateNotifier<DriverState> {
  DriverController(this._ref) : super(const DriverState(isOnline: false));

  final Ref _ref;
  StreamSubscription<Position>? _locationSubscription;

  Future<void> toggleOnline(bool shouldBeOnline) async {
    if (!shouldBeOnline) {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      state = state.copyWith(isOnline: false);
      await _updateDriverStatus(isOnline: false);
      return;
    }

    final hasPermission =
        await _ref.read(locationServiceProvider).ensurePermission();
    if (!hasPermission) {
      return;
    }

    state = state.copyWith(isOnline: true);
    await _updateDriverStatus(isOnline: true);

    _locationSubscription = _ref
        .read(locationServiceProvider)
        .positionStream()
        .listen(_handlePositionUpdate);
  }

  Future<void> _handlePositionUpdate(Position position) async {
    state = state.copyWith(position: position);
    await _updateDriverStatus(
      isOnline: true,
      position: position,
    );
  }

  Future<void> _updateDriverStatus({
    required bool isOnline,
    Position? position,
  }) async {
    final firestore = _ref.read(firestoreProvider);
    const driverId = 'driver-001';
    final driver = Driver(
      id: driverId,
      isOnline: isOnline,
      lat: position?.latitude ?? state.position?.latitude ?? 0,
      lng: position?.longitude ?? state.position?.longitude ?? 0,
      lastUpdated: DateTime.now(),
    );

    await firestore
        .collection(FirestoreCollections.drivers)
        .doc(driverId)
        .set(driver.toJson(), SetOptions(merge: true));
  }
}

final driverControllerProvider =
    StateNotifierProvider<DriverController, DriverState>((ref) {
  return DriverController(ref);
});

final incomingRideRequestProvider = StreamProvider<RideRequest>((ref) {
  return ref.watch(dispatchRepositoryProvider).listenForIncomingRequests();
});
