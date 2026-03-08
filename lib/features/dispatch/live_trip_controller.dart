import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:parafare_application/core/providers.dart';
import 'package:parafare_application/features/dispatch/graph/graph_models.dart';
import 'package:parafare_application/features/dispatch/graph/graph_snap_service.dart';
import 'package:parafare_application/features/dispatch/history/trip_history_store.dart';
import 'package:parafare_application/features/dispatch/simulation/fare_calculator.dart';
import 'package:parafare_application/features/dispatch/simulation/pathfinding_service.dart';

class LiveTripState {
  const LiveTripState({
    this.graph,
    this.startPosition,
    this.endPosition,
    this.startSnap,
    this.endSnap,
    this.pathResult,
    this.fareBreakdown,
    this.discountApplied = false,
    this.manualAdjustment = 0,
    this.isLoading = false,
    this.errorMessage,
    this.history = const [],
  });

  final GraphData? graph;
  final Position? startPosition;
  final Position? endPosition;
  final SnapResult? startSnap;
  final SnapResult? endSnap;
  final PathResult? pathResult;
  final FareBreakdown? fareBreakdown;
  final bool discountApplied;
  final double manualAdjustment;
  final bool isLoading;
  final String? errorMessage;
  final List<CompletedTripRecord> history;

  LiveTripState copyWith({
    GraphData? graph,
    Position? startPosition,
    Position? endPosition,
    SnapResult? startSnap,
    SnapResult? endSnap,
    PathResult? pathResult,
    FareBreakdown? fareBreakdown,
    bool? discountApplied,
    double? manualAdjustment,
    bool? isLoading,
    String? errorMessage,
    List<CompletedTripRecord>? history,
    bool clearResult = false,
  }) {
    return LiveTripState(
      graph: graph ?? this.graph,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      startSnap: startSnap ?? this.startSnap,
      endSnap: endSnap ?? this.endSnap,
      pathResult: clearResult ? null : (pathResult ?? this.pathResult),
      fareBreakdown: clearResult ? null : (fareBreakdown ?? this.fareBreakdown),
      discountApplied: discountApplied ?? this.discountApplied,
      manualAdjustment: manualAdjustment ?? this.manualAdjustment,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      history: history ?? this.history,
    );
  }
}

final liveTripControllerProvider =
    StateNotifierProvider<LiveTripController, LiveTripState>((ref) {
  return LiveTripController(ref)..initialize();
});

class LiveTripController extends StateNotifier<LiveTripState> {
  LiveTripController(this._ref) : super(const LiveTripState());

  final Ref _ref;

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final graph = await _ref.read(graphDataSourceProvider).loadGraph();
      final store = await _ref.read(tripHistoryStoreProvider.future);
      final history = await store.loadTrips();

      state = state.copyWith(
        graph: graph,
        history: history,
        isLoading: false,
      );
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize live trip mode: $error',
      );
    }
  }

  void setDiscountApplied(bool value) {
    state = state.copyWith(discountApplied: value, errorMessage: null);
    _recomputeFareIfReady();
  }

  void setManualAdjustment(double value) {
    state = state.copyWith(manualAdjustment: value, errorMessage: null);
    _recomputeFareIfReady();
  }

  Future<void> captureTripStart() async {
    final graph = state.graph;
    if (graph == null) {
      state = state.copyWith(errorMessage: 'Graph is not loaded yet.');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, clearResult: true);

    try {
      final position = await _ref.read(locationServiceProvider).getCurrentPosition();
      final snap = _ref.read(graphSnapServiceProvider).nearestNode(
            latitude: position.latitude,
            longitude: position.longitude,
            nodes: graph.nodes,
          );

      state = state.copyWith(
        startPosition: position,
        startSnap: snap,
        endPosition: null,
        endSnap: null,
        isLoading: false,
      );
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to capture start GPS: $error',
      );
    }
  }

  Future<void> captureTripEndAndCompute() async {
    final graph = state.graph;
    final start = state.startPosition;
    final startSnap = state.startSnap;

    if (graph == null || start == null || startSnap == null) {
      state = state.copyWith(errorMessage: 'Capture trip start first.');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final end = await _ref.read(locationServiceProvider).getCurrentPosition();
      final endSnap = _ref.read(graphSnapServiceProvider).nearestNode(
            latitude: end.latitude,
            longitude: end.longitude,
            nodes: graph.nodes,
          );

      final bool sameNode = startSnap.node.id == endSnap.node.id;
      final pathResult = sameNode
          ? PathResult(nodeIds: [startSnap.node.id], totalDistanceKm: 0)
          : PathfindingService(
              nodes: graph.nodes,
              edges: graph.edges,
            ).shortestPath(
              startNodeId: startSnap.node.id,
              endNodeId: endSnap.node.id,
            );

      final snapService = _ref.read(graphSnapServiceProvider);
      final distanceKm = sameNode
          ? snapService.haversineDistanceKm(
              fromLatitude: start.latitude,
              fromLongitude: start.longitude,
              toLatitude: end.latitude,
              toLongitude: end.longitude,
            )
          : (pathResult?.totalDistanceKm ?? 0);

      if (!sameNode && pathResult == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No route found between snapped nodes.',
          endPosition: end,
          endSnap: endSnap,
          clearResult: true,
        );
        return;
      }

      final fare = _ref.read(fareCalculatorProvider).calculate(
            distanceKm: distanceKm,
            applyDiscount: state.discountApplied,
            manualAdjustment: state.manualAdjustment,
          );

      state = state.copyWith(
        isLoading: false,
        endPosition: end,
        endSnap: endSnap,
        pathResult: pathResult ?? PathResult(nodeIds: [startSnap.node.id], totalDistanceKm: distanceKm),
        fareBreakdown: fare,
      );
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to capture end GPS: $error',
      );
    }
  }

  Future<void> completeTrip() async {
    final start = state.startPosition;
    final end = state.endPosition;
    final startSnap = state.startSnap;
    final endSnap = state.endSnap;
    final fare = state.fareBreakdown;

    if (start == null || end == null || startSnap == null || endSnap == null || fare == null) {
      state = state.copyWith(errorMessage: 'No computed trip to save yet.');
      return;
    }

    final record = CompletedTripRecord(
      completedAtIso: DateTime.now().toIso8601String(),
      startLatitude: start.latitude,
      startLongitude: start.longitude,
      endLatitude: end.latitude,
      endLongitude: end.longitude,
      startNodeId: startSnap.node.id,
      endNodeId: endSnap.node.id,
      distanceKm: fare.distanceKm,
      baseFare: fare.baseFare,
      discountAmount: fare.discountAmount,
      manualAdjustment: fare.manualAdjustment,
      finalFare: fare.finalFare,
    );

    final store = await _ref.read(tripHistoryStoreProvider.future);
    await store.saveTrip(record);
    final history = await store.loadTrips();

    state = state.copyWith(history: history, errorMessage: null);
  }

  void _recomputeFareIfReady() {
    final fare = state.fareBreakdown;
    if (fare == null) {
      return;
    }

    final recalculated = _ref.read(fareCalculatorProvider).calculate(
          distanceKm: fare.distanceKm,
          applyDiscount: state.discountApplied,
          manualAdjustment: state.manualAdjustment,
        );

    state = state.copyWith(fareBreakdown: recalculated);
  }
}
