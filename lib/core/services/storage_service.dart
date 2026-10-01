import 'package:shared_preferences/shared_preferences.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLoggedIn = 'logged_in';
  static const _keyPhone = 'phone';
  static const _keyToken = 'auth_token';
  static const _keyLanguage = 'language_code';
  static const _keyRetailGridView = 'retail_category_grid_view';
  static const _keyResumeLocation = 'resume_location';
  static const _keyDeliveryLocKind = 'delivery_loc_kind';
  static const _keyDeliveryLocLat = 'delivery_loc_lat';
  static const _keyDeliveryLocLng = 'delivery_loc_lng';
  static const _keyDeliveryLocTitle = 'delivery_loc_title';
  static const _keyDeliveryLocSubtitle = 'delivery_loc_subtitle';
  static const _keyDeliveryLocAddressId = 'delivery_loc_address_id';

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

  String? get languageCode => _prefs.getString(_keyLanguage);

  Future<void> saveLanguageCode(String value) =>
      _prefs.setString(_keyLanguage, value);

  /// Customer preferred grid/list on Fashion/Flowers-style category pages.
  bool get retailCategoryGridView => _prefs.getBool(_keyRetailGridView) ?? true;

  Future<void> setRetailCategoryGridView(bool isGrid) =>
      _prefs.setBool(_keyRetailGridView, isGrid);

  /// Last in-app screen, so a later launch can reopen it instead of the splash.
  String? get resumeLocation {
    final value = _prefs.getString(_keyResumeLocation)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> setResumeLocation(String value) =>
      _prefs.setString(_keyResumeLocation, value);

  Future<void> clearSession() async {
    await _prefs.remove(_keyLoggedIn);
    await _prefs.remove(_keyPhone);
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyResumeLocation);
  }

  bool get hasSession => isLoggedIn && (token?.isNotEmpty ?? false);

  String? readString(String key) => _prefs.getString(key);

  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> saveDeliveryLocationCache({
    required String kind,
    required double latitude,
    required double longitude,
    required String displayTitle,
    String? displaySubtitle,
    String? addressId,
  }) async {
    await _prefs.setString(_keyDeliveryLocKind, kind);
    await _prefs.setDouble(_keyDeliveryLocLat, latitude);
    await _prefs.setDouble(_keyDeliveryLocLng, longitude);
    await _prefs.setString(_keyDeliveryLocTitle, displayTitle);
    if (displaySubtitle != null && displaySubtitle.isNotEmpty) {
      await _prefs.setString(_keyDeliveryLocSubtitle, displaySubtitle);
    } else {
      await _prefs.remove(_keyDeliveryLocSubtitle);
    }
    if (addressId != null && addressId.isNotEmpty) {
      await _prefs.setString(_keyDeliveryLocAddressId, addressId);
    } else {
      await _prefs.remove(_keyDeliveryLocAddressId);
    }
  }

  DeliveryLocationCache? loadDeliveryLocationCache() {
    final kind = _prefs.getString(_keyDeliveryLocKind);
    final lat = _prefs.getDouble(_keyDeliveryLocLat);
    final lng = _prefs.getDouble(_keyDeliveryLocLng);
    final title = _prefs.getString(_keyDeliveryLocTitle);
    if (kind == null || lat == null || lng == null) return null;
    return DeliveryLocationCache(
      kind: kind,
      latitude: lat,
      longitude: lng,
      displayTitle: title ?? '',
      displaySubtitle: _prefs.getString(_keyDeliveryLocSubtitle),
      addressId: _prefs.getString(_keyDeliveryLocAddressId),
    );
  }
}

class DeliveryLocationCache {
  const DeliveryLocationCache({
    required this.kind,
    required this.latitude,
    required this.longitude,
    required this.displayTitle,
    this.displaySubtitle,
    this.addressId,
  });

  final String kind;
  final double latitude;
  final double longitude;
  final String displayTitle;
  final String? displaySubtitle;
  final String? addressId;
}
