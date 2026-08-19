import 'package:flutter/services.dart';

/// Result from the native BenefitPay in-app SDK (app-to-app flow).
class BenefitPayNativeResult {
  const BenefitPayNativeResult({
    required this.status,
    this.referenceId,
    this.amount,
    this.message,
  });

  final String status;
  final String? referenceId;
  final String? amount;
  final String? message;

  bool get isSuccess => status == 'success';
  bool get isCancelled => status == 'cancelled';
  bool get isFailed => status == 'failed';
  bool get isUnavailable => status == 'unavailable';

  factory BenefitPayNativeResult.fromMap(Map<dynamic, dynamic>? raw) {
    final map = raw ?? const <dynamic, dynamic>{};
    return BenefitPayNativeResult(
      status: map['status']?.toString() ?? 'failed',
      referenceId: map['referenceId']?.toString(),
      amount: map['amount']?.toString(),
      message: map['message']?.toString(),
    );
  }
}

/// Session payload from POST …/payments/benefitpay/native-session.
class BenefitPayNativeSessionResult {
  const BenefitPayNativeSessionResult({
    this.ok = false,
    this.session,
    this.errorMessage,
  });

  final bool ok;
  final BenefitPayNativeSession? session;
  final String? errorMessage;
}

/// Session payload from POST …/payments/benefitpay/native-session.
class BenefitPayNativeSession {
  const BenefitPayNativeSession({
    required this.gatewayRef,
    required this.appId,
    required this.merchantId,
    required this.secretKey,
    required this.referenceId,
    required this.amount,
    required this.currencyCode,
    required this.merchantCategoryCode,
    required this.merchantName,
    required this.merchantCity,
    required this.countryCode,
    required this.callBackTag,
  });

  final String gatewayRef;
  final String appId;
  final String merchantId;
  final String secretKey;
  final String referenceId;
  final String amount;
  final String currencyCode;
  final String merchantCategoryCode;
  final String merchantName;
  final String merchantCity;
  final String countryCode;
  final String callBackTag;

  factory BenefitPayNativeSession.fromJson(Map<String, dynamic> json) {
    return BenefitPayNativeSession(
      gatewayRef: json['gatewayRef']?.toString() ?? '',
      appId: json['appId']?.toString() ?? '',
      merchantId: json['merchantId']?.toString() ?? '',
      secretKey: json['secretKey']?.toString() ?? '',
      referenceId: json['referenceId']?.toString() ??
          json['gatewayRef']?.toString() ??
          '',
      amount: json['amount']?.toString() ?? '',
      currencyCode: json['currencyCode']?.toString() ?? '048',
      merchantCategoryCode: json['merchantCategoryCode']?.toString() ?? '',
      merchantName: json['merchantName']?.toString() ?? '',
      merchantCity: json['merchantCity']?.toString() ?? '',
      countryCode: json['countryCode']?.toString() ?? 'BH',
      callBackTag: json['callBackTag']?.toString() ?? 'yjeekbp',
    );
  }

  Map<String, dynamic> toNativeConfig() => {
        'appId': appId,
        'merchantId': merchantId,
        'secretKey': secretKey,
        'referenceId': referenceId,
        'amount': amount,
        'currencyCode': currencyCode,
        'merchantCategoryCode': merchantCategoryCode,
        'merchantName': merchantName,
        'merchantCity': merchantCity,
        'countryCode': countryCode,
        'callBackTag': callBackTag,
      };
}

/// Flutter bridge to the official Benefit In-App SDK on Android/iOS.
abstract final class BenefitPayNative {
  static const MethodChannel _channel =
      MethodChannel('bh.yjeek.customer/benefit_pay');

  static Future<bool> isAvailable() async {
    try {
      final value = await _channel.invokeMethod<bool>('isAvailable');
      return value == true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static Future<BenefitPayNativeResult> pay(
    BenefitPayNativeSession session,
  ) async {
    try {
      final raw = await _channel.invokeMethod<dynamic>(
        'pay',
        session.toNativeConfig(),
      );
      if (raw is Map) {
        return BenefitPayNativeResult.fromMap(raw);
      }
      return const BenefitPayNativeResult(
        status: 'failed',
        message: 'Invalid native payment response',
      );
    } on PlatformException catch (e) {
      return BenefitPayNativeResult(
        status: 'failed',
        message: e.message ?? e.code,
      );
    } on MissingPluginException {
      return const BenefitPayNativeResult(
        status: 'unavailable',
        message: 'BenefitPay is not supported on this platform',
      );
    }
  }
}
