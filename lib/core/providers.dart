import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parafare_application/data/repositories/dispatch_repository.dart';
import 'package:parafare_application/data/repositories/dispatch_repository_impl.dart';
import 'package:parafare_application/features/dispatch/graph/graph_data_sources.dart';
import 'package:parafare_application/features/dispatch/graph/graph_snap_service.dart';
import 'package:parafare_application/features/dispatch/graph/route_distance_service.dart';
import 'package:parafare_application/features/dispatch/history/trip_history_store.dart';
import 'package:parafare_application/features/dispatch/simulation/fare_calculator.dart';
import 'package:parafare_application/core/services/location_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final dispatchRepositoryProvider = Provider<DispatchRepository>((ref) {
  return DispatchRepositoryImpl(ref.watch(firestoreProvider));
});

final graphDataSourceProvider = Provider<GraphDataSource>((ref) {
  // Attempt converted local graph first, then fall back to generated Dart graph.
  return const FallbackGraphDataSource(
    primary: JsonAssetGraphDataSource('assets/graph/gensan_graph.json'),
    fallback: GeneratedDartGraphDataSource(),
  );
});

final graphSnapServiceProvider = Provider<GraphSnapService>((ref) {
  return const GraphSnapService();
});

final fareCalculatorProvider = Provider<FareCalculator>((ref) {
  return const FareCalculator();
});


final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final tripHistoryStoreProvider = FutureProvider<TripHistoryStore>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return TripHistoryStore(prefs);
});

final routeDistanceServiceProvider = Provider<RouteDistanceService>((ref) {
  return const RouteDistanceService();
});
