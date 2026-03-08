class DriverProfile {
  const DriverProfile({
    required this.name,
    required this.tricycleId,
    required this.seatCount,
  });

  final String name;
  final String tricycleId;
  final int seatCount;

  factory DriverProfile.fromJson(Map<String, dynamic> json) => DriverProfile(
        name: json['name'] as String,
        tricycleId: json['tricycleId'] as String,
        seatCount: json['seatCount'] as int,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'tricycleId': tricycleId,
        'seatCount': seatCount,
      };
}

class RideRecord {
  const RideRecord({
    required this.id,
    required this.slotIndex,
    required this.originLabel,
    required this.destinationLabel,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.baseFare,
    required this.finalFare,
    required this.startedAtIso,
    this.completedAtIso,
    this.isCompleted = false,
  });

  final String id;
  final int slotIndex;
  final String originLabel;
  final String destinationLabel;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final double distanceKm;
  final int estimatedMinutes;
  final double baseFare;
  final double finalFare;
  final String startedAtIso;
  final String? completedAtIso;
  final bool isCompleted;

  RideRecord copyWith({
    double? finalFare,
    String? completedAtIso,
    bool? isCompleted,
  }) {
    return RideRecord(
      id: id,
      slotIndex: slotIndex,
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      distanceKm: distanceKm,
      estimatedMinutes: estimatedMinutes,
      baseFare: baseFare,
      finalFare: finalFare ?? this.finalFare,
      startedAtIso: startedAtIso,
      completedAtIso: completedAtIso ?? this.completedAtIso,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory RideRecord.fromJson(Map<String, dynamic> json) => RideRecord(
        id: json['id'] as String,
        slotIndex: json['slotIndex'] as int,
        originLabel: json['originLabel'] as String,
        destinationLabel: json['destinationLabel'] as String,
        originLat: (json['originLat'] as num).toDouble(),
        originLng: (json['originLng'] as num).toDouble(),
        destinationLat: (json['destinationLat'] as num).toDouble(),
        destinationLng: (json['destinationLng'] as num).toDouble(),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        estimatedMinutes: json['estimatedMinutes'] as int,
        baseFare: (json['baseFare'] as num).toDouble(),
        finalFare: (json['finalFare'] as num).toDouble(),
        startedAtIso: json['startedAtIso'] as String,
        completedAtIso: json['completedAtIso'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slotIndex': slotIndex,
        'originLabel': originLabel,
        'destinationLabel': destinationLabel,
        'originLat': originLat,
        'originLng': originLng,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'distanceKm': distanceKm,
        'estimatedMinutes': estimatedMinutes,
        'baseFare': baseFare,
        'finalFare': finalFare,
        'startedAtIso': startedAtIso,
        'completedAtIso': completedAtIso,
        'isCompleted': isCompleted,
      };
}

class MvpAppData {
  const MvpAppData({
    required this.onboardingComplete,
    this.profile,
    this.activeRides = const {},
    this.completedRides = const [],
  });

  final bool onboardingComplete;
  final DriverProfile? profile;
  final Map<int, RideRecord> activeRides;
  final List<RideRecord> completedRides;

  MvpAppData copyWith({
    bool? onboardingComplete,
    DriverProfile? profile,
    Map<int, RideRecord>? activeRides,
    List<RideRecord>? completedRides,
  }) {
    return MvpAppData(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      profile: profile ?? this.profile,
      activeRides: activeRides ?? this.activeRides,
      completedRides: completedRides ?? this.completedRides,
    );
  }

  factory MvpAppData.fromJson(Map<String, dynamic> json) {
    final activeRaw = Map<String, dynamic>.from(json['activeRides'] as Map? ?? {});
    return MvpAppData(
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      profile: json['profile'] == null
          ? null
          : DriverProfile.fromJson(Map<String, dynamic>.from(json['profile'] as Map)),
      activeRides: {
        for (final entry in activeRaw.entries)
          int.parse(entry.key): RideRecord.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          ),
      },
      completedRides: (json['completedRides'] as List<dynamic>? ?? const [])
          .map((ride) => RideRecord.fromJson(Map<String, dynamic>.from(ride as Map)))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'onboardingComplete': onboardingComplete,
        'profile': profile?.toJson(),
        'activeRides': {
          for (final entry in activeRides.entries)
            entry.key.toString(): entry.value.toJson(),
        },
        'completedRides': completedRides.map((ride) => ride.toJson()).toList(growable: false),
      };
}
