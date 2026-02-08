import 'package:geolocator/geolocator.dart';

/// Encapsulates location permission + stream logic for reuse across features.
class LocationService {
  Future<bool> ensurePermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.always ||
          requested == LocationPermission.whileInUse;
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    );
  }
}
