import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';

/// `data.screen` from POST /users/me/age-verification.
/// Unknown means the response had no screen. Callers must not infer an
/// outcome from the error message.
enum AgeVerificationScreen {
  verified,
  under18,
  idAlreadyUsed,
  rejected,
  unknown,
}

AgeVerificationScreen ageVerificationScreenFromApi(Object? raw) {
  switch (raw) {
    case 'verified':
      return AgeVerificationScreen.verified;
    case 'under_18':
      return AgeVerificationScreen.under18;
    case 'id_already_used':
      return AgeVerificationScreen.idAlreadyUsed;
    case 'rejected':
      return AgeVerificationScreen.rejected;
    default:
      return AgeVerificationScreen.unknown;
  }
}

class AgeVerificationStatus {
  const AgeVerificationStatus({
    required this.status,
    required this.canPurchaseAgeRestricted,
    this.rejectCode,
    this.rejectMessage,
  });

  final String status;
  final bool canPurchaseAgeRestricted;
  final String? rejectCode;
  final String? rejectMessage;

  factory AgeVerificationStatus.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return AgeVerificationStatus(
      status: data['status']?.toString() ?? 'NOT_VERIFIED',
      canPurchaseAgeRestricted: data['canPurchaseAgeRestricted'] == true,
      rejectCode: _text(data['rejectCode']),
      rejectMessage: _text(data['rejectMessage']),
    );
  }
}

class AgeVerificationResult {
  const AgeVerificationResult({
    required this.screen,
    this.rejectMessage,
    this.canPurchaseAgeRestricted = false,
  });

  final AgeVerificationScreen screen;
  final String? rejectMessage;
  final bool canPurchaseAgeRestricted;
}

class AgeVerificationRepository {
  const AgeVerificationRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /users/me/age-verification
  Future<AgeVerificationStatus> fetchStatus() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      return const AgeVerificationStatus(
        status: 'NOT_VERIFIED',
        canPurchaseAgeRestricted: false,
      );
    }
    final response = await _apiClient.getJson(
      '/users/me/age-verification',
      bearerToken: token,
    );
    final data = response?['data'];
    if (data is! Map) {
      return const AgeVerificationStatus(
        status: 'NOT_VERIFIED',
        canPurchaseAgeRestricted: false,
      );
    }
    return AgeVerificationStatus.fromJson(Map<String, dynamic>.from(data));
  }

  /// POST /uploads/private/age-verification
  /// Category is AGE_VERIFICATION. Returns the URL stored on the age record.
  Future<String?> uploadIdImage(String filePath, {String? filename}) async {
    final response = await _apiClient.postMultipartFile(
      '/uploads/private/age-verification',
      filePath: filePath,
      filename: filename,
      bearerToken: _token,
    );
    if (!response.ok) return null;
    final url = response.data?['url'];
    return url is String && url.isNotEmpty ? url : null;
  }

  /// POST /users/me/age-verification
  /// Body is `{ idFrontUrl, idBackUrl, consent: true }`.
  /// Outcome is `data.screen` only.
  Future<AgeVerificationResult> submit({
    required String idFrontUrl,
    required String idBackUrl,
    required bool consent,
  }) async {
    final response = await _apiClient.postJson('/users/me/age-verification', {
      'idFrontUrl': idFrontUrl,
      'idBackUrl': idBackUrl,
      'consent': consent,
    }, bearerToken: _token);
    if (!response.ok) {
      return AgeVerificationResult(
        screen: AgeVerificationScreen.unknown,
        rejectMessage: response.message,
      );
    }
    final data = response.data;
    return AgeVerificationResult(
      screen: ageVerificationScreenFromApi(data?['screen']),
      rejectMessage: _text(data?['rejectMessage']),
      canPurchaseAgeRestricted: data?['canPurchaseAgeRestricted'] == true,
    );
  }
}

String? _text(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty || text == 'null') return null;
  return text;
}
