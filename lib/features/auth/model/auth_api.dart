import 'package:yjeek_app/core/network/api_client.dart';

class SendOtpResult {
  const SendOtpResult({
    required this.success,
    this.error,
    this.isNetworkError = false,
    this.devCode,
    this.expiresInSeconds,
  });

  final bool success;
  final String? error;
  final bool isNetworkError;

  /// OTP returned by the dev backend for testing (`data.devCode`).
  final String? devCode;
  final int? expiresInSeconds;
}

class VerifyOtpResult {
  const VerifyOtpResult({
    required this.success,
    this.error,
    this.isNetworkError = false,
    this.token,
  });

  final bool success;
  final String? error;
  final bool isNetworkError;
  final String? token;
}

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  static const _role = 'CUSTOMER';

  /// POST /auth/send-otp — [phone] is local digits (e.g. `33000001`),
  /// [countryCode] like `+973`.
  Future<SendOtpResult> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    final res = await _client.postJson('/auth/send-otp', {
      'phone': phone,
      'countryCode': countryCode,
      'termsAccepted': true,
      'role': _role,
    });
    if (res.ok) {
      return SendOtpResult(
        success: true,
        devCode: res.data?['devCode']?.toString(),
        expiresInSeconds: res.data?['expiresInSeconds'] as int?,
      );
    }
    return SendOtpResult(
      success: false,
      isNetworkError: res.isNetworkError,
      error: res.message ??
          (res.isNetworkError
              ? 'Could not reach the server. Check your connection.'
              : 'Failed to send code. Please try again.'),
    );
  }

  /// POST /auth/resend-otp
  Future<SendOtpResult> resendOtp({
    required String phone,
    required String countryCode,
  }) async {
    final res = await _client.postJson('/auth/resend-otp', {
      'phone': phone,
      'countryCode': countryCode,
    });
    if (res.ok) {
      return SendOtpResult(
        success: true,
        devCode: res.data?['devCode']?.toString(),
        expiresInSeconds: res.data?['expiresInSeconds'] as int?,
      );
    }
    return SendOtpResult(
      success: false,
      isNetworkError: res.isNetworkError,
      error: res.message ??
          (res.isNetworkError
              ? 'Could not reach the server. Check your connection.'
              : 'Failed to resend code. Please try again.'),
    );
  }

  /// POST /auth/verify-otp
  Future<VerifyOtpResult> verifyOtp({
    required String phone,
    required String countryCode,
    required String code,
  }) async {
    final res = await _client.postJson('/auth/verify-otp', {
      'phone': phone,
      'countryCode': countryCode,
      'code': code,
      'role': _role,
    });
    if (res.ok) {
      final data = res.data;
      final token = (data?['token'] ??
              data?['accessToken'] ??
              (data?['tokens'] as Map<String, dynamic>?)?['accessToken'])
          ?.toString();
      return VerifyOtpResult(success: true, token: token);
    }
    return VerifyOtpResult(
      success: false,
      isNetworkError: res.isNetworkError,
      error: res.message ??
          (res.isNetworkError
              ? 'Could not reach the server. Check your connection.'
              : 'Verification failed. Please try again.'),
    );
  }

  /// POST /auth/logout
  Future<bool> logout({required String? bearerToken}) async {
    final res = await _client.postJson(
      '/auth/logout',
      const {},
      bearerToken: bearerToken,
    );
    // Local clear should happen even if the server call fails.
    return res.ok || res.isNetworkError || res.statusCode == 401;
  }
}
