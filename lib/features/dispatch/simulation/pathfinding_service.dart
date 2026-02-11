import 'package:collection/collection.dart';

import 'tricycle_network.dart';

class PathResult {
  const PathResult({
    required this.nodeIds,
    required this.totalDistanceKm,
  });

  final List<String> nodeIds;
  final double totalDistanceKm;
}

class PathfindingService {
  const PathfindingService({
    this.nodes = TricycleNetwork.nodes,
    this.edges = TricycleNetwork.edges,
  });

  final List<TricycleNode> nodes;
  final List<TricycleEdge> edges;

  PathResult? shortestPath({
    required String startNodeId,
    required String endNodeId,
  }) {
    if (startNodeId == endNodeId) {
      return PathResult(nodeIds: [startNodeId], totalDistanceKm: 0);
    }

    final nodeIds = nodes.map((node) => node.id).toSet();
    if (!nodeIds.contains(startNodeId) || !nodeIds.contains(endNodeId)) {
      return null;
    }

    final adjacency = _buildAdjacency();
    final distances = <String, double>{for (final id in nodeIds) id: double.infinity};
    final previous = <String, String?>{for (final id in nodeIds) id: null};

    distances[startNodeId] = 0;

    final queue = PriorityQueue<_QueueNode>((a, b) => a.distance.compareTo(b.distance))
      ..add(_QueueNode(nodeId: startNodeId, distance: 0));

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current.distance > (distances[current.nodeId] ?? double.infinity)) {
        continue;
      }

      if (current.nodeId == endNodeId) {
        break;
      }

      for (final edge in adjacency[current.nodeId] ?? const <_AdjEdge>[]) {
        final candidate = current.distance + edge.distanceKm;
        if (candidate < (distances[edge.toNodeId] ?? double.infinity)) {
          distances[edge.toNodeId] = candidate;
          previous[edge.toNodeId] = current.nodeId;
          queue.add(_QueueNode(nodeId: edge.toNodeId, distance: candidate));
        }
      }
    }

    final destinationDistance = distances[endNodeId] ?? double.infinity;
    if (destinationDistance == double.infinity) {
      return null;
    }

    final path = <String>[];
    String? cursor = endNodeId;
    while (cursor != null) {
      path.add(cursor);
      cursor = previous[cursor];
    }

    return PathResult(
      nodeIds: path.reversed.toList(),
      totalDistanceKm: destinationDistance,
    );
  }

  Map<String, List<_AdjEdge>> _buildAdjacency() {
    final map = <String, List<_AdjEdge>>{};
    for (final edge in edges) {
      map.putIfAbsent(edge.fromNodeId, () => <_AdjEdge>[]).add(
            _AdjEdge(toNodeId: edge.toNodeId, distanceKm: edge.distanceKm),
          );
      map.putIfAbsent(edge.toNodeId, () => <_AdjEdge>[]).add(
            _AdjEdge(toNodeId: edge.fromNodeId, distanceKm: edge.distanceKm),
          );
    }
    return map;
  }
}

class _QueueNode {
  const _QueueNode({required this.nodeId, required this.distance});

  final String nodeId;
  final double distance;
}

class _AdjEdge {
  const _AdjEdge({required this.toNodeId, required this.distanceKm});

  final String toNodeId;
  final double distanceKm;
}
