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
}
