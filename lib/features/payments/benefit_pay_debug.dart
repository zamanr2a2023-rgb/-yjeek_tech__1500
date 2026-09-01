import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';

/// DEBUG-only BenefitPay Wallet / native-session tracing. No-op in release builds.
abstract final class BenefitPayDebug {
  static const _logTag = 'BenefitPayDebug';

  static const _sensitiveKeys = <String>{
    'secretkey',
    'secret_key',
    'secret',
    'secure_hash',
    'securehash',
    'hashedstring',
    'password',
    'token',
    'apikey',
    'api_key',
    'authorization',
    'appid',
    'merchantid',
    'merchant_id',
    'clientid',
    'client_id',
    'resourcekey',
    'tranportalpassword',
  };

  static void log(String message) {
    if (!kDebugMode) return;
    debugPrint('[$_logTag] $message');
    appLogger.d('[$_logTag] $message');
  }

  static void logNativeSessionRequest(String orderId) {
    log('native-session request orderId=$orderId');
  }

  static void logNativeSessionResponse(String orderId, ApiResponse response) {
    if (!kDebugMode) return;
    log(
      'native-session response orderId=$orderId '
      'http=${response.statusCode} ok=${response.ok} '
      'message=${response.message ?? "—"} '
      'safeFields=${sanitizeMap(response.data)}',
    );
  }

  static void logConfirmRequest({
    required String orderId,
    required String paymentMethod,
    String? gatewayRef,
  }) {
    log(
      'confirm request orderId=$orderId paymentMethod=$paymentMethod '
      'gatewayRef=${gatewayRef ?? "—"}',
    );
  }

  static void logConfirmResponse(String orderId, ApiResponse response) {
    if (!kDebugMode) return;
    log(
      'confirm response orderId=$orderId '
      'http=${response.statusCode} ok=${response.ok} '
      'message=${response.message ?? "—"} '
      'safeFields=${sanitizeMap(response.data)}',
    );
  }

  static void logNativeLaunch({required bool available, String? gatewayRef}) {
    log(
      'native launch available=$available gatewayRef=${gatewayRef ?? "—"}',
    );
  }

  static void logNativeResult({
    required String status,
    String? referenceId,
    String? amount,
    String? message,
  }) {
    log(
      'native result status=$status referenceId=${referenceId ?? "—"} '
      'amount=${amount ?? "—"} message=${message ?? "—"}',
    );
  }

  static void logAppResume({required String phase, String? orderId}) {
    log('app resume phase=$phase orderId=${orderId ?? "—"}');
  }

  static void logDeepLinkOrReturn(String label, String? raw) {
    if (!kDebugMode) return;
    final masked = maskUrl(raw);
    log('$label url=$masked');
  }

  static Map<String, dynamic>? sanitizeMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) return null;
    final out = <String, dynamic>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      if (_isSensitiveKey(key)) continue;
      final value = entry.value;
      if (value is Map) {
        out[key] = sanitizeMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        out[key] = 'list(${value.length})';
      } else {
        out[key] = value;
      }
    }
    return out.isEmpty ? null : out;
  }

  static String? extractErrorCode(Map<String, dynamic>? json) {
    if (json == null) return null;
    final error = json['error'];
    if (error is Map) {
      final code = error['code'] ?? error['statusCode'];
      if (code != null) return code.toString();
    }
    final code = json['code'];
    if (code != null) return code.toString();
    return null;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return _sensitiveKeys.contains(normalized);
  }

  static String maskUrl(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return '—';
    final uri = Uri.tryParse(text);
    if (uri == null) return _maskGeneric(text);
    final maskedQuery = <String, String>{};
    for (final entry in uri.queryParameters.entries) {
      final k = entry.key.toLowerCase();
      if (_sensitiveKeys.contains(k) ||
          k.contains('secret') ||
          k.contains('hash') ||
          k.contains('token')) {
        maskedQuery[entry.key] = '***';
      } else {
        maskedQuery[entry.key] = entry.value;
      }
    }
    return uri.replace(queryParameters: maskedQuery).toString();
  }

  static String _maskGeneric(String text) {
    if (text.length <= 8) return '***';
    return '${text.substring(0, 4)}…${text.substring(text.length - 4)}';
  }

  static Future<void> showFailureDiagnostics(
    BuildContext context,
    BenefitPayFailureDiagnostic diagnostic,
  ) async {
    if (!kDebugMode || !context.mounted) return;

    final copyText = diagnostic.copyText;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'BenefitPay debug',
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _DiagRow(label: 'Order ID', value: diagnostic.orderId),
                _DiagRow(
                  label: 'Debug ID',
                  value: diagnostic.debugId ?? '—',
                ),
                _DiagRow(
                  label: 'Error code',
                  value: diagnostic.errorCode ?? '—',
                ),
                _DiagRow(
                  label: 'Error message',
                  value: diagnostic.errorMessage ?? '—',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: copyText));
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('BenefitPay debug info copied'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BenefitPayFailureDiagnostic {
  const BenefitPayFailureDiagnostic({
    required this.orderId,
    this.debugId,
    this.errorCode,
    this.errorMessage,
  });

  final String orderId;
  final String? debugId;
  final String? errorCode;
  final String? errorMessage;

  String get copyText => [
    'orderId=$orderId',
    'debugId=${debugId ?? "—"}',
    'errorCode=${errorCode ?? "—"}',
    'errorMessage=${errorMessage ?? "—"}',
  ].join('\n');
}

class _DiagRow extends StatelessWidget {
  const _DiagRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
