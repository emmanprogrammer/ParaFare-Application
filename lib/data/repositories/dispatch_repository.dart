import '../models/ride_request.dart';

/// Repository contract for dispatch operations.
///
/// Keeping this interface clean allows swapping Firebase for another backend
/// while preserving app-layer logic.
abstract class DispatchRepository {
  Future<RideRequest> createRideRequest({
    required String passengerId,
    required double pickupLat,
    required double pickupLng,
  });

  Stream<RideRequest?> listenForRideRequest(String requestId);

  Future<void> updateRideStatus({
    required String requestId,
    required String status,
  });

  /// Placeholder for future matching engines (zone-based, pricing tiers, etc.).
  Stream<RideRequest> listenForIncomingRequests();
}
