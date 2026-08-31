import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';
import 'package:yjeek_app/features/payments/view/benefit_pay_checkout_screen.dart';

void main() {
  test('buildBenefitPayCheckoutUri uses sandbox hash route', () {
    final payload = BenefitPaySdkPayload.fromJson({
      'merchantId': '3430',
      'appId': '6412373392',
      'transactionAmount': '3.571',
      'transactionCurrency': 'BHD',
      'referenceNumber': 'bp_test_1',
      'secure_hash': 'abc123',
      'showResult': 0,
      'hideMobileQR': 0,
    });
    final uri = buildBenefitPayCheckoutUri(payload);
    expect(uri.host, 'benefit-checkout.test-benefitpay.bh');
    expect(uri.fragment, contains('/home?'));
    expect(uri.fragment, contains('secure_hash=abc123'));
    expect(uri.fragment, contains('merchantId=3430'));
  });
}
