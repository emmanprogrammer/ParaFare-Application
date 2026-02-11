import 'package:latlong2/latlong.dart';

import 'generated/gensan_network_data.dart';

class TricycleNode {
  const TricycleNode({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  LatLng get coordinate => LatLng(latitude, longitude);
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

/// Tricycle node graph generated from OpenStreetMap road network for
/// General Santos City (intersection-style nodes + weighted edges).
class TricycleNetwork {
  static const List<TricycleNode> nodes = GensanNetworkData.nodes;
  static const List<TricycleEdge> edges = GensanNetworkData.edges;
}
