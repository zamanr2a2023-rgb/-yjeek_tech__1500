import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/payments/model/native_wallet_pay.dart';

class CheckoutPaymentMethods {
  const CheckoutPaymentMethods({
    required this.options,
    required this.defaultId,
    this.walletBalance = 0,
  });

  final List<PaymentOption> options;
  final String defaultId;
  final double walletBalance;

  static List<PaymentOption> platformFiltered(List<PaymentOption> options) {
    return filterWalletMethodsForPlatform(options, (o) {
      if (o.id == 'apple') return 'APPLE_PAY';
      if (o.id == 'google') return 'GOOGLE_PAY';
      return o.id;
    });
  }

  static CheckoutPaymentMethods fallback({
    List<PaymentOption>? base,
    String defaultId = 'benefitpay',
  }) {
    final options = platformFiltered(
      List<PaymentOption>.from(base ?? CartFlowData.paymentOptions),
    );
    final preferred = options.any((o) => o.id == defaultId)
        ? defaultId
        : (options.isNotEmpty ? options.first.id : defaultId);
    return CheckoutPaymentMethods(
      options: options,
      defaultId: preferred,
    );
  }
}

class PaymentMethodsRepository {
  const PaymentMethodsRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// GET /users/me/payment-methods
  Future<CheckoutPaymentMethods> fetchCheckoutMethods({
    List<PaymentOption>? fallback,
    bool includeCod = true,
    bool includeWallet = true,
    String? preferredDefaultId,
  }) async {
    final base = fallback ?? CartFlowData.paymentOptions;
    if (!_storage.hasSession) {
      return CheckoutPaymentMethods.fallback(
        base: base,
        defaultId: preferredDefaultId ?? 'benefitpay',
      );
    }

    try {
      final response = await _apiClient.getJson(
        '/users/me/payment-methods',
        bearerToken: _storage.token,
      );
      final data = response?['data'];
      if (data is! Map<String, dynamic>) {
        return CheckoutPaymentMethods.fallback(
          base: base,
          defaultId: preferredDefaultId ?? 'benefitpay',
        );
      }

      final methodsRaw = data['methods'];
      final options = <PaymentOption>[];
      if (methodsRaw is List) {
        for (final raw in methodsRaw) {
          if (raw is! Map<String, dynamic>) continue;
          final id = raw['id']?.toString();
          if (id == null || id.isEmpty) continue;
          if (!includeCod && id == 'cod') continue;
          if (!includeWallet && id == 'wallet') continue;
          final label = raw['label']?.toString() ?? id;
          final subtitle = raw['subtitle']?.toString();
          options.add(
            PaymentOption(
              id: id,
              label: subtitle != null && subtitle.isNotEmpty
                  ? '$label · $subtitle'
                  : label,
              iconAsset: _iconFor(id, raw['iconKey']?.toString()),
            ),
          );
        }
      }

      if (options.isEmpty) {
        return CheckoutPaymentMethods.fallback(
          base: base,
          defaultId: preferredDefaultId ?? 'benefitpay',
        );
      }

      final filtered = CheckoutPaymentMethods.platformFiltered(options);
      if (filtered.isEmpty) {
        return CheckoutPaymentMethods.fallback(
          base: base,
          defaultId: preferredDefaultId ?? 'benefitpay',
        );
      }

      final apiDefault = data['defaultMethodId']?.toString();
      final preferred = preferredDefaultId ?? apiDefault ?? filtered.first.id;
      final walletBalance = (data['walletBalance'] as num?)?.toDouble() ?? 0;
      return CheckoutPaymentMethods(
        options: filtered,
        defaultId: filtered.any((o) => o.id == preferred)
            ? preferred
            : filtered.first.id,
        walletBalance: walletBalance,
      );
    } catch (_) {
      return CheckoutPaymentMethods.fallback(
        base: base,
        defaultId: preferredDefaultId ?? 'benefitpay',
      );
    }
  }

  static String _iconFor(String id, String? iconKey) {
    final key = iconKey ?? id;
    return switch (key) {
      'apple' => AppAssets.payApple,
      'google' => AppAssets.payGoogle,
      'benefit' => AppAssets.payBenefit,
      'benefitpay' => AppAssets.payBenefitPay,
      'wallet' => AppAssets.payWallet,
      'cod' => AppAssets.payCash,
      'new-card' => AppAssets.payAddCard,
      _ => AppAssets.payAddCard,
    };
  }
}
