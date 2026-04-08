class GraphNode {
  const GraphNode({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final double latitude;
  final double longitude;

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class GraphEdge {
  const GraphEdge({
    required this.fromNodeId,
    required this.toNodeId,
    required this.distanceKm,
  });

  final String fromNodeId;
  final String toNodeId;
  final double distanceKm;

  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    final km = json['distanceKm'];
    final meters = json['distanceMeters'];
    return GraphEdge(
      fromNodeId: json['fromNodeId'] as String,
      toNodeId: json['toNodeId'] as String,
      distanceKm: km != null
          ? (km as num).toDouble()
          : ((meters as num).toDouble() / 1000.0),
    );
  }

  Map<String, dynamic> toJson() => {
        'fromNodeId': fromNodeId,
        'toNodeId': toNodeId,
        'distanceKm': distanceKm,
      };
}

class GraphData {
  const GraphData({
    required this.nodes,
    required this.edges,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  factory GraphData.fromJson(Map<String, dynamic> json) {
    final nodes = (json['nodes'] as List<dynamic>)
        .map((node) => GraphNode.fromJson(Map<String, dynamic>.from(node as Map)))
        .toList(growable: false);

    final edges = (json['edges'] as List<dynamic>)
        .map((edge) => GraphEdge.fromJson(Map<String, dynamic>.from(edge as Map)))
        .toList(growable: false);

    return GraphData(nodes: nodes, edges: edges);
  }

  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((node) => node.toJson()).toList(growable: false),
        'edges': edges.map((edge) => edge.toJson()).toList(growable: false),
      };
}
