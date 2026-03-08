import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:parafare_application/core/providers.dart';

enum MapTileMode { online, offline }

class MapTileConfig {
  const MapTileConfig({
    required this.mode,
    required this.urlTemplate,
    required this.description,
  });

  final MapTileMode mode;
  final String urlTemplate;
  final String description;
}

final mapTileModeProvider = StateProvider<MapTileMode>((ref) {
  return MapTileMode.online;
});

final mapTileConfigProvider = Provider<MapTileConfig>((ref) {
  final mode = ref.watch(mapTileModeProvider);
  switch (mode) {
    case MapTileMode.online:
      return const MapTileConfig(
        mode: MapTileMode.online,
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        description: 'Online OpenStreetMap tiles',
      );
    case MapTileMode.offline:
      return const MapTileConfig(
        mode: MapTileMode.offline,
        // Local tile server or on-device tile host placeholder.
        // Replace with your chosen offline provider endpoint.
        urlTemplate: 'http://127.0.0.1:8080/{z}/{x}/{y}.png',
        description: 'Offline/local tile source (configure your tile host)',
      );
  }
});

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
