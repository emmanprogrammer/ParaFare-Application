import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/providers.dart';

final locationPermissionProvider = FutureProvider<bool>((ref) async {
  return ref.watch(locationServiceProvider).ensurePermission();
});

final locationStreamProvider = StreamProvider<Position>((ref) async* {
  final hasPermission = await ref.watch(locationPermissionProvider.future);
  if (!hasPermission) {
    return;
  }

  yield* ref.watch(locationServiceProvider).positionStream();
});
