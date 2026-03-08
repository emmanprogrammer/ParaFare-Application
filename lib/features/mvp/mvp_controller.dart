import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import '../../core/services/location_service.dart';
import '../dispatch/graph/graph_data_sources.dart';
import '../dispatch/graph/graph_models.dart';
import '../dispatch/graph/graph_snap_service.dart';
import '../dispatch/graph/route_distance_service.dart';
import '../dispatch/simulation/fare_calculator.dart';
import 'data/mvp_local_store.dart';
import 'models/mvp_models.dart';

class MvpState {
  const MvpState({
    this.data = const MvpAppData(onboardingComplete: false),
    this.graph,
    this.loading = true,
    this.error,
  });

  final MvpAppData data;
  final GraphData? graph;
  final bool loading;
  final String? error;

  MvpState copyWith({
    MvpAppData? data,
    GraphData? graph,
    bool? loading,
    String? error,
  }) {
    return MvpState(
      data: data ?? this.data,
      graph: graph ?? this.graph,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final mvpControllerProvider = StateNotifierProvider<MvpController, MvpState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final fareCalculator = ref.watch(fareCalculatorProvider);
  final graphDataSource = ref.watch(graphDataSourceProvider);
  final snapService = ref.watch(graphSnapServiceProvider);
  final routeDistanceService = ref.watch(routeDistanceServiceProvider);

  return MvpController(
    locationService,
    fareCalculator,
    graphDataSource,
    snapService,
    routeDistanceService,
  )
    ..initialize();
});

class MvpController extends StateNotifier<MvpState> {
  MvpController(
    this._locationService,
    this._fareCalculator,
    this._graphDataSource,
    this._snapService,
    this._routeDistanceService,
  ) : super(const MvpState());

  final LocationService _locationService;
  final FareCalculator _fareCalculator;
  final GraphDataSource _graphDataSource;
  final GraphSnapService _snapService;
  final RouteDistanceService _routeDistanceService;
  late MvpLocalStore _store;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _store = MvpLocalStore(prefs);
    final data = await _store.load();

    GraphData? graph;
    try {
      graph = await _graphDataSource.loadGraph();
    } on Exception {
      graph = null;
    }

    state = state.copyWith(data: data, graph: graph, loading: false, error: null);
  }

  Future<void> completeOnboarding(DriverProfile profile) async {
    final data = state.data.copyWith(
      onboardingComplete: true,
      profile: profile,
    );
    await _store.save(data);
    state = state.copyWith(data: data, error: null);
  }

  RideRecord? activeRideForSlot(int slotIndex) => state.data.activeRides[slotIndex];

  Future<Position> getCurrentPosition() => _locationService.getCurrentPosition();

  FarePreview? calculatePreview({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) {
    final graph = state.graph;
    if (graph == null) {
      return null;
    }

    final route = _routeDistanceService.calculate(
      graph: graph,
      startLat: originLat,
      startLng: originLng,
      endLat: destinationLat,
      endLng: destinationLng,
      snapService: _snapService,
    );

    if (route == null) {
      return null;
    }

    final estimatedMinutes = max(1, (route.totalDistanceKm / 20 * 60).round());
    final fare = _fareCalculator.calculate(
      distanceKm: route.totalDistanceKm,
      applyDiscount: false,
      manualAdjustment: 0,
    );

    return FarePreview(
      distanceKm: route.totalDistanceKm,
      estimatedMinutes: estimatedMinutes,
      baseFare: fare.baseFare,
      suggestedFare: fare.finalFare,
      graphDistanceKm: route.graphDistanceKm,
      startOffsetKm: route.startOffsetKm,
      endOffsetKm: route.endOffsetKm,
      startSnapNodeId: route.startSnap.node.id,
      endSnapNodeId: route.endSnap.node.id,
      startSnapLat: route.startSnap.node.latitude,
      startSnapLng: route.startSnap.node.longitude,
      endSnapLat: route.endSnap.node.latitude,
      endSnapLng: route.endSnap.node.longitude,
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

    if (preview == null) {
      state = state.copyWith(error: 'Unable to compute route on graph.');
      return;
    }

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

    final active = Map<int, RideRecord>.from(state.data.activeRides)..[slotIndex] = ride;

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

    final active = Map<int, RideRecord>.from(state.data.activeRides)..remove(slotIndex);
    final completedRides = [completed, ...state.data.completedRides].take(200).toList(growable: false);

    final data = state.data.copyWith(
      activeRides: active,
      completedRides: completedRides,
    );

    await _store.save(data);
    state = state.copyWith(data: data, error: null);
  }

  double todayEarnings() {
    final now = DateTime.now();
    return state.data.completedRides.where((ride) {
      final completed = DateTime.tryParse(ride.completedAtIso ?? '');
      return completed != null &&
          completed.year == now.year &&
          completed.month == now.month &&
          completed.day == now.day;
    }).fold<double>(0, (sum, ride) => sum + ride.finalFare);
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
}

class FarePreview {
  const FarePreview({
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.baseFare,
    required this.suggestedFare,
    required this.graphDistanceKm,
    required this.startOffsetKm,
    required this.endOffsetKm,
    required this.startSnapNodeId,
    required this.endSnapNodeId,
    required this.startSnapLat,
    required this.startSnapLng,
    required this.endSnapLat,
    required this.endSnapLng,
  });

  final double distanceKm;
  final int estimatedMinutes;
  final double baseFare;
  final double suggestedFare;
  final double graphDistanceKm;
  final double startOffsetKm;
  final double endOffsetKm;
  final String startSnapNodeId;
  final String endSnapNodeId;
  final double startSnapLat;
  final double startSnapLng;
  final double endSnapLat;
  final double endSnapLng;
}
