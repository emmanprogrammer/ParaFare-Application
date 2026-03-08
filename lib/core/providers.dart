import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parafare_application/core/services/location_service.dart';
import 'package:parafare_application/fare/calc.dart';
import 'package:parafare_application/nav/data.dart';
import 'package:parafare_application/nav/route.dart';
import 'package:parafare_application/nav/snap.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final graphDataSourceProvider = Provider<GraphDataSource>((ref) {
  return const JsonAssetGraphDataSource('assets/graph/gensan_graph.json');
});

final graphSnapServiceProvider = Provider<GraphSnapService>((ref) {
  return const GraphSnapService();
});

final fareCalculatorProvider = Provider<FareCalculator>((ref) {
  return const FareCalculator();
});

final routeDistanceServiceProvider = Provider<RouteDistanceService>((ref) {
  return const RouteDistanceService();
});
