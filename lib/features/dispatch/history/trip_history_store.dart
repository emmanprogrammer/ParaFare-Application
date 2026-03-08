import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CompletedTripRecord {
  const CompletedTripRecord({
    required this.completedAtIso,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.startNodeId,
    required this.endNodeId,
    required this.distanceKm,
    required this.baseFare,
    required this.discountAmount,
    required this.manualAdjustment,
    required this.finalFare,
  });

  final String completedAtIso;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String startNodeId;
  final String endNodeId;
  final double distanceKm;
  final double baseFare;
  final double discountAmount;
  final double manualAdjustment;
  final double finalFare;

  factory CompletedTripRecord.fromJson(Map<String, dynamic> json) {
    return CompletedTripRecord(
      completedAtIso: json['completedAtIso'] as String,
      startLatitude: (json['startLatitude'] as num).toDouble(),
      startLongitude: (json['startLongitude'] as num).toDouble(),
      endLatitude: (json['endLatitude'] as num).toDouble(),
      endLongitude: (json['endLongitude'] as num).toDouble(),
      startNodeId: json['startNodeId'] as String,
      endNodeId: json['endNodeId'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      baseFare: (json['baseFare'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      manualAdjustment: (json['manualAdjustment'] as num).toDouble(),
      finalFare: (json['finalFare'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'completedAtIso': completedAtIso,
        'startLatitude': startLatitude,
        'startLongitude': startLongitude,
        'endLatitude': endLatitude,
        'endLongitude': endLongitude,
        'startNodeId': startNodeId,
        'endNodeId': endNodeId,
        'distanceKm': distanceKm,
        'baseFare': baseFare,
        'discountAmount': discountAmount,
        'manualAdjustment': manualAdjustment,
        'finalFare': finalFare,
      };
}

class TripHistoryStore {
  TripHistoryStore(this._prefs);

  static const _storageKey = 'completed_trips_v1';
  final SharedPreferences _prefs;

  Future<void> saveTrip(CompletedTripRecord record) async {
    final all = await loadTrips();
    final updated = [record, ...all].take(100).toList(growable: false);
    await _prefs.setString(
      _storageKey,
      jsonEncode(updated.map((trip) => trip.toJson()).toList(growable: false)),
    );
  }

  Future<List<CompletedTripRecord>> loadTrips() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const <CompletedTripRecord>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => CompletedTripRecord.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }
}
