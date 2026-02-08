import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_collections.dart';
import '../models/ride_request.dart';
import 'dispatch_repository.dart';

class DispatchRepositoryImpl implements DispatchRepository {
  DispatchRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requestsRef =>
      _firestore.collection(FirestoreCollections.rideRequests);

  @override
  Future<RideRequest> createRideRequest({
    required String passengerId,
    required double pickupLat,
    required double pickupLng,
  }) async {
    final docRef = _requestsRef.doc();
    final request = RideRequest(
      id: docRef.id,
      passengerId: passengerId,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await docRef.set(request.toJson());
    return request;
  }

  @override
  Stream<RideRequest?> listenForRideRequest(String requestId) {
    return _requestsRef.doc(requestId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return RideRequest.fromJson(snapshot.data()!, snapshot.id);
    });
  }

  @override
  Future<void> updateRideStatus({
    required String requestId,
    required String status,
  }) {
    return _requestsRef.doc(requestId).update({'status': status});
  }

  @override
  Stream<RideRequest> listenForIncomingRequests() {
    // TODO: Replace with a geospatial or zone-based query when ready.
    return _requestsRef
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .expand((snapshot) => snapshot.docs)
        .map((doc) => RideRequest.fromJson(doc.data(), doc.id));
  }
}
