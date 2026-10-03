/// Global API configuration for the Yjeek customer app.
///
/// Physical phone over USB: run `adb reverse tcp:3000 tcp:3000` so the
/// device's `127.0.0.1:3000` tunnels to this PC's Yjeek backend.
abstract final class ApiConstants {
  /// Android emulator → host machine local yjeek_backend (`npm run dev`).
  /// Physical USB: use `127.0.0.1` + `adb reverse tcp:3000 tcp:3000`.
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  // static const String baseUrl = 'http://127.0.0.1:3000/api/v1';
  static const String baseUrl = 'https://api.yjeektech.com/api/v1';
  // static const String baseUrl = 'http://103.208.183.248:3000/api/v1';
  // static const String baseUrl = 'http://103.208.183.250:3000/api/v1';
  // static const String baseUrl = 'http://192.168.10.251:3000/api/v1';

  /// Local / private / explicitly UAT-named hosts (not production api.yjeektech.com).
  static bool get isLikelyUatBackend {
    final u = baseUrl.toLowerCase();
    return u.contains('localhost') ||
        u.contains('127.0.0.1') ||
        u.contains('10.0.2.2') ||
        u.contains('192.168.') ||
        u.contains('uat') ||
        u.contains('staging') ||
        u.contains(':3000');
  }
}
