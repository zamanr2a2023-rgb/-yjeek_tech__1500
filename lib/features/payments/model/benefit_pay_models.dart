/// Result of opening BenefitPay Web Checkout (before server confirm).
enum BenefitPayCheckoutOutcome { success, error, closed }

class BenefitPayCheckoutResult {
  const BenefitPayCheckoutResult({
    required this.outcome,
    this.message,
    this.raw,
  });

  final BenefitPayCheckoutOutcome outcome;
  final String? message;
  final Map<String, dynamic>? raw;

  bool get isSuccess => outcome == BenefitPayCheckoutOutcome.success;
}

/// Server-signed FOO / goSell payload from POST /payments/initiate.
class BenefitPaySdkPayload {
  const BenefitPaySdkPayload({
    required this.merchantId,
    required this.appId,
    required this.transactionAmount,
    required this.transactionCurrency,
    required this.referenceNumber,
    required this.secureHash,
    this.hashedString,
    this.showResult = '0',
    this.hideMobileQr = '0',
    this.qrTimeoutMs,
  });

  final String merchantId;
  final String appId;
  final String transactionAmount;
  final String transactionCurrency;
  final String referenceNumber;
  final String secureHash;
  final String? hashedString;
  final String showResult;
  final String hideMobileQr;
  final int? qrTimeoutMs;

  factory BenefitPaySdkPayload.fromJson(Map<String, dynamic> json) {
    String str(dynamic v, [String fallback = '']) =>
        v == null ? fallback : v.toString();

    return BenefitPaySdkPayload(
      merchantId: str(json['merchantId']),
      appId: str(json['appId']),
      transactionAmount: str(json['transactionAmount']),
      transactionCurrency: str(json['transactionCurrency'], 'BHD'),
      referenceNumber: str(json['referenceNumber']),
      secureHash: str(json['secure_hash'] ?? json['secureHash']),
      hashedString: json['hashedString']?.toString(),
      showResult: str(json['showResult'], '0'),
      hideMobileQr: str(json['hideMobileQR'] ?? json['hideMobileQr'], '0'),
      qrTimeoutMs: json['qr_timeout'] is num
          ? (json['qr_timeout'] as num).toInt()
          : int.tryParse(json['qr_timeout']?.toString() ?? ''),
    );
  }

  bool get isComplete =>
      merchantId.isNotEmpty &&
      appId.isNotEmpty &&
      transactionAmount.isNotEmpty &&
      referenceNumber.isNotEmpty &&
      secureHash.isNotEmpty;

  Map<String, dynamic> toRequestData() => {
        'merchantId': merchantId,
        'appId': appId,
        'transactionAmount': transactionAmount,
        'transactionCurrency': transactionCurrency,
        'referenceNumber': referenceNumber,
        'secure_hash': secureHash,
        if (hashedString != null && hashedString!.isNotEmpty)
          'hashedString': hashedString,
        'showResult': showResult,
        'hideMobileQR': hideMobileQr,
        if (qrTimeoutMs != null) 'qr_timeout': qrTimeoutMs,
      };
}

class PaymentInitiateResult {
  const PaymentInitiateResult({
    this.ok = false,
    this.gatewayRef,
    this.sdkPayload,
    this.verificationConfigured = false,
    this.errorMessage,
    this.raw,
  });

  final bool ok;
  final String? gatewayRef;
  final BenefitPaySdkPayload? sdkPayload;
  final bool verificationConfigured;
  final String? errorMessage;
  final Map<String, dynamic>? raw;
}

class PaymentConfirmResult {
  const PaymentConfirmResult({
    required this.ok,
    this.errorMessage,
    this.raw,
  });

  final bool ok;
  final String? errorMessage;
  final Map<String, dynamic>? raw;
}

num? parseMoney(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString().replaceAll(',', '').trim());
}
