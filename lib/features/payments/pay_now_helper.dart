import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';
import 'package:yjeek_app/features/payments/model/native_wallet_pay.dart';
import 'package:yjeek_app/features/payments/view/benefit_pay_checkout_screen.dart';

/// Shared Pay-now options + wallet / BenefitPay confirm flow (food reference).
class PayNowHelper {
  PayNowHelper(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  static const defaultPaymentOptions = <(String, String)>[
    ('YJEEK_WALLET', 'Yjeek Wallet'),
    ('BENEFIT_PAY', 'BenefitPay'),
  ];

  static bool isWallet(String methodApi) {
    final key = methodApi.toUpperCase();
    return key == 'YJEEK_WALLET' || key == 'WALLET';
  }

  static bool isBenefitPay(String methodApi) {
    final key = methodApi.toUpperCase();
    return key == 'BENEFIT_PAY' || key == 'BENEFITPAY' || key == 'BENEFIT';
  }

  static bool isSettled(String? paymentStatus) {
    final p = (paymentStatus ?? '').toUpperCase();
    return p == 'PAID' || p == 'AUTHORIZED';
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

  static List<(String, String)> parsePayNowOptions(dynamic raw) {
    if (raw is! List || raw.isEmpty) return List.of(defaultPaymentOptions);
    final parsed = <(String, String)>[];
    for (final entry in raw) {
      final api = entry?.toString().toUpperCase() ?? '';
      if (api.isEmpty) continue;
      // Pay-now online options only — no COD / Card stubs.
      if (isCashMethod(api)) continue;
      if (api == 'CARD') continue;
      if (api == 'APPLE_PAY' && !supportsApplePayNative) continue;
      if (api == 'GOOGLE_PAY' && !supportsGooglePayNative) continue;
      parsed.add((api, formatPaymentMethod(api)));
    }
    return parsed.isEmpty ? List.of(defaultPaymentOptions) : parsed;
  }

  static String subtitleForMethod(String methodApi, String balanceLabel) {
    if (isWallet(methodApi)) return balanceLabel;
    if (isBenefitPay(methodApi)) return 'Pay securely with BenefitPay';
    if (isApplePayMethod(methodApi)) return 'Pay with Apple Pay';
    if (isGooglePayMethod(methodApi)) return 'Pay with Google Pay';
    return formatPaymentMethod(methodApi);
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
    required List<(String, String)> options,
    required String currentApi,
    required String balanceLabel,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
              child: Text(
                'Pay with',
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final opt in options)
              ListTile(
                leading: Icon(
                  isWallet(opt.$1)
                      ? Icons.account_balance_wallet_outlined
                      : Icons.payment_outlined,
                  color: AppColors.primary,
                ),
                title: Text(opt.$2),
                subtitle: isWallet(opt.$1) ? Text(balanceLabel) : null,
                trailing: currentApi == opt.$1
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, opt.$1),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
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
    final status = (order['status']?.toString() ?? '').toUpperCase();
    if (status != 'AWAITING_PAYMENT' && order['needsPayment'] != true) {
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
    final confirmed =
        await ref.read(ordersRepositoryProvider).confirmPaymentDetailed(
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

  Future<bool> payWithBenefitPay({
    required List<String> orderIds,
  }) async {
    for (final orderId in orderIds) {
      final initiated =
          await ref.read(ordersRepositoryProvider).initiatePaymentDetailed(orderId);
      if (!initiated.ok) {
        snack(
          initiated.errorMessage ?? 'Could not start BenefitPay',
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
      final checkout =
          await Navigator.of(context).push<BenefitPayCheckoutResult>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => BenefitPayCheckoutScreen(
            paymentUrl: paymentUrl,
            paymentId: initiated.paymentId,
            referenceNumber: gatewayRef,
            amountLabel: initiated.amountLabel,
          ),
        ),
      );
      if (!context.mounted) return false;
      final settled = await _refreshUntilBenefitSettled(orderId);
      if (settled) {
        snack('Payment successful');
        var ok = await confirmAuthorized(
          orderId: orderId,
          paymentMethod: 'BENEFIT_PAY',
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
        snack(
          'Payment failed or cancelled',
          color: const Color(0xFFB42318),
        );
        return false;
      }

      snack('Payment successful');
      var ok = await confirmAuthorized(
        orderId: orderId,
        paymentMethod: 'BENEFIT_PAY',
        gatewayRef: gatewayRef,
      );
      if (!ok) {
        ok = await isOrderSettled(orderId);
      }
      if (!ok) return false;
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
      final session =
          await ref.read(walletPayRepositoryProvider).createSession(orderId);
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
          e.toString().replaceFirst('Bad state: ', '').replaceFirst('StateError: ', ''),
          color: const Color(0xFFB42318),
        );
        return false;
      }
      if (token == null) {
        snack('Payment cancelled');
        return false;
      }

      final confirmed = await ref.read(walletPayRepositoryProvider).confirm(
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
    if (isWallet(methodApi)) {
      return payWithWallet(orderIds: unpaid, totalAmount: totalAmount);
    }
    if (isBenefitPay(methodApi)) {
      return payWithBenefitPay(orderIds: unpaid);
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
