import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequest {
  const RideRequest({
    required this.id,
    required this.passengerId,
    required this.pickupLat,
    required this.pickupLng,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String passengerId;
  final double pickupLat;
  final double pickupLng;
  final String status;
  final DateTime createdAt;

  factory RideRequest.fromJson(Map<String, dynamic> json, String id) {
    final timestamp = json['createdAt'] as Timestamp?;
    return RideRequest(
      id: id,
      passengerId: json['passengerId'] as String? ?? '',
      pickupLat: (json['pickupLat'] as num?)?.toDouble() ?? 0,
      pickupLng: (json['pickupLng'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passengerId': passengerId,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
