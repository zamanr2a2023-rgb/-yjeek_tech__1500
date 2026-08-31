import 'dart:convert';

import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/payments/model/wallet_pay_models.dart';

class WalletPayRepository {
  const WalletPayRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// POST /orders/:orderId/payments/wallet-pay/session
  Future<WalletPaySession?> createSession(String orderId) async {
    final response = await _apiClient.postJson(
      '/orders/$orderId/payments/wallet-pay/session',
      const {},
      bearerToken: _token,
    );
    if (!response.ok) return null;
    final data = response.data;
    if (data == null) return null;
    return WalletPaySession.fromJson(data);
  }

  /// POST /orders/:orderId/payments/wallet-pay/confirm
  Future<WalletPayConfirmResult> confirm({
    required String orderId,
    required String paymentMethod,
    required String gatewayRef,
    required Object paymentToken,
  }) async {
    Object tokenPayload = paymentToken;
    if (paymentToken is String) {
      try {
        tokenPayload = jsonDecode(paymentToken);
      } catch (_) {
        tokenPayload = paymentToken;
      }
    } else if (paymentToken is Map) {
      tokenPayload = Map<String, dynamic>.from(paymentToken);
    }

    final response = await _apiClient.postJson(
      '/orders/$orderId/payments/wallet-pay/confirm',
      {
        'paymentMethod': paymentMethod,
        'gatewayRef': gatewayRef,
        'paymentToken': tokenPayload,
      },
      bearerToken: _token,
    );
    return WalletPayConfirmResult(
      ok: response.ok,
      errorMessage: response.ok
          ? null
          : (response.message ?? 'Wallet payment confirmation failed'),
      raw: response.data,
    );
  }
}
