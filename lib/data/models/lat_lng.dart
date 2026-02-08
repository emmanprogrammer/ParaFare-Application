import 'package:cloud_firestore/cloud_firestore.dart';

class LatLngData {
  const LatLngData({required this.lat, required this.lng});

  final double lat;
  final double lng;

  factory LatLngData.fromJson(Map<String, dynamic> json) {
    return LatLngData(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  factory LatLngData.fromGeoPoint(GeoPoint point) {
    return LatLngData(lat: point.latitude, lng: point.longitude);
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
