import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/payments/payment_dev_bypass.dart';
import 'package:yjeek_app/features/payments/benefit_pay_debug.dart';
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
    PayNowOption(api: 'BENEFIT_PAY', label: 'BenefitPay', enabled: true),
    PayNowOption(api: 'APPLE_PAY', label: 'Apple Pay', enabled: false),
    PayNowOption(api: 'GOOGLE_PAY', label: 'Google Pay', enabled: false),
    PayNowOption(api: 'BENEFIT', label: 'Benefit', enabled: true),
    PayNowOption(api: 'CARD', label: 'Add new card', enabled: false),
    PayNowOption(api: 'YJEEK_WALLET', label: 'Yjeek Wallet', enabled: true),
  ];

  static bool isWallet(String methodApi) {
    final key = methodApi.toUpperCase();
    return key == 'YJEEK_WALLET' || key == 'WALLET';
  }

  static bool isBenefitPayNative(String methodApi) {
    final key = methodApi.toUpperCase();
    return key == 'BENEFIT_PAY' || key == 'BENEFITPAY';
  }

  /// Native Wallet: never treat SDK success alone as payment success.
  /// Success snack only after confirm (or settlement fallback).
  static bool shouldShowNativePaymentSuccessSnack({
    required bool confirmOk,
    bool orderSettled = false,
  }) =>
      confirmOk || orderSettled;

  /// Native Wallet routing after SDK returns (before /payments/confirm).
  /// Insufficient-funds / declines stay on the SDK failure path.
  static bool shouldConfirmAfterNativeSdk(BenefitPayNativeResult native) {
    if (native.isUnavailable || native.isCancelled || !native.isSuccess) {
      return false;
    }
    return true;
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

  Future<void> _showBenefitPayDebugFailure(
    BenefitPayFailureDiagnostic diagnostic,
  ) async {
    if (!kDebugMode || !context.mounted) return;
    await BenefitPayDebug.showFailureDiagnostics(context, diagnostic);
  }

  Future<String?> showMethodSheet({
    required List<PayNowOption> options,
    required String currentApi,
    required String balanceLabel,
  }) async {
    final rows = options
        .where((option) => !isCashMethod(option.api))
        .map(_checkoutStyleOption)
        .toList();
    return showModalBottomSheet<String>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: AppColors.background,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: CartPaymentMethodList(
              options: rows,
              selectedId: currentApi.toUpperCase(),
              onSelected: (id) {
                PayNowOption? match;
                for (final option in options) {
                  if (option.api.toUpperCase() == id.toUpperCase()) {
                    match = option;
                    break;
                  }
                }
                if (match == null || !match.enabled) {
                  snack('Coming soon');
                  return;
                }
                Navigator.pop(ctx, match.api);
              },
            ),
          ),
        );
      },
    );
  }

  PaymentOption _checkoutStyleOption(PayNowOption option) {
    final api = option.api.toUpperCase();
    return PaymentOption(
      id: api,
      label: api == 'CARD' ? 'Add new card' : option.label,
      iconAsset: switch (api) {
        'BENEFIT_PAY' => AppAssets.payBenefitPay,
        'APPLE_PAY' => AppAssets.payApple,
        'GOOGLE_PAY' => AppAssets.payGoogle,
        'BENEFIT' => AppAssets.payBenefit,
        'CARD' => AppAssets.payAddCard,
        'YJEEK_WALLET' => AppAssets.payWallet,
        _ => AppAssets.payWallet,
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
    bool devBypassBenefitPay = false,
  }) async {
    final confirmed = await ref
        .read(ordersRepositoryProvider)
        .confirmPaymentDetailed(
          orderId,
          status: 'AUTHORIZED',
          gatewayRef: gatewayRef,
          paymentMethod: paymentMethod,
          devBypassBenefitPay: devBypassBenefitPay,
        );
    if (!confirmed.ok) {
      snack(
        confirmed.errorMessage ?? 'Payment failed — try again',
        color: const Color(0xFFB42318),
      );
      if (kDebugMode && isBenefitPayNative(paymentMethod)) {
        await _showBenefitPayDebugFailure(
          BenefitPayFailureDiagnostic(
            orderId: orderId,
            debugId: gatewayRef,
            errorCode: confirmed.errorCode ??
                confirmed.httpStatus?.toString(),
            errorMessage: confirmed.errorMessage,
          ),
        );
      }
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

  Future<bool> payWithCard({required List<String> orderIds}) async {
    for (final orderId in orderIds) {
      final initiated = await ref
          .read(ordersRepositoryProvider)
          .initiatePaymentDetailed(orderId);
      if (!initiated.ok) {
        snack(
          initiated.errorMessage ?? 'Could not start card payment',
          color: const Color(0xFFB42318),
        );
        return false;
      }
      final paymentUrl = initiated.paymentUrl?.trim();
      final gatewayRef = initiated.gatewayRef;
      if (paymentUrl == null ||
          paymentUrl.isEmpty ||
          gatewayRef == null ||
          gatewayRef.isEmpty) {
        snack('Card payment is not available right now');
        return false;
      }
      if (!context.mounted) return false;
      final checkout = await Navigator.of(context).push<BenefitPayCheckoutResult>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => BenefitPayCheckoutScreen(
            paymentUrl: paymentUrl,
            paymentId: initiated.paymentId,
            referenceNumber: gatewayRef,
            amountLabel: initiated.amountLabel,
            title: 'Card',
          ),
        ),
      );
      if (!context.mounted) return false;
      if (checkout?.outcome != BenefitPayCheckoutOutcome.success) {
        snack(checkout?.message ?? 'Card payment cancelled');
        return false;
      }
      final ok = await confirmAuthorized(
        orderId: orderId,
        paymentMethod: 'CARD',
        gatewayRef: gatewayRef,
      );
      if (!ok && !await isOrderSettled(orderId)) return false;
      snack('Payment successful');
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

  /// TEMPORARY: mint session + confirm without opening BenefitPay app.
  Future<bool> payWithBenefitPayNativeDevBypass({
    required List<String> orderIds,
  }) async {
    for (final orderId in orderIds) {
      if (kDebugMode) {
        BenefitPayDebug.log(
          'payWithBenefitPayNative DEV BYPASS orderId=$orderId',
        );
      }
      final sessionResult = await ref
          .read(ordersRepositoryProvider)
          .fetchBenefitPayNativeSession(orderId);
      if (!sessionResult.ok || sessionResult.session == null) {
        final message =
            sessionResult.errorMessage ?? 'Could not start BenefitPay';
        snack(message, color: const Color(0xFFB42318));
        return false;
      }
      final gatewayRef = sessionResult.session!.gatewayRef;
      if (gatewayRef.isEmpty) {
        snack(
          'Missing payment reference from server',
          color: const Color(0xFFB42318),
        );
        return false;
      }
      final ok = await confirmAuthorized(
        orderId: orderId,
        paymentMethod: 'BENEFIT_PAY',
        gatewayRef: gatewayRef,
        devBypassBenefitPay: true,
      );
      final settled = ok ? true : await isOrderSettled(orderId);
      if (!shouldShowNativePaymentSuccessSnack(
        confirmOk: ok,
        orderSettled: settled,
      )) {
        return false;
      }
      snack('Payment successful (dev bypass)');
    }
    return true;
  }

  Future<bool> payWithBenefitPayNative({required List<String> orderIds}) async {
    if (PaymentDevBypass.skipBenefitPayNativeSdk) {
      return payWithBenefitPayNativeDevBypass(orderIds: orderIds);
    }
    for (final orderId in orderIds) {
      if (kDebugMode) {
        BenefitPayDebug.log('payWithBenefitPayNative start orderId=$orderId');
      }
      final sessionResult = await ref
          .read(ordersRepositoryProvider)
          .fetchBenefitPayNativeSession(orderId);
      if (!sessionResult.ok || sessionResult.session == null) {
        final message =
            sessionResult.errorMessage ?? 'Could not start BenefitPay';
        snack(message, color: const Color(0xFFB42318));
        if (kDebugMode) {
          await _showBenefitPayDebugFailure(
            BenefitPayFailureDiagnostic(
              orderId: orderId,
              errorCode: sessionResult.errorCode ??
                  sessionResult.httpStatus?.toString(),
              errorMessage: message,
            ),
          );
        }
        return false;
      }
      final session = sessionResult.session!;
      final gatewayRef = session.gatewayRef;
      if (gatewayRef.isEmpty) {
        snack(
          'Missing payment reference from server',
          color: const Color(0xFFB42318),
        );
        if (kDebugMode) {
          await _showBenefitPayDebugFailure(
            BenefitPayFailureDiagnostic(
              orderId: orderId,
              errorCode: sessionResult.httpStatus?.toString(),
              errorMessage: 'Missing payment reference from server',
            ),
          );
        }
        return false;
      }

      final available = await BenefitPayNative.isAvailable();
      BenefitPayDebug.logNativeLaunch(
        available: available,
        gatewayRef: gatewayRef,
      );
      if (!available) {
        snack(
          'BenefitPay app is not installed on this device',
          color: const Color(0xFFB42318),
        );
        if (kDebugMode) {
          await _showBenefitPayDebugFailure(
            BenefitPayFailureDiagnostic(
              orderId: orderId,
              debugId: gatewayRef,
              errorMessage: 'BenefitPay app is not installed on this device',
            ),
          );
        }
        return false;
      }

      final native = await BenefitPayNative.pay(session);
      BenefitPayDebug.logAppResume(
        phase: 'after_native_pay',
        orderId: orderId,
      );
      if (native.isUnavailable) {
        final message = native.message ?? 'BenefitPay is not available';
        snack(message, color: const Color(0xFFB42318));
        if (kDebugMode) {
          await _showBenefitPayDebugFailure(
            BenefitPayFailureDiagnostic(
              orderId: orderId,
              debugId: gatewayRef,
              errorMessage: message,
            ),
          );
        }
        return false;
      }
      if (native.isCancelled) {
        snack(native.message ?? 'Payment cancelled');
        if (kDebugMode) {
          await _showBenefitPayDebugFailure(
            BenefitPayFailureDiagnostic(
              orderId: orderId,
              debugId: gatewayRef,
              errorCode: 'cancelled',
              errorMessage: native.message ?? 'Payment cancelled',
            ),
          );
        }
        return false;
      }
      if (!shouldConfirmAfterNativeSdk(native)) {
        final message = native.message ?? 'Payment failed or cancelled';
        snack(message, color: const Color(0xFFB42318));
        if (kDebugMode) {
          await _showBenefitPayDebugFailure(
            BenefitPayFailureDiagnostic(
              orderId: orderId,
              debugId: gatewayRef,
              errorCode: native.referenceId != null &&
                      native.referenceId!.isNotEmpty
                  ? 'native_failed'
                  : null,
              errorMessage: message,
            ),
          );
        }
        return false;
      }

      // Confirm first — only show success after backend verification succeeds.
      final ok = await confirmAuthorized(
        orderId: orderId,
        paymentMethod: 'BENEFIT_PAY',
        gatewayRef: gatewayRef,
      );
      final settled = ok ? true : await isOrderSettled(orderId);
      if (!shouldShowNativePaymentSuccessSnack(
        confirmOk: ok,
        orderSettled: settled,
      )) {
        return false;
      }
      snack('Payment successful');
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
    if (methodApi.toUpperCase() == 'CARD') {
      return payWithCard(orderIds: unpaid);
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
