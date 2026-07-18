import 'package:shared_preferences/shared_preferences.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLoggedIn = 'logged_in';
  static const _keyPhone = 'phone';
  static const _keyToken = 'auth_token';

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    appLogger.i('StorageService ready');
    return StorageService(prefs);
  }

  bool get isLoggedIn => _prefs.getBool(_keyLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) => _prefs.setBool(_keyLoggedIn, value);

  String? get phone => _prefs.getString(_keyPhone);

  Future<void> savePhone(String value) => _prefs.setString(_keyPhone, value);

  String? get token => _prefs.getString(_keyToken);

  Future<void> saveToken(String value) => _prefs.setString(_keyToken, value);

  Future<void> clearSession() async {
    await _prefs.remove(_keyLoggedIn);
    await _prefs.remove(_keyPhone);
    await _prefs.remove(_keyToken);
  }

  bool get hasSession => isLoggedIn && (token?.isNotEmpty ?? false);
}
