import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pay/pay.dart';
import 'package:yjeek_app/features/payments/model/wallet_pay_models.dart';

/// Platform availability for native wallet sheets.
bool get supportsApplePayNative =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool get supportsGooglePayNative =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool isApplePayMethod(String methodApi) =>
    methodApi.toUpperCase() == 'APPLE_PAY';

bool isGooglePayMethod(String methodApi) =>
    methodApi.toUpperCase() == 'GOOGLE_PAY';

bool isNativeWalletMethod(String methodApi) =>
    isApplePayMethod(methodApi) || isGooglePayMethod(methodApi);

/// Filter pay-now options by OS capability (checkout list shows all methods).
List<T> filterWalletMethodsForPlatform<T>(
  Iterable<T> items,
  String Function(T) apiOf,
) {
  return items.where((item) {
    final api = apiOf(item).toUpperCase();
    if (api == 'APPLE_PAY') return supportsApplePayNative;
    if (api == 'GOOGLE_PAY') return supportsGooglePayNative;
    return true;
  }).toList();
}

String _amountString(num amount) => amount.toStringAsFixed(3);

Map<String, dynamic> buildApplePayPaymentConfig(WalletPaySession session) {
  final apple = session.applePay;
  return {
    'provider': 'apple_pay',
    'data': {
      'merchantIdentifier': apple?.merchantId ?? '',
      'displayName': apple?.merchantName ?? session.merchantName,
      'merchantCapabilities': ['3DS', 'debit', 'credit'],
      'supportedNetworks': ['visa', 'masterCard', 'amex'],
      'countryCode': apple?.countryCode ?? session.countryCode,
      'currencyCode': apple?.currencyCode ?? session.currency,
      'requiredBillingContactFields': [],
      'requiredShippingContactFields': [],
    },
  };
}

Map<String, dynamic> buildGooglePayPaymentConfig(WalletPaySession session) {
  final g = session.googlePay;
  final publicKey = g?.publicKey ?? '';
  final env = (g?.environment ?? 'TEST').toUpperCase() == 'PRODUCTION'
      ? 'PRODUCTION'
      : 'TEST';
  return {
    'provider': 'google_pay',
    'data': {
      'environment': env,
      'apiVersion': 2,
      'apiVersionMinor': 0,
      'allowedPaymentMethods': [
        {
          'type': 'CARD',
          'parameters': {
            'allowedAuthMethods': g?.allowedAuthMethods ??
                ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
            'allowedCardNetworks':
                g?.allowedCardNetworks ?? ['VISA', 'MASTERCARD'],
          },
          'tokenizationSpecification': {
            'type': 'DIRECT',
            'parameters': {
              'protocolVersion': g?.protocolVersion ?? 'ECv2',
              'publicKey': publicKey,
            },
          },
        },
      ],
      'merchantInfo': {
        'merchantId': g?.merchantId ?? '',
        'merchantName': g?.merchantName ?? session.merchantName,
      },
      'transactionInfo': {
        'totalPriceStatus': 'FINAL',
        'totalPrice': _amountString(session.amount),
        'currencyCode': session.currency,
        'countryCode': session.countryCode,
      },
    },
  };
}

/// Shows native Apple / Google Pay sheet and returns the payment token payload.
Future<Object?> presentNativeWalletSheet(WalletPaySession session) async {
  final method = session.paymentMethod.toUpperCase();
  final paymentItems = [
    PaymentItem(
      label: session.merchantName,
      amount: _amountString(session.amount),
      status: PaymentItemStatus.final_price,
    ),
  ];

  if (method == 'APPLE_PAY') {
    if (!supportsApplePayNative) {
      throw StateError('Apple Pay is only available on iOS');
    }
    if ((session.applePay?.merchantId ?? '').isEmpty) {
      throw StateError('Apple Pay merchantId missing from session');
    }
    final config = PaymentConfiguration.fromJsonString(
      jsonEncode(buildApplePayPaymentConfig(session)),
    );
    final payClient = Pay({PayProvider.apple_pay: config});
    final canPay = await payClient.userCanPay(PayProvider.apple_pay);
    if (!canPay) throw StateError('Apple Pay is not available on this device');
    return payClient.showPaymentSelector(PayProvider.apple_pay, paymentItems);
  }

  if (method == 'GOOGLE_PAY') {
    if (!supportsGooglePayNative) {
      throw StateError('Google Pay is only available on Android');
    }
    if ((session.googlePay?.publicKey ?? '').isEmpty) {
      throw StateError('Google Pay publicKey missing from session');
    }
    final config = PaymentConfiguration.fromJsonString(
      jsonEncode(buildGooglePayPaymentConfig(session)),
    );
    final payClient = Pay({PayProvider.google_pay: config});
    final canPay = await payClient.userCanPay(PayProvider.google_pay);
    if (!canPay) throw StateError('Google Pay is not available on this device');
    return payClient.showPaymentSelector(PayProvider.google_pay, paymentItems);
  }

  throw StateError('Unsupported wallet method: $method');
}

/// Debug helper — never use Platform in web builds without guard.
String walletPlatformLabel() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return 'other';
}
