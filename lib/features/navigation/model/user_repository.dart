import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/navigation/model/kyc_models.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/l10n/app_locales.dart';

class DeliveryCountry {
  const DeliveryCountry({
    required this.code,
    required this.name,
    this.available = true,
  });

  final String code;
  final String name;
  final bool available;

  static const fallback = <DeliveryCountry>[
    DeliveryCountry(code: 'KW', name: 'Kuwait'),
    DeliveryCountry(code: 'SA', name: 'KSA'),
    DeliveryCountry(code: 'BH', name: 'Bahrain'),
    DeliveryCountry(code: 'AE', name: 'UAE'),
    DeliveryCountry(code: 'OM', name: 'Oman'),
    DeliveryCountry(code: 'QA', name: 'Qatar'),
    DeliveryCountry(code: 'JO', name: 'Jordan'),
    DeliveryCountry(code: 'EG', name: 'Egypt'),
    DeliveryCountry(code: 'IQ', name: 'Iraq'),
  ];
}

class AppLanguageOption {
  const AppLanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    this.rtl = false,
  });

  final String code;
  final String name;
  final String nativeName;
  final bool rtl;

  /// Label shown in Language settings (native name preferred).
  String get label => nativeName.isNotEmpty ? nativeName : name;

  static const fallback = <AppLanguageOption>[
    AppLanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
    ),
    AppLanguageOption(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      rtl: true,
    ),
  ];
}

class UserRepository {
  const UserRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /users/me — requires Bearer token from login.
  /// Skips the network call when there is no session (avoids noisy 401s).
  Future<UserMe?> fetchMe() async {
    final token = _token;
    if (token == null || token.isEmpty) return null;

    final response = await _apiClient.getJson(
      '/users/me',
      bearerToken: token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return UserMe.fromJson(data);
  }

  /// GET /users/me/kyc
  Future<KycStatus> fetchKyc() async {
    final token = _token;
    if (token == null || token.isEmpty) return KycStatus.empty;

    final response = await _apiClient.getJson(
      '/users/me/kyc',
      bearerToken: token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return KycStatus.empty;
    return KycStatus.fromJson(data);
  }

  /// POST /uploads?category=… — returns public file URL.
  ///
  /// [category] must match backend public upload categories, e.g.
  /// `support-evidence`, `address-photos`, `avatars`, `documents`.
  Future<String?> uploadFile(
    String filePath, {
    required String category,
    String? filename,
  }) async {
    final encoded = Uri.encodeQueryComponent(category);
    final response = await _apiClient.postMultipartFile(
      '/uploads?category=$encoded',
      filePath: filePath,
      filename: filename,
      bearerToken: _token,
    );
    if (!response.ok) return null;
    final url = response.data?['url'];
    return url is String && url.isNotEmpty ? url : null;
  }

  /// POST /users/me/kyc
  Future<ApiResponse> submitKyc(Map<String, dynamic> body) {
    return _apiClient.postJson(
      '/users/me/kyc',
      body,
      bearerToken: _token,
    );
  }

  /// PATCH /users/me
  Future<ApiResponse> updateProfile(Map<String, dynamic> body) {
    return _apiClient.patchJson(
      '/users/me',
      body,
      bearerToken: _token,
    );
  }

  /// DELETE /users/me
  Future<ApiResponse> deleteAccount({String? reason}) {
    return _apiClient.deleteJson(
      '/users/me',
      bearerToken: _token,
      body: {
        'confirm': true,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }

  /// POST /users/me/phone/request
  Future<ApiResponse> requestPhoneChange({
    required String phone,
    String countryCode = '+973',
  }) {
    return _apiClient.postJson(
      '/users/me/phone/request',
      {
        'phone': phone,
        'countryCode': countryCode,
      },
      bearerToken: _token,
    );
  }

  /// POST /users/me/phone/confirm
  Future<ApiResponse> confirmPhoneChange({
    required String phone,
    required String code,
    String countryCode = '+973',
  }) {
    return _apiClient.postJson(
      '/users/me/phone/confirm',
      {
        'phone': phone,
        'countryCode': countryCode,
        'code': code,
      },
      bearerToken: _token,
    );
  }

  /// GET /content/countries
  Future<List<DeliveryCountry>> fetchDeliveryCountries() async {
    final response = await _apiClient.getJson('/content/countries');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return DeliveryCountry.fallback;
    final rows = data['countries'];
    if (rows is! List) return DeliveryCountry.fallback;
    final out = <DeliveryCountry>[];
    for (final raw in rows) {
      if (raw is! Map<String, dynamic>) continue;
      final code = raw['code']?.toString() ?? '';
      final name = raw['name']?.toString() ?? '';
      if (code.isEmpty || name.isEmpty) continue;
      out.add(
        DeliveryCountry(
          code: code.toUpperCase(),
          name: name,
          available: raw['available'] != false,
        ),
      );
    }
    return out.isEmpty ? DeliveryCountry.fallback : out;
  }

  /// GET /content/languages — admin localization settings (customer-facing).
  Future<List<AppLanguageOption>> fetchLanguages() async {
    final response = await _apiClient.getJson('/content/languages');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return AppLanguageOption.fallback;
    final rows = data['languages'];
    if (rows is! List) return AppLanguageOption.fallback;
    final out = <AppLanguageOption>[];
    for (final raw in rows) {
      if (raw is! Map<String, dynamic>) continue;
      final code = raw['code']?.toString().trim().toLowerCase() ?? '';
      if (code.isEmpty) continue;
      final name = raw['name']?.toString() ?? code.toUpperCase();
      final nativeName = raw['nativeName']?.toString() ?? name;
      out.add(
        AppLanguageOption(
          code: code,
          name: name,
          nativeName: nativeName,
          rtl: raw['rtl'] == true || code == 'ar',
        ),
      );
    }
    // App currently ships EN/AR UI strings only.
    final supported = out.where((l) => AppLocales.isSupported(l.code)).toList();
    return supported.isEmpty ? AppLanguageOption.fallback : supported;
  }
}
