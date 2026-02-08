import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'map_providers.dart';

class MapView extends ConsumerWidget {
  const MapView({
    super.key,
    this.onTap,
    this.pickupLocation,
  });

  final void Function(LatLng location)? onTap;
  final LatLng? pickupLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationStreamProvider);

    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(6.1164, 125.1716),
        initialZoom: 14,
        onTap: onTap == null ? null : (_, point) => onTap!(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.parafare.app',
          // Future extension: swap to offline tile cache provider here.
        ),
        MarkerLayer(
          markers: [
            if (pickupLocation != null)
              Marker(
                point: pickupLocation!,
                child: const Icon(Icons.place, color: Colors.red, size: 32),
              ),
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
