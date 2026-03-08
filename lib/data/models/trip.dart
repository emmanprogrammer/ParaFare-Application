import 'package:cloud_firestore/cloud_firestore.dart';

import 'lat_lng.dart';

class Trip {
  const Trip({
    required this.id,
    required this.driverId,
    required this.passengerId,
    required this.startLatLng,
    required this.endLatLng,
    required this.startedAt,
    required this.endedAt,
  });

  final String id;
  final String driverId;
  final String passengerId;
  final LatLngData startLatLng;
  final LatLngData endLatLng;
  final DateTime? startedAt;
  final DateTime? endedAt;

  factory Trip.fromJson(Map<String, dynamic> json, String id) {
    final startedAt = json['startedAt'] as Timestamp?;
    final endedAt = json['endedAt'] as Timestamp?;
    return Trip(
      id: id,
      driverId: json['driverId'] as String? ?? '',
      passengerId: json['passengerId'] as String? ?? '',
      startLatLng: LatLngData.fromJson(
        Map<String, dynamic>.from(json['startLatLng'] as Map? ?? {}),
      ),
      endLatLng: LatLngData.fromJson(
        Map<String, dynamic>.from(json['endLatLng'] as Map? ?? {}),
      ),
      startedAt: startedAt?.toDate(),
      endedAt: endedAt?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'passengerId': passengerId,
      'startLatLng': startLatLng.toJson(),
      'endLatLng': endLatLng.toJson(),
      'startedAt': startedAt == null ? null : Timestamp.fromDate(startedAt!),
      'endedAt': endedAt == null ? null : Timestamp.fromDate(endedAt!),
    };
  }
}
