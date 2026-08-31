import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/payments/benefit_pay_native.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';
import 'package:yjeek_app/features/payments/model/native_wallet_pay.dart';
import 'package:yjeek_app/features/payments/view/benefit_pay_checkout_screen.dart';

/// Shared Pay-now options + wallet / BenefitPay confirm flow (food reference).
class PayNowOption {
  const PayNowOption({
    required this.api,
    required this.label,
    required this.enabled,
  });

  final String api;
  final String label;
  final bool enabled;
}

class PayNowHelper {
  PayNowHelper(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  static const defaultPaymentOptions = <PayNowOption>[
    PayNowOption(api: 'YJEEK_WALLET', label: 'Yjeek Wallet', enabled: true),
    PayNowOption(api: 'BENEFIT_PAY', label: 'BenefitPay', enabled: true),
    PayNowOption(api: 'APPLE_PAY', label: 'Apple Pay', enabled: false),
    PayNowOption(api: 'GOOGLE_PAY', label: 'Google Pay', enabled: false),
    PayNowOption(api: 'BENEFIT', label: 'Benefit', enabled: false),
    PayNowOption(api: 'CARD', label: 'Add new card', enabled: false),
  ];

  static bool isWallet(String methodApi) {
    final key = methodApi.toUpperCase();
    return key == 'YJEEK_WALLET' || key == 'WALLET';
  }

  static bool isBenefitPayNative(String methodApi) {
    final key = methodApi.toUpperCase();
    return key == 'BENEFIT_PAY' || key == 'BENEFITPAY';
  }

  static bool isBenefitHosted(String methodApi) {
    return methodApi.toUpperCase() == 'BENEFIT';
  }

  static bool isSettled(String? paymentStatus) {
    final p = (paymentStatus ?? '').toUpperCase();
    return p == 'PAID' || p == 'AUTHORIZED';
  }

  static bool _flagTrue(dynamic value) {
    if (value == true || value == 1) return true;
    return value?.toString().toLowerCase() == 'true';
  }

  static const _terminalStatuses = {
    'CANCELLED',
    'REJECTED',
    'EXPIRED',
    'DELIVERED',
    'COMPLETED',
    'COLLECTED',
  };

  static const _beforeVendorAccept = {'PLACED', 'PENDING_VENDOR_ACCEPT'};

  /// Unpaid online order after vendor accept can still be collected.
  static bool canCollectPayment(Map<String, dynamic>? order) {
    if (order == null) return false;
    if (isSettled(paymentStatusOf(order))) return false;
    if (isCashMethod(order['paymentMethod']?.toString())) return false;
    final status = (order['status']?.toString() ?? '').toUpperCase();
    if (_terminalStatuses.contains(status)) return false;
    if (_beforeVendorAccept.contains(status)) return false;
    if (_flagTrue(order['needsPayment'])) return true;
    return status.isNotEmpty;
  }

  static bool isCashMethod(String? method) {
    final m = (method ?? '').toUpperCase();
    return m == 'CASH' || m == 'COD' || m == 'CASH_ON_DELIVERY';
  }

  static String paymentStatusOf(Map<String, dynamic>? order) {
    if (order == null) return '';
    return order['paymentStatus']?.toString() ??
        (order['payment'] is Map
            ? (order['payment'] as Map)['status']?.toString() ?? ''
            : '');
  }

  static bool isMethodEnabledOnThisDevice(String api) {
    if (isApplePayMethod(api)) return supportsApplePayNative;
    if (isGooglePayMethod(api)) return supportsGooglePayNative;
    return true;
  }

  static bool methodsMatch(String a, String b) {
    return a.toUpperCase() == b.toUpperCase();
  }

  static List<PayNowOption> parsePayNowOptions(
    dynamic raw, {
    String? orderPaymentMethod,
  }) {
    final available = <String>{};
    if (raw is List) {
      for (final entry in raw) {
        final api = entry?.toString().toUpperCase() ?? '';
        if (api.isEmpty || isCashMethod(api)) continue;
        available.add(api);
      }
    }
    final orderApi = orderPaymentMethod?.toUpperCase();

    return defaultPaymentOptions.map((option) {
      final isAvailable = available.isEmpty
          ? option.enabled
          : available.contains(option.api) || option.api == orderApi;
      final enabled = isAvailable && isMethodEnabledOnThisDevice(option.api);
      return PayNowOption(
        api: option.api,
        label: option.label,
        enabled: enabled,
      );
    }).toList();
  }

  static String subtitleForMethod(String methodApi, String balanceLabel) {
    if (isWallet(methodApi)) return balanceLabel;
    if (isBenefitPayNative(methodApi)) return 'Pay securely with BenefitPay';
    if (isBenefitHosted(methodApi)) return 'Forwarded to Benefit';
    if (isApplePayMethod(methodApi)) return 'Pay with Apple Pay';
    if (isGooglePayMethod(methodApi)) return 'Pay with Google Pay';
    return formatPaymentMethod(methodApi);
  }

  static String? subtitleForOption(PayNowOption option, String balanceLabel) {
    if (!option.enabled) return 'Coming soon';
    if (isWallet(option.api)) return balanceLabel;
    return subtitleForMethod(option.api, balanceLabel);
  }

  void snack(String message, {Color? color}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<String?> showMethodSheet({
    required List<PayNowOption> options,
    required String currentApi,
    required String balanceLabel,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                  child: Text(
                    'Pay with',
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final opt in options)
                        ListTile(
                          leading: Icon(
                            isWallet(opt.api)
                                ? Icons.account_balance_wallet_outlined
                                : Icons.payment_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            opt.label,
                            style: TextStyle(
                              color: opt.enabled ? null : AppColors.textSecondary,
                            ),
                          ),
                          subtitle: (() {
                            final subtitle = subtitleForOption(opt, balanceLabel);
                            return subtitle == null ? null : Text(subtitle);
                          })(),
                          trailing: methodsMatch(currentApi, opt.api)
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: opt.enabled
                              ? () => Navigator.pop(ctx, opt.api)
                              : null,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> isOrderSettled(String orderId) async {
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    return isSettled(paymentStatusOf(order));
  }

  /// False if missing / not awaiting (settled orders should be filtered first).
  Future<bool> ensureAwaitingPayment(String orderId) async {
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (order == null) {
      snack('Order not found', color: const Color(0xFFB42318));
      return false;
    }
    if (isSettled(paymentStatusOf(order))) return false;
    if (!canCollectPayment(order)) {
      snack(
        'This order is not awaiting payment',
        color: const Color(0xFFB42318),
      );
      return false;
    }
    return true;
  }

  Future<bool> confirmAuthorized({
    required String orderId,
    required String paymentMethod,
    String? gatewayRef,
  }) async {
    final confirmed = await ref
        .read(ordersRepositoryProvider)
        .confirmPaymentDetailed(
          orderId,
          status: 'AUTHORIZED',
          gatewayRef: gatewayRef,
          paymentMethod: paymentMethod,
        );
    if (!confirmed.ok) {
      snack(
        confirmed.errorMessage ?? 'Payment failed — try again',
        color: const Color(0xFFB42318),
      );
      return false;
    }

    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (isSettled(paymentStatusOf(order))) return true;

    snack(
      'Payment was not authorized — try again',
      color: const Color(0xFFB42318),
    );
    return false;
  }

  Future<num> fetchWalletBalance() async {
    final wallet = await ref.read(walletRepositoryProvider).fetchWallet();
    return wallet.balance ?? parseMoney(wallet.balanceLabel) ?? 0;
  }

  Future<bool> payWithWallet({
    required List<String> orderIds,
    required num totalAmount,
  }) async {
    final balance = await fetchWalletBalance();
    if (balance < totalAmount) {
      snack(
        'Insufficient wallet balance. Top up or switch to BenefitPay.',
        color: const Color(0xFFB42318),
      );
      return false;
    }
    for (final orderId in orderIds) {
      final ok = await confirmAuthorized(
        orderId: orderId,
        paymentMethod: 'YJEEK_WALLET',
      );
      if (!ok) return false;
    }
    return true;
  }

  Future<bool> payWithBenefitHosted({required List<String> orderIds}) async {
    for (final orderId in orderIds) {
      final initiated = await ref
          .read(ordersRepositoryProvider)
          .initiatePaymentDetailed(orderId);
      if (!initiated.ok) {
        snack(
          initiated.errorMessage ?? 'Could not start Benefit payment',
          color: const Color(0xFFB42318),
        );
        return false;
      }
      final gatewayRef = initiated.gatewayRef;
      if (gatewayRef == null || gatewayRef.isEmpty) {
        snack(
          'Missing payment reference from server',
          color: const Color(0xFFB42318),
        );
        return false;
      }
      final paymentUrl = initiated.paymentUrl?.trim();
      if (paymentUrl == null || paymentUrl.isEmpty) {
        snack(
          initiated.hostedInitError ??
              'Benefit Hosted Init failed (no PaymentURL)',
          color: const Color(0xFFB42318),
        );
        return false;
      }

      if (!context.mounted) return false;
      final checkout = await Navigator.of(context)
          .push<BenefitPayCheckoutResult>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => BenefitPayCheckoutScreen(
                paymentUrl: paymentUrl,
                paymentId: initiated.paymentId,
                referenceNumber: gatewayRef,
                amountLabel: initiated.amountLabel,
                title: 'Benefit',
              ),
            ),
          );
      if (!context.mounted) return false;
      final settled = await _refreshUntilBenefitSettled(orderId);
      if (settled) {
        snack('Payment successful');
        var ok = await confirmAuthorized(
          orderId: orderId,
          paymentMethod: 'BENEFIT',
          gatewayRef: gatewayRef,
        );
        if (!ok) ok = await isOrderSettled(orderId);
        if (!ok) return false;
        continue;
      }
      if (checkout == null ||
          checkout.outcome == BenefitPayCheckoutOutcome.closed) {
        snack(checkout?.message ?? 'Payment cancelled');
        return false;
      }
      if (checkout.outcome != BenefitPayCheckoutOutcome.success) {
        snack('Payment failed or cancelled', color: const Color(0xFFB42318));
        return false;
      }

      snack('Payment successful');
      var ok = await confirmAuthorized(
        orderId: orderId,
        paymentMethod: 'BENEFIT',
        gatewayRef: gatewayRef,
      );
      if (!ok) {
        ok = await isOrderSettled(orderId);
      }
      if (!ok) return false;
    }
    return true;
  }

  Future<bool> payWithBenefitPayNative({required List<String> orderIds}) async {
    for (final orderId in orderIds) {
      final sessionResult = await ref
          .read(ordersRepositoryProvider)
          .fetchBenefitPayNativeSession(orderId);
      if (!sessionResult.ok || sessionResult.session == null) {
        snack(
          sessionResult.errorMessage ?? 'Could not start BenefitPay',
          color: const Color(0xFFB42318),
        );
        return false;
      }
      final session = sessionResult.session!;
      final gatewayRef = session.gatewayRef;
      if (gatewayRef.isEmpty) {
        snack(
          'Missing payment reference from server',
          color: const Color(0xFFB42318),
        );
        return false;
      }

      final available = await BenefitPayNative.isAvailable();
      if (!available) {
        snack(
          'BenefitPay app is not installed on this device',
          color: const Color(0xFFB42318),
        );
        return false;
      }

      final native = await BenefitPayNative.pay(session);
      if (native.isUnavailable) {
        snack(
          native.message ?? 'BenefitPay is not available',
          color: const Color(0xFFB42318),
        );
        return false;
      }
      if (native.isCancelled) {
        snack(native.message ?? 'Payment cancelled');
        return false;
      }
      if (!native.isSuccess) {
        snack(
          native.message ?? 'Payment failed or cancelled',
          color: const Color(0xFFB42318),
        );
        return false;
      }

      snack('Payment successful');
      final ok = await confirmAuthorized(
        orderId: orderId,
        paymentMethod: 'BENEFIT_PAY',
        gatewayRef: gatewayRef,
      );
      if (!ok) {
        final settled = await isOrderSettled(orderId);
        if (!settled) return false;
      }
    }
    return true;
  }

  /// BENEFIT often hits /error after a real CAPTURED success. Trust PAID on the order.
  Future<bool> _refreshUntilBenefitSettled(String orderId) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
      if (await isOrderSettled(orderId)) return true;
    }
    return false;
  }

  Future<bool> payWithNativeWallet({
    required List<String> orderIds,
    required String methodApi,
  }) async {
    final method = methodApi.toUpperCase();
    for (final orderId in orderIds) {
      final session = await ref
          .read(walletPayRepositoryProvider)
          .createSession(orderId);
      if (session == null) {
        snack(
          'Could not start ${formatPaymentMethod(method)}',
          color: const Color(0xFFB42318),
        );
        return false;
      }
      if (session.gatewayRef.isEmpty) {
        snack(
          'Missing payment reference from server',
          color: const Color(0xFFB42318),
        );
        return false;
      }

      Object? token;
      try {
        token = await presentNativeWalletSheet(session);
      } catch (e) {
        snack(
          e
              .toString()
              .replaceFirst('Bad state: ', '')
              .replaceFirst('StateError: ', ''),
          color: const Color(0xFFB42318),
        );
        return false;
      }
      if (token == null) {
        snack('Payment cancelled');
        return false;
      }

      final confirmed = await ref
          .read(walletPayRepositoryProvider)
          .confirm(
            orderId: orderId,
            paymentMethod: method,
            gatewayRef: session.gatewayRef,
            paymentToken: token,
          );
      if (!confirmed.ok) {
        snack(
          confirmed.errorMessage ?? 'Payment failed — try again',
          color: const Color(0xFFB42318),
        );
        return false;
      }

      final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
      if (!isSettled(paymentStatusOf(order))) {
        snack(
          'Payment was not authorized — try again',
          color: const Color(0xFFB42318),
        );
        return false;
      }
    }
    return true;
  }

  Future<bool> pay({
    required List<String> orderIds,
    required String methodApi,
    required num totalAmount,
  }) async {
    if (orderIds.isEmpty) {
      snack('Order not found', color: const Color(0xFFB42318));
      return false;
    }
    final unpaid = <String>[];
    for (final id in orderIds) {
      if (await isOrderSettled(id)) continue;
      final canPay = await ensureAwaitingPayment(id);
      if (!canPay) return false;
      unpaid.add(id);
    }
    if (unpaid.isEmpty) return true;
    if (!isMethodEnabledOnThisDevice(methodApi)) {
      snack('Coming soon');
      return false;
    }
    if (isWallet(methodApi)) {
      return payWithWallet(orderIds: unpaid, totalAmount: totalAmount);
    }
    if (isBenefitHosted(methodApi)) {
      return payWithBenefitHosted(orderIds: unpaid);
    }
    if (isBenefitPayNative(methodApi)) {
      return payWithBenefitPayNative(orderIds: unpaid);
    }
    if (isNativeWalletMethod(methodApi)) {
      return payWithNativeWallet(orderIds: unpaid, methodApi: methodApi);
    }
    snack('Unsupported payment method: ${formatPaymentMethod(methodApi)}');
    return false;
  }

  Future<bool> changeMethod({
    required List<String> orderIds,
    required String selected,
  }) async {
    var anyOk = false;
    for (final id in orderIds) {
      final ok = await ref
          .read(ordersRepositoryProvider)
          .changePaymentMethod(id, selected);
      if (ok) anyOk = true;
    }
    if (!anyOk) {
      snack('Could not change payment method — try again');
    }
    return anyOk;
  }
}
