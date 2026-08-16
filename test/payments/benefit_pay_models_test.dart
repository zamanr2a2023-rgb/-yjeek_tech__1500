import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';

void main() {
  test('BenefitPaySdkPayload parses initiate sdkPayload', () {
    final payload = BenefitPaySdkPayload.fromJson({
      'merchantId': '3430',
      'appId': '6412373392',
      'transactionAmount': '3.571',
      'transactionCurrency': 'BHD',
      'referenceNumber': 'bp_test_1',
      'hashedString': 'canon',
      'secure_hash': 'abc123',
      'showResult': 0,
      'hideMobileQR': 0,
      'qr_timeout': 150000,
    });

    expect(payload.isComplete, isTrue);
    expect(payload.toRequestData()['secure_hash'], 'abc123');
    expect(payload.toRequestData()['showResult'], '0');
    expect(payload.toRequestData()['qr_timeout'], 150000);
  });

  test('parseMoney accepts num and string', () {
    expect(parseMoney(3.571), 3.571);
    expect(parseMoney('12.450'), 12.450);
    expect(parseMoney(null), isNull);
  });

  test('canOpenCheckout requires hosted PaymentURL not sdkPayload', () {
    final payload = BenefitPaySdkPayload.fromJson({
      'merchantId': '3430',
      'appId': '1',
      'transactionAmount': '1.000',
      'transactionCurrency': 'BHD',
      'referenceNumber': 'bp_1',
      'secure_hash': 'abc',
    });
    expect(
      PaymentInitiateResult(
        ok: true,
        paymentUrl: 'https://www.test.benefit-gateway.bh/pay',
        sdkPayload: payload,
      ).canOpenCheckout,
      isTrue,
    );
    expect(
      PaymentInitiateResult(
        ok: true,
        paymentUrl: null,
        sdkPayload: payload,
        hostedInitError: 'Benefit hosted init failed',
      ).canOpenCheckout,
      isFalse,
    );
  });

  test('hosted PaymentURL is opened verbatim, not a FOO checkout host', () {
    const hosted =
        'https://www.test.benefit-gateway.bh/payment/paymentpage.htm?PaymentID=99';
    final result = PaymentInitiateResult(ok: true, paymentUrl: hosted);
    expect(result.canOpenCheckout, isTrue);
    final uri = Uri.parse(result.paymentUrl!.trim());
    expect(uri.host, 'www.test.benefit-gateway.bh');
    expect(uri.host.contains('benefit-checkout'), isFalse);
    expect(uri.host.contains('test-benefitpay.bh'), isFalse);
  });

  test('benefitHostedCallbackKind intercepts success and error URLs', () {
    expect(
      benefitHostedCallbackKind(
        'https://api.yjeektech.com/payments/benefit/success',
      ),
      BenefitHostedCallbackKind.success,
    );
    expect(
      benefitHostedCallbackKind(
        'https://api.yjeektech.com/payments/benefit/success?trandata=abc',
      ),
      BenefitHostedCallbackKind.success,
    );
    expect(
      benefitHostedCallbackKind(
        'https://api.yjeektech.com/payments/benefit/error',
      ),
      BenefitHostedCallbackKind.error,
    );
    expect(
      benefitHostedCallbackKind(
        'https://test.benefit-gateway.bh/payment/paymentpage.htm?PaymentID=1',
      ),
      isNull,
    );
  });
}
