import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:parafare_application/features/dispatch/simulation/tricycle_network.dart';
import 'package:parafare_application/features/dispatch/graph/graph_models.dart';

abstract class GraphDataSource {
  Future<GraphData> loadGraph();
}

class GeneratedDartGraphDataSource implements GraphDataSource {
  const GeneratedDartGraphDataSource();

  @override
  Future<GraphData> loadGraph() async {
    return GraphData(
      nodes: TricycleNetwork.nodes
          .map(
            (node) => GraphNode(
              id: node.id,
              latitude: node.latitude,
              longitude: node.longitude,
            ),
          )
          .toList(growable: false),
      edges: TricycleNetwork.edges
          .map(
            (edge) => GraphEdge(
              fromNodeId: edge.fromNodeId,
              toNodeId: edge.toNodeId,
              distanceKm: edge.distanceKm,
            ),
          )
          .toList(growable: false),
    );
  }
}

class JsonAssetGraphDataSource implements GraphDataSource {
  const JsonAssetGraphDataSource(this.assetPath);

  final String assetPath;

  @override
  Future<GraphData> loadGraph() async {
    final raw = await rootBundle.loadString(assetPath);
    return GraphData.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }
}

class FallbackGraphDataSource implements GraphDataSource {
  const FallbackGraphDataSource({
    required this.primary,
    required this.fallback,
  });

  final GraphDataSource primary;
  final GraphDataSource fallback;

  @override
  Future<GraphData> loadGraph() async {
    try {
      return await primary.loadGraph();
    } on Exception {
      return fallback.loadGraph();
    }
  }
}
