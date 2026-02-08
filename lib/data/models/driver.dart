import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  const Driver({
    required this.id,
    required this.isOnline,
    required this.lat,
    required this.lng,
    required this.lastUpdated,
  });

  final String id;
  final bool isOnline;
  final double lat;
  final double lng;
  final DateTime lastUpdated;

  factory Driver.fromJson(Map<String, dynamic> json, String id) {
    final timestamp = json['lastUpdated'] as Timestamp?;
    return Driver(
      id: id,
      isOnline: json['isOnline'] as bool? ?? false,
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      lastUpdated: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOnline': isOnline,
      'lat': lat,
      'lng': lng,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
