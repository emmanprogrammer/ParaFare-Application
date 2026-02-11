import 'package:latlong2/latlong.dart';

class TricycleNode {
  const TricycleNode({
    required this.id,
    required this.name,
    required this.coordinate,
  });

  final String id;
  final String name;
  final LatLng coordinate;
}

class TricycleEdge {
  const TricycleEdge({
    required this.fromNodeId,
    required this.toNodeId,
    required this.distanceKm,
  });

  final String fromNodeId;
  final String toNodeId;
  final double distanceKm;
}

/// Initial node graph for testing shortest path and fare computation without GPS.
///
/// Future extension:
/// - Replace static graph with Firestore-managed nodes/edges.
/// - Add edge metadata: road type, one-way flag, tricycle restrictions.
class TricycleNetwork {
  static const List<TricycleNode> nodes = [
    TricycleNode(
      id: 'plaza',
      name: 'City Plaza',
      coordinate: LatLng(6.1162, 125.1719),
    ),
    TricycleNode(
      id: 'market',
      name: 'Public Market',
      coordinate: LatLng(6.1129, 125.1752),
    ),
    TricycleNode(
      id: 'terminal',
      name: 'Integrated Terminal',
      coordinate: LatLng(6.1057, 125.1685),
    ),
    TricycleNode(
      id: 'hospital',
      name: 'City Hospital',
      coordinate: LatLng(6.1214, 125.1648),
    ),
    TricycleNode(
      id: 'school',
      name: 'State University',
      coordinate: LatLng(6.1248, 125.1770),
    ),
    TricycleNode(
      id: 'seaport',
      name: 'Makar Port',
      coordinate: LatLng(6.0905, 125.1543),
    ),
  ];

  static const List<TricycleEdge> edges = [
    TricycleEdge(fromNodeId: 'plaza', toNodeId: 'market', distanceKm: 1.2),
    TricycleEdge(fromNodeId: 'plaza', toNodeId: 'hospital', distanceKm: 1.5),
    TricycleEdge(fromNodeId: 'hospital', toNodeId: 'school', distanceKm: 1.7),
    TricycleEdge(fromNodeId: 'plaza', toNodeId: 'terminal', distanceKm: 2.0),
    TricycleEdge(fromNodeId: 'market', toNodeId: 'terminal', distanceKm: 1.6),
    TricycleEdge(fromNodeId: 'terminal', toNodeId: 'seaport', distanceKm: 3.1),
    TricycleEdge(fromNodeId: 'market', toNodeId: 'school', distanceKm: 2.5),
    TricycleEdge(fromNodeId: 'hospital', toNodeId: 'market', distanceKm: 1.8),
  ];
}
