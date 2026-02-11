// GENERATED FILE. DO NOT EDIT.
// Seed dataset used when full OSM extraction is not yet generated.

import '../tricycle_network.dart';

class GensanNetworkData {
  static const List<TricycleNode> nodes = [
    TricycleNode(id: 'plaza', name: 'City Plaza', latitude: 6.1162, longitude: 125.1719),
    TricycleNode(id: 'market', name: 'Public Market', latitude: 6.1129, longitude: 125.1752),
    TricycleNode(id: 'terminal', name: 'Integrated Terminal', latitude: 6.1057, longitude: 125.1685),
    TricycleNode(id: 'hospital', name: 'City Hospital', latitude: 6.1214, longitude: 125.1648),
    TricycleNode(id: 'school', name: 'State University', latitude: 6.1248, longitude: 125.1770),
    TricycleNode(id: 'seaport', name: 'Makar Port', latitude: 6.0905, longitude: 125.1543),
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
