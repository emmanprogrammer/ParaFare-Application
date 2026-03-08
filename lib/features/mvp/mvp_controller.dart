import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/location_service.dart';
import '../dispatch/simulation/fare_calculator.dart';
import 'data/mvp_local_store.dart';
import 'models/mvp_models.dart';

class MvpState {
  const MvpState({
    this.data = const MvpAppData(onboardingComplete: false),
    this.loading = true,
    this.error,
  });

  final MvpAppData data;
  final bool loading;
  final String? error;

  MvpState copyWith({
    MvpAppData? data,
    bool? loading,
    String? error,
  }) {
    return MvpState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final mvpControllerProvider =
    StateNotifierProvider<MvpController, MvpState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final fareCalculator = ref.watch(fareCalculatorProvider);
  return MvpController(locationService, fareCalculator)..initialize();
});

class MvpController extends StateNotifier<MvpState> {
  MvpController(this._locationService, this._fareCalculator)
      : super(const MvpState());

  final LocationService _locationService;
  final FareCalculator _fareCalculator;
  late MvpLocalStore _store;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _store = MvpLocalStore(prefs);
    final data = await _store.load();
    state = state.copyWith(data: data, loading: false, error: null);
  }

  Future<void> completeOnboarding(DriverProfile profile) async {
    final data = state.data.copyWith(
      onboardingComplete: true,
      profile: profile,
    );
    await _store.save(data);
    state = state.copyWith(data: data, error: null);
  }

  bool isSlotOccupied(int slotIndex) =>
      state.data.activeRides.containsKey(slotIndex);

  RideRecord? activeRideForSlot(int slotIndex) =>
      state.data.activeRides[slotIndex];

  Future<Position> getCurrentPosition() => _locationService.getCurrentPosition();

  FarePreview calculatePreview({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) {
    final distanceKm = _haversineKm(
      originLat,
      originLng,
      destinationLat,
      destinationLng,
    );
    final estimatedMinutes = max(1, (distanceKm / 20 * 60).round());
    final fare = _fareCalculator.calculate(
      distanceKm: distanceKm,
      applyDiscount: false,
      manualAdjustment: 0,
    );

    return FarePreview(
      distanceKm: distanceKm,
      estimatedMinutes: estimatedMinutes,
      baseFare: fare.baseFare,
      suggestedFare: fare.finalFare,
    );
  }

  Future<void> assignRideToSlot({
    required int slotIndex,
    required String originLabel,
    required String destinationLabel,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final preview = calculatePreview(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );

    final ride = RideRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      slotIndex: slotIndex,
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      distanceKm: preview.distanceKm,
      estimatedMinutes: preview.estimatedMinutes,
      baseFare: preview.baseFare,
      finalFare: preview.suggestedFare,
      startedAtIso: DateTime.now().toIso8601String(),
    );

    final active = Map<int, RideRecord>.from(state.data.activeRides)
      ..[slotIndex] = ride;

    final data = state.data.copyWith(activeRides: active);
    await _store.save(data);
    state = state.copyWith(data: data, error: null);
  }

  Future<void> finishRide({
    required int slotIndex,
    required double manualAdjustment,
  }) async {
    final activeRide = state.data.activeRides[slotIndex];
    if (activeRide == null) {
      return;
    }

    final adjusted = _fareCalculator.calculate(
      distanceKm: activeRide.distanceKm,
      applyDiscount: false,
      manualAdjustment: manualAdjustment,
    );

    final completed = activeRide.copyWith(
      finalFare: adjusted.finalFare,
      completedAtIso: DateTime.now().toIso8601String(),
      isCompleted: true,
    );

    final active = Map<int, RideRecord>.from(state.data.activeRides)
      ..remove(slotIndex);
    final completedRides = [completed, ...state.data.completedRides]
        .take(200)
        .toList(growable: false);

    final data = state.data.copyWith(
      activeRides: active,
      completedRides: completedRides,
    );

    await _store.save(data);
    state = state.copyWith(data: data, error: null);
  }

  double todayEarnings() {
    final now = DateTime.now();
    return state.data.completedRides
        .where((ride) {
          final completed = DateTime.tryParse(ride.completedAtIso ?? '');
          return completed != null &&
              completed.year == now.year &&
              completed.month == now.month &&
              completed.day == now.day;
        })
        .fold<double>(0, (sum, ride) => sum + ride.finalFare);
  }

  int todayTripCount() {
    final now = DateTime.now();
    return state.data.completedRides.where((ride) {
      final completed = DateTime.tryParse(ride.completedAtIso ?? '');
      return completed != null &&
          completed.year == now.year &&
          completed.month == now.month &&
          completed.day == now.day;
    }).length;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final p1 = lat1 * pi / 180;
    final p2 = lat2 * pi / 180;
    final dp = (lat2 - lat1) * pi / 180;
    final dl = (lon2 - lon1) * pi / 180;
    final a =
        sin(dp / 2) * sin(dp / 2) + cos(p1) * cos(p2) * sin(dl / 2) * sin(dl / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}

class FarePreview {
  const FarePreview({
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.baseFare,
    required this.suggestedFare,
  });

  final double distanceKm;
  final int estimatedMinutes;
  final double baseFare;
  final double suggestedFare;
}
