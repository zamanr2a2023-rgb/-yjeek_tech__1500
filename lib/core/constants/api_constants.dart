/// Global API configuration for the Yjeek customer app.
///
/// Physical phone over USB: run `adb reverse tcp:3000 tcp:3000` so the
/// device's `127.0.0.1:3000` tunnels to this PC's Yjeek backend.
abstract final class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';
}
