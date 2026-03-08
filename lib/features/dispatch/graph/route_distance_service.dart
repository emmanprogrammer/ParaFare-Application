import 'graph_models.dart';
import 'graph_snap_service.dart';
import '../simulation/pathfinding_service.dart';

class RouteDistanceResult {
  const RouteDistanceResult({
    required this.totalDistanceKm,
    required this.graphDistanceKm,
    required this.startOffsetKm,
    required this.endOffsetKm,
    required this.startSnap,
    required this.endSnap,
    required this.pathNodeIds,
  });

  final double totalDistanceKm;
  final double graphDistanceKm;
  final double startOffsetKm;
  final double endOffsetKm;
  final SnapResult startSnap;
  final SnapResult endSnap;
  final List<String> pathNodeIds;
}

class RouteDistanceService {
  const RouteDistanceService();

  RouteDistanceResult? calculate({
    required GraphData graph,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required GraphSnapService snapService,
  }) {
    final startSnap = snapService.nearestNode(
      latitude: startLat,
      longitude: startLng,
      nodes: graph.nodes,
    );
    final endSnap = snapService.nearestNode(
      latitude: endLat,
      longitude: endLng,
      nodes: graph.nodes,
    );

    final startOffsetKm = startSnap.distanceKm;
    final endOffsetKm = endSnap.distanceKm;

    final pathfinding = PathfindingService(
      nodes: graph.nodes,
      edges: graph.edges,
    );

    final path = pathfinding.shortestPath(
      startNodeId: startSnap.node.id,
      endNodeId: endSnap.node.id,
    );

    if (path == null) {
      return null;
    }

    final totalDistanceKm = path.totalDistanceKm + startOffsetKm + endOffsetKm;

    return RouteDistanceResult(
      totalDistanceKm: totalDistanceKm,
      graphDistanceKm: path.totalDistanceKm,
      startOffsetKm: startOffsetKm,
      endOffsetKm: endOffsetKm,
      startSnap: startSnap,
      endSnap: endSnap,
      pathNodeIds: path.nodeIds,
    );
  }
}
