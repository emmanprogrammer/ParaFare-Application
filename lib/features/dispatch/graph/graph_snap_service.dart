import 'dart:math';

import 'graph_models.dart';

class SnapResult {
  const SnapResult({
    required this.node,
    required this.distanceKm,
  });

  final GraphNode node;
  final double distanceKm;
}

class GraphSnapService {
  const GraphSnapService();

  SnapResult nearestNode({
    required double latitude,
    required double longitude,
    required List<GraphNode> nodes,
  }) {
    if (nodes.isEmpty) {
      throw StateError('Graph has no nodes.');
    }

    GraphNode bestNode = nodes.first;
    double bestDistance = _haversineKm(
      latitude,
      longitude,
      bestNode.latitude,
      bestNode.longitude,
    );

    for (final node in nodes.skip(1)) {
      final d = _haversineKm(latitude, longitude, node.latitude, node.longitude);
      if (d < bestDistance) {
        bestDistance = d;
        bestNode = node;
      }
    }

    return SnapResult(node: bestNode, distanceKm: bestDistance);
  }

  double haversineDistanceKm({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    return _haversineKm(fromLatitude, fromLongitude, toLatitude, toLongitude);
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dPhi = (lat2 - lat1) * pi / 180;
    final dLambda = (lon2 - lon1) * pi / 180;

    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);

    return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
