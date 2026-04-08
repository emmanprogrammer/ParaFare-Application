import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_pmtiles/flutter_map_pmtiles.dart';
import 'package:geolocator/geolocator.dart';

import 'package:parafare_application/core/providers.dart';

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

final pmTilesTileProviderProvider = FutureProvider<PmTilesTileProvider?>(
  (ref) async {
    final tilePath = await ref.watch(offlineTilePathProvider.future);
    if (tilePath == null) {
      return null;
    }

    return PmTilesTileProvider.fromSource(tilePath);
  },
);
