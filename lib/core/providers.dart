import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/dispatch_repository.dart';
import '../data/repositories/dispatch_repository_impl.dart';
import 'services/location_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final dispatchRepositoryProvider = Provider<DispatchRepository>((ref) {
  return DispatchRepositoryImpl(ref.watch(firestoreProvider));
});
