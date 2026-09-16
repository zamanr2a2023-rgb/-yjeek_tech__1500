import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/payments/benefit_pay_native.dart';
import 'package:yjeek_app/features/payments/pay_now_helper.dart';

void main() {
  group('BenefitPay native success timing', () {
    test('SDK success + confirm fail → no success snackbar', () {
      const native = BenefitPayNativeResult(status: 'success');
      expect(PayNowHelper.shouldConfirmAfterNativeSdk(native), isTrue);
      expect(
        PayNowHelper.shouldShowNativePaymentSuccessSnack(
          confirmOk: false,
          orderSettled: false,
        ),
        isFalse,
      );
    });

    test('SDK success + confirm success → success snackbar', () {
      const native = BenefitPayNativeResult(status: 'success');
      expect(PayNowHelper.shouldConfirmAfterNativeSdk(native), isTrue);
      expect(
        PayNowHelper.shouldShowNativePaymentSuccessSnack(
          confirmOk: true,
          orderSettled: false,
        ),
        isTrue,
      );
    });

    test('insufficient funds / SDK failure path unchanged (no confirm)', () {
      const insufficient = BenefitPayNativeResult(
        status: 'failed',
        message: 'Insufficient funds',
      );
      expect(PayNowHelper.shouldConfirmAfterNativeSdk(insufficient), isFalse);
      expect(
        PayNowHelper.shouldShowNativePaymentSuccessSnack(
          confirmOk: false,
          orderSettled: false,
        ),
        isFalse,
      );
    });

    test('cancelled does not confirm or show success', () {
      const cancelled = BenefitPayNativeResult(status: 'cancelled');
      expect(PayNowHelper.shouldConfirmAfterNativeSdk(cancelled), isFalse);
      expect(
        PayNowHelper.shouldShowNativePaymentSuccessSnack(confirmOk: false),
        isFalse,
      );
    });
  });
}
