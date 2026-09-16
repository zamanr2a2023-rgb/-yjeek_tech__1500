import 'package:geolocator/geolocator.dart';

/// Outcome of asking for when-in-use location access.
enum LocationPermissionOutcome {
  granted,
  serviceDisabled,
  denied,
  deniedForever,
}

/// Device GPS helpers for delivery location (permission + current position).
class LocationService {
  const LocationService();

  /// Requests when-in-use location permission if needed.
  /// Returns true when the app may read the current position.
  Future<bool> ensurePermission() async {
    final outcome = await requestPermission();
    return outcome == LocationPermissionOutcome.granted;
  }

  /// Explicit permission flow — always tries the OS dialog when possible.
  Future<LocationPermissionOutcome> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionOutcome.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionOutcome.deniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationPermissionOutcome.denied;
    }
    // whileInUse / always / unableToDetermine treated as usable when not denied
    return LocationPermissionOutcome.granted;
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

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
