import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';

/// TEMPORARY — flip individual [hide…] flags to `false` to show a method again.
abstract final class CheckoutPaymentVisibility {
  static const bool hideBenefitPay = true;
  static const bool hideApplePay = true;
  static const bool hideGooglePay = true;
  static const bool hideAddNewCard = true;
  static const bool hideCashOnDelivery = true;

  /// Default selection when BenefitPay is hidden.
  static const String visibleDefaultMethodId = 'benefit';

  static Set<String> get hiddenCheckoutMethodIds {
    final ids = <String>{};
    if (hideBenefitPay) ids.add('benefitpay');
    if (hideApplePay) ids.add('apple');
    if (hideGooglePay) ids.add('google');
    if (hideAddNewCard) ids.add('new-card');
    if (hideCashOnDelivery) ids.add('cod');
    return ids;
  }

  static List<PaymentOption> filter(List<PaymentOption> options) {
    final hidden = hiddenCheckoutMethodIds;
    if (hidden.isEmpty) return options;
    return options.where((o) => !hidden.contains(o.id)).toList();
  }

  static String preferredCheckoutDefaultId({String whenAllVisible = 'benefitpay'}) {
    if (!hideBenefitPay) return whenAllVisible;
    return visibleDefaultMethodId;
  }

  /// Pay-now / order payment sheet (API enums, not checkout ids).
  static bool isPayNowApiHidden(String methodApi) {
    final key = methodApi.toUpperCase();
    return switch (key) {
      'BENEFIT_PAY' || 'BENEFITPAY' => hideBenefitPay,
      'APPLE_PAY' => hideApplePay,
      'GOOGLE_PAY' => hideGooglePay,
      'CARD' => hideAddNewCard,
      'CASH' || 'COD' || 'CASH_ON_DELIVERY' => hideCashOnDelivery,
      _ => false,
    };
  }

  static String preferredPayNowDefaultApi({String whenAllVisible = 'BENEFIT_PAY'}) {
    if (!hideBenefitPay) return whenAllVisible;
    return 'BENEFIT';
  }

  static String resolvePayNowApi({
    required List<dynamic> visibleOptions,
    String? preferred,
    String whenAllVisible = 'BENEFIT_PAY',
    String Function(dynamic option)? readApi,
  }) {
    String apiOf(dynamic option) {
      if (readApi != null) return readApi(option).toUpperCase();
      if (option is String) return option.toUpperCase();
      try {
        return (option as dynamic).api.toString().toUpperCase();
      } catch (_) {
        return '';
      }
    }

    bool containsApi(String api) {
      final key = api.toUpperCase();
      for (final option in visibleOptions) {
        if (apiOf(option) == key) return true;
      }
      return false;
    }

    final candidates = <String>[
      if (preferred != null && preferred.isNotEmpty) preferred.toUpperCase(),
      preferredPayNowDefaultApi(whenAllVisible: whenAllVisible),
      if (visibleOptions.isNotEmpty) apiOf(visibleOptions.first),
    ];
    for (final api in candidates) {
      if (api.isEmpty || isPayNowApiHidden(api)) continue;
      if (containsApi(api)) return api;
    }
    return preferredPayNowDefaultApi(whenAllVisible: whenAllVisible);
  }

  static String resolveDefaultId({
    required List<PaymentOption> options,
    String? preferred,
    String whenAllVisible = 'benefitpay',
  }) {
    final candidates = <String>[
      if (preferred != null && preferred.isNotEmpty) preferred,
      preferredCheckoutDefaultId(whenAllVisible: whenAllVisible),
      if (options.isNotEmpty) options.first.id,
    ];
    for (final id in candidates) {
      if (options.any((o) => o.id == id)) return id;
    }
    return preferredCheckoutDefaultId(whenAllVisible: whenAllVisible);
  }
}
