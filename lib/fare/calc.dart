import 'dart:math';

class FareBreakdown {
  const FareBreakdown({
    required this.distanceKm,
    required this.baseFare,
    required this.discountAmount,
    required this.manualAdjustment,
    required this.finalFare,
  });

  final double distanceKm;
  final double baseFare;
  final double discountAmount;
  final double manualAdjustment;
  final double finalFare;
}

/// Mirrors hardware fare behavior for continuity with the device prototype.
class FareCalculator {
  const FareCalculator({
    this.minFare = 10,
    this.maxFare = 100,
  });

  final double minFare;
  final double maxFare;

  FareBreakdown calculate({
    required double distanceKm,
    required bool applyDiscount,
    required double manualAdjustment,
  }) {
    final baseFare = _calculateBaseFare(distanceKm);
    final rawDiscount = applyDiscount ? baseFare * 0.2 : 0;
    final afterDiscount = max(minFare, baseFare - rawDiscount);
    final withAdjustment = afterDiscount + manualAdjustment;
    final finalFare = withAdjustment.clamp(minFare, maxFare).toDouble();

    return FareBreakdown(
      distanceKm: distanceKm,
      baseFare: baseFare,
      discountAmount: applyDiscount ? (baseFare - afterDiscount) : 0,
      manualAdjustment: manualAdjustment,
      finalFare: finalFare,
    );
  }

  double _calculateBaseFare(double distanceKm) {
    if (distanceKm <= 4) {
      return 15;
    }
    return 15 + (distanceKm - 4).ceilToDouble();
  }
}
