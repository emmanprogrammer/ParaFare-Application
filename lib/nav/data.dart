import 'dart:convert';

import 'package:flutter/services.dart';

import 'model.dart';

abstract class GraphDataSource {
  Future<GraphData> loadGraph();
}

class JsonAssetGraphDataSource implements GraphDataSource {
  const JsonAssetGraphDataSource(this.assetPath);

  final String assetPath;

  @override
  Future<GraphData> loadGraph() async {
    final raw = await rootBundle.loadString(assetPath);
    return GraphData.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }
}
