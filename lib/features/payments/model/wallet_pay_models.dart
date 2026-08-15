class WalletPaySession {
  const WalletPaySession({
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.currency,
    required this.countryCode,
    required this.paymentMethod,
    required this.gatewayRef,
    required this.merchantName,
    this.applePay,
    this.googlePay,
  });

  final String orderId;
  final String orderNumber;
  final num amount;
  final String currency;
  final String countryCode;
  final String paymentMethod;
  final String gatewayRef;
  final String merchantName;
  final ApplePaySessionConfig? applePay;
  final GooglePaySessionConfig? googlePay;

  factory WalletPaySession.fromJson(Map<String, dynamic> json) {
    return WalletPaySession(
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse('${json['amount']}') ?? 0,
      currency: json['currency']?.toString() ?? 'BHD',
      countryCode: json['countryCode']?.toString() ?? 'BH',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      gatewayRef: json['gatewayRef']?.toString() ?? '',
      merchantName: json['merchantName']?.toString() ?? 'Yjeek',
      applePay: json['applePay'] is Map
          ? ApplePaySessionConfig.fromJson(
              Map<String, dynamic>.from(json['applePay'] as Map),
            )
          : null,
      googlePay: json['googlePay'] is Map
          ? GooglePaySessionConfig.fromJson(
              Map<String, dynamic>.from(json['googlePay'] as Map),
            )
          : null,
    );
  }
}

class ApplePaySessionConfig {
  const ApplePaySessionConfig({
    this.merchantId,
    this.merchantName,
    this.countryCode,
    this.currencyCode,
  });

  final String? merchantId;
  final String? merchantName;
  final String? countryCode;
  final String? currencyCode;

  factory ApplePaySessionConfig.fromJson(Map<String, dynamic> json) {
    return ApplePaySessionConfig(
      merchantId: json['merchantId']?.toString(),
      merchantName: json['merchantName']?.toString(),
      countryCode: json['countryCode']?.toString(),
      currencyCode: json['currencyCode']?.toString(),
    );
  }
}

class GooglePaySessionConfig {
  const GooglePaySessionConfig({
    this.merchantId,
    this.merchantName,
    this.environment,
    this.protocolVersion,
    this.publicKey,
    this.allowedCardNetworks = const ['VISA', 'MASTERCARD'],
    this.allowedAuthMethods = const ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
  });

  final String? merchantId;
  final String? merchantName;
  final String? environment;
  final String? protocolVersion;
  /// ECv2 public key only — never a private key.
  final String? publicKey;
  final List<String> allowedCardNetworks;
  final List<String> allowedAuthMethods;

  factory GooglePaySessionConfig.fromJson(Map<String, dynamic> json) {
    List<String> listOf(dynamic raw) {
      if (raw is! List) return const [];
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }

    return GooglePaySessionConfig(
      merchantId: json['merchantId']?.toString(),
      merchantName: json['merchantName']?.toString(),
      environment: json['environment']?.toString(),
      protocolVersion: json['protocolVersion']?.toString(),
      publicKey: json['publicKey']?.toString(),
      allowedCardNetworks: listOf(json['allowedCardNetworks']).isEmpty
          ? const ['VISA', 'MASTERCARD']
          : listOf(json['allowedCardNetworks']),
      allowedAuthMethods: listOf(json['allowedAuthMethods']).isEmpty
          ? const ['PAN_ONLY', 'CRYPTOGRAM_3DS']
          : listOf(json['allowedAuthMethods']),
    );
  }
}

class WalletPayConfirmResult {
  const WalletPayConfirmResult({
    required this.ok,
    this.errorMessage,
    this.raw,
  });

  final bool ok;
  final String? errorMessage;
  final Map<String, dynamic>? raw;
}
