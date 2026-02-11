import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../map/map_providers.dart';
import 'simulation/fare_calculator.dart';
import 'simulation/pathfinding_service.dart';
import 'simulation/tricycle_network.dart';

class TripSimulationState {
  const TripSimulationState({
    this.startNodeId,
    this.endNodeId,
    this.applyDiscount = false,
    this.manualAdjustment = 0,
    this.pathResult,
    this.fareBreakdown,
    this.errorMessage,
  });

  final String? startNodeId;
  final String? endNodeId;
  final bool applyDiscount;
  final double manualAdjustment;
  final PathResult? pathResult;
  final FareBreakdown? fareBreakdown;
  final String? errorMessage;

  List<LatLng> routePoints(List<TricycleNode> nodes) {
    final byId = {for (final node in nodes) node.id: node};
    return (pathResult?.nodeIds ?? const <String>[])
        .map((id) => byId[id]?.coordinate)
        .whereType<LatLng>()
        .toList(growable: false);
  }

  TripSimulationState copyWith({
    String? startNodeId,
    String? endNodeId,
    bool? applyDiscount,
    double? manualAdjustment,
    PathResult? pathResult,
    FareBreakdown? fareBreakdown,
    String? errorMessage,
    bool clearResult = false,
  }) {
    return TripSimulationState(
      startNodeId: startNodeId ?? this.startNodeId,
      endNodeId: endNodeId ?? this.endNodeId,
      applyDiscount: applyDiscount ?? this.applyDiscount,
      manualAdjustment: manualAdjustment ?? this.manualAdjustment,
      pathResult: clearResult ? null : (pathResult ?? this.pathResult),
      fareBreakdown: clearResult ? null : (fareBreakdown ?? this.fareBreakdown),
      errorMessage: errorMessage,
    );
  }
}

final tricycleNodesProvider = Provider<List<TricycleNode>>((ref) {
  return TricycleNetwork.nodes;
});

final pathfindingServiceProvider = Provider<PathfindingService>((ref) {
  return PathfindingService();
});

final fareCalculatorProvider = Provider<FareCalculator>((ref) {
  return const FareCalculator();
});

final tripSimulationControllerProvider =
    StateNotifierProvider<TripSimulationController, TripSimulationState>((ref) {
  return TripSimulationController(ref);
});

class TripSimulationController extends StateNotifier<TripSimulationState> {
  TripSimulationController(this._ref) : super(const TripSimulationState());

  final Ref _ref;

  void setStartNode(String? nodeId) {
    state = state.copyWith(startNodeId: nodeId, clearResult: true, errorMessage: null);
  }

  void setEndNode(String? nodeId) {
    state = state.copyWith(endNodeId: nodeId, clearResult: true, errorMessage: null);
  }

  void toggleDiscount(bool value) {
    state = state.copyWith(applyDiscount: value, errorMessage: null);
    _recalculateIfReady();
  }

  void setManualAdjustment(double value) {
    state = state.copyWith(manualAdjustment: value, errorMessage: null);
    _recalculateIfReady();
  }

  void setTileMode(MapTileMode mode) {
    _ref.read(mapTileModeProvider.notifier).state = mode;
  }

  void computeTrip() {
    final start = state.startNodeId;
    final end = state.endNodeId;

    if (start == null || end == null) {
      state = state.copyWith(errorMessage: 'Select both origin and destination nodes.');
      return;
    }

    final pathResult = _ref
        .read(pathfindingServiceProvider)
        .shortestPath(startNodeId: start, endNodeId: end);

    if (pathResult == null) {
      state = state.copyWith(
        errorMessage: 'No tricycle-accessible path found for the selected nodes.',
        clearResult: true,
      );
      return;
    }

    final fare = _ref.read(fareCalculatorProvider).calculate(
          distanceKm: pathResult.totalDistanceKm,
          applyDiscount: state.applyDiscount,
          manualAdjustment: state.manualAdjustment,
        );

    state = state.copyWith(
      pathResult: pathResult,
      fareBreakdown: fare,
      errorMessage: null,
    );
  }

  void _recalculateIfReady() {
    if (state.pathResult == null) {
      return;
    }

    final fare = _ref.read(fareCalculatorProvider).calculate(
          distanceKm: state.pathResult!.totalDistanceKm,
          applyDiscount: state.applyDiscount,
          manualAdjustment: state.manualAdjustment,
        );

    state = state.copyWith(fareBreakdown: fare);
  }
}
