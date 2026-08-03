import 'package:geolocator/geolocator.dart';

/// Device GPS helpers for delivery location (permission + current position).
class LocationService {
  const LocationService();

  /// Requests when-in-use location permission if needed.
  /// Returns true when the app may read the current position.
  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Current GPS fix, or null if permission/services unavailable.
  Future<({double lat, double lng})?> currentPosition() async {
    final allowed = await ensurePermission();
    if (!allowed) return null;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return (lat: position.latitude, lng: position.longitude);
    } catch (_) {
      return null;
    }
  }
}
