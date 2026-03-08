import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'state.dart';

class MapView extends ConsumerWidget {
  const MapView({
    super.key,
    this.onTap,
    this.pickupLocation,
    this.showLiveLocation = true,
    this.routePoints = const [],
    this.extraMarkers = const [],
  });

  final void Function(LatLng location)? onTap;
  final LatLng? pickupLocation;
  final bool showLiveLocation;
  final List<LatLng> routePoints;
  final List<Marker> extraMarkers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationStreamProvider);
    final tileConfig = ref.watch(mapTileConfigProvider);

    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(6.1164, 125.1716),
        initialZoom: 14,
        onTap: onTap == null ? null : (_, point) => onTap!(point),
      ),
      children: [
        TileLayer(
          urlTemplate: tileConfig.urlTemplate,
          userAgentPackageName: 'com.parafare.app',
          // Extension point: wire MBTiles/file tile provider for fully offline map packs.
        ),
        if (routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4,
                color: Colors.deepPurple,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (pickupLocation != null)
              Marker(
                point: pickupLocation!,
                child: const Icon(Icons.place, color: Colors.red, size: 32),
              ),
            ...extraMarkers,
            if (showLiveLocation)
              locationAsync.when(
                data: (position) => Marker(
                  point: LatLng(position.latitude, position.longitude),
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                loading: () => null,
                error: (_, __) => null,
              ),
          ].whereType<Marker>().toList(),
        ),
      ],
    );
  }
}
