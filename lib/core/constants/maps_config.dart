/// Google Maps configuration for Yjeek.
///
/// Enable these APIs on the Google Cloud key:
/// - Maps SDK for Android
/// - Maps SDK for iOS
/// - Maps Static API (checkout / address previews)
abstract final class MapsConfig {
  static const apiKey = 'AIzaSyC7BXis0DYkbNBdzeXQV6VWPPcSj6aL-PM';

  /// Default camera when GPS is unavailable (Seef / Manama, Bahrain).
  static const defaultLat = 26.2361;
  static const defaultLng = 50.5358;
  static const defaultZoom = 15.0;

  static String staticMapUrl({
    required double latitude,
    required double longitude,
    int width = 640,
    int height = 240,
    int zoom = 15,
  }) {
    final w = width.clamp(1, 640);
    final h = height.clamp(1, 640);
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$latitude,$longitude'
        '&zoom=$zoom'
        '&size=${w}x$h'
        '&scale=2'
        '&maptype=roadmap'
        '&markers=color:0xE53935%7C$latitude,$longitude'
        '&key=$apiKey';
  }
}
