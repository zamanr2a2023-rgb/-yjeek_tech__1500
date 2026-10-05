import 'package:flutter/foundation.dart';
import 'package:yjeek_app/core/constants/api_constants.dart';

/// TEMPORARY — set [enabled] to false before store release.
///
/// When on, BenefitPay skips the native wallet app and POSTs payment confirm
/// with `devBypassBenefitPay: true` (server must include benefit-pay-dev-bypass).
abstract final class PaymentDevBypass {
  static const bool enabled = true;

  static bool get skipBenefitPayNativeSdk =>
      enabled && (kDebugMode || ApiConstants.isLikelyUatBackend);
}
