import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';
import 'package:yjeek_app/features/payments/pay_now_helper.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Food delivery: pay after vendor accept (5 min window).
/// Payment options: Wallet, BenefitPay, Apple Pay (iOS), Google Pay (Android).
class OrderPayScreen extends ConsumerStatefulWidget {
  const OrderPayScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderPayScreen> createState() => _OrderPayScreenState();
}

class _OrderPayScreenState extends ConsumerState<OrderPayScreen> {
  static const _defaultSeconds = 299;

  late int _secondsLeft;
  Timer? _timer;
  bool _paying = false;
  bool _expiring = false;
  bool _expired = false;
  bool _methodBusy = false;
  DateTime? _payArmedAt;
  String _vendor = 'Vendor';
  String _method = 'BenefitPay';
  String _methodApi = 'BENEFIT_PAY';
  String _balance = 'Balance BHD 0.000';
  num _totalAmount = 0;
  String _subtotal = 'BHD —';
  String? _discountLabel;
  String? _discountValue;
  String? _deliveryFee;
  String _serviceFee = 'BHD —';
  String? _tip;
  String? _vat;
  String _total = 'BHD —';
  List<PayNowOption> _paymentOptions =
      List.of(PayNowHelper.defaultPaymentOptions);

  @override
  void initState() {
    super.initState();
    _secondsLeft = _defaultSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _expired || _expiring) return;
      if (_secondsLeft <= 0) {
        unawaited(_onPaymentWindowExpired());
        return;
      }
      setState(() => _secondsLeft--);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString()}:${s.toString().padLeft(2, '0')}';
  }

  bool _isPaidOrCash(String? method, String? paymentStatus) {
    final m = (method ?? '').toUpperCase();
    final p = (paymentStatus ?? '').toUpperCase();
    if (p == 'PAID' || p == 'AUTHORIZED') return true;
    return m == 'CASH' || m == 'COD' || m == 'CASH_ON_DELIVERY';
  }

  String _subtitleForMethod(String methodApi) {
    return PayNowHelper.subtitleForMethod(methodApi, _balance);
  }

  List<PayNowOption> _parsePayNowOptions(
    dynamic raw, {
    String? orderPaymentMethod,
  }) {
    return PayNowHelper.parsePayNowOptions(
      raw,
      orderPaymentMethod: orderPaymentMethod,
    );
  }

  void _snack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _hydrate() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;

    final orderFuture = ref.read(ordersRepositoryProvider).getOrder(orderId);
    final walletFuture = ref.read(walletRepositoryProvider).fetchWallet();
    final order = await orderFuture;
    final wallet = await walletFuture;
    if (!mounted) return;

    final balanceNum = wallet.balance ?? parseMoney(wallet.balanceLabel) ?? 0;
    final balanceText = 'Balance ${formatBhd(balanceNum)}';

    if (order == null) {
      setState(() {
        _balance = balanceText;
      });
      return;
    }

    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final method = order['paymentMethod']?.toString() ?? '';
    final paymentStatus =
        order['paymentStatus']?.toString() ??
        (order['payment'] is Map
            ? (order['payment'] as Map)['status']?.toString()
            : null);
    final status = (order['status']?.toString() ?? '').toUpperCase();
    final deadline = DateTime.tryParse(
      order['paymentDeadline']?.toString() ?? '',
    )?.toLocal();
    final left = deadline?.difference(DateTime.now()).inSeconds;
    final options = _parsePayNowOptions(
      order['availablePaymentMethods'],
      orderPaymentMethod: method.isNotEmpty ? method : null,
    );
    final totalNum = parseMoney(order['totalAmount']) ?? 0;
    final discountNum = parseMoney(order['discountAmount']) ?? 0;
    final pickupDiscountNum = parseMoney(order['pickupDiscountAmount']) ?? 0;
    final deliveryNum = parseMoney(order['deliveryFee']) ?? 0;
    final tipNum = parseMoney(order['tipAmount']) ?? 0;
    final vatNum = parseMoney(order['vatAmount']) ?? 0;

    setState(() {
      _balance = balanceText;
      _paymentOptions = options;
      _totalAmount = totalNum;
      if (vendorName != null && vendorName.isNotEmpty) _vendor = vendorName;
      if (method.isNotEmpty) {
        _methodApi = method.toUpperCase();
        _method = formatPaymentMethod(method);
      }
      _subtotal = formatBhd(order['subtotal']);
      _serviceFee = formatBhd(order['serviceFee']);
      _total = formatBhd(totalNum);
      if (discountNum > 0) {
        _discountLabel = 'Discount';
        _discountValue = '− ${formatBhd(discountNum)}';
      } else if (pickupDiscountNum > 0) {
        _discountLabel = 'Pickup discount';
        _discountValue = '− ${formatBhd(pickupDiscountNum)}';
      } else {
        _discountLabel = null;
        _discountValue = null;
      }
      _deliveryFee = deliveryNum > 0 ? formatBhd(deliveryNum) : null;
      _tip = tipNum > 0 ? formatBhd(tipNum) : null;
      _vat = vatNum > 0 ? formatBhd(vatNum) : null;
      if (left != null) {
        if (left > 0) {
          _secondsLeft = left;
        } else if (!_isPaidOrCash(method, paymentStatus)) {
          _secondsLeft = 0;
        }
      }
    });

    // Only leave pay-now after real authorization — never for CASH shortcut.
    final settled = (paymentStatus ?? '').toUpperCase();
    if (settled == 'PAID' || settled == 'AUTHORIZED') {
      _timer?.cancel();
      context.pushReplacement(OrderFlowRoutes.confirmedFor(orderId));
      return;
    }

    if (status == 'CANCELLED' ||
        status == 'EXPIRED' ||
        (left != null && left <= 0)) {
      await _onPaymentWindowExpired(alreadyCancelled: status == 'CANCELLED');
    }
  }

  Future<void> _onPaymentWindowExpired({bool alreadyCancelled = false}) async {
    if (_expiring || _expired || _paying) return;
    _expiring = true;
    _timer?.cancel();
    final orderId = widget.orderId;
    if (!alreadyCancelled && orderId != null && orderId.isNotEmpty) {
      await ref
          .read(ordersRepositoryProvider)
          .cancel(orderId, reason: 'Payment window expired');
    }
    if (!mounted) return;
    setState(() {
      _expired = true;
      _secondsLeft = 0;
      _expiring = false;
    });
    _snack(
      'Payment window expired — order cancelled',
      color: const Color(0xFFB42318),
    );
    context.go('${RouteNames.home}?tab=1');
  }

  Future<void> _changePayment() async {
    if (_expired || _methodBusy || _paying) return;
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;

    setState(() => _methodBusy = true);
    try {
      final selected = await PayNowHelper(ref, context).showMethodSheet(
        options: _paymentOptions,
        currentApi: _methodApi,
        balanceLabel: _balance,
      );
      // Absorb sheet-close tap bleed into the Pay button.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      if (selected == null) return;
      if (PayNowHelper.methodsMatch(selected, _methodApi)) {
        _payArmedAt = DateTime.now().add(const Duration(milliseconds: 400));
        return;
      }

      final ok = await ref
          .read(ordersRepositoryProvider)
          .changePaymentMethod(orderId, selected);
      if (!mounted) return;
      if (!ok) {
        _snack('Could not change payment method — try again');
        return;
      }
      setState(() {
        _methodApi = selected;
        _method = formatPaymentMethod(selected);
        _payArmedAt = DateTime.now().add(const Duration(milliseconds: 400));
      });
    } finally {
      if (mounted) setState(() => _methodBusy = false);
    }
  }

  Future<bool> _ensureAwaitingPayment(String orderId) async {
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (order == null) {
      _snack('Order not found', color: const Color(0xFFB42318));
      return false;
    }
    final paymentStatus =
        order['paymentStatus']?.toString() ??
        (order['payment'] is Map
            ? (order['payment'] as Map)['status']?.toString()
            : null);
    final settled = (paymentStatus ?? '').toUpperCase();
    if (settled == 'PAID' || settled == 'AUTHORIZED') {
      _timer?.cancel();
      if (mounted) {
        context.pushReplacement(OrderFlowRoutes.confirmedFor(orderId));
      }
      return false;
    }
    if (!PayNowHelper.canCollectPayment(order)) {
      _snack(
        'This order is not awaiting payment',
        color: const Color(0xFFB42318),
      );
      return false;
    }
    final method = (order['paymentMethod']?.toString() ?? '').toUpperCase();
    if (method.isNotEmpty && method != _methodApi) {
      setState(() {
        _methodApi = method;
        _method = formatPaymentMethod(method);
      });
    }
    return true;
  }

  Future<void> _pay() async {
    if (_paying || _expired || _methodBusy || _secondsLeft <= 0) return;
    final armed = _payArmedAt;
    if (armed != null && DateTime.now().isBefore(armed)) {
      // Ignore accidental tap-through from the payment-method sheet.
      return;
    }
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      _snack('Order not found', color: const Color(0xFFB42318));
      return;
    }
    setState(() => _paying = true);
    try {
      final canPay = await _ensureAwaitingPayment(orderId);
      if (!canPay || !mounted) return;
      final helper = PayNowHelper(ref, context);
      final ok = await helper.pay(
        orderIds: [orderId],
        methodApi: _methodApi,
        totalAmount: _totalAmount,
      );
      if (!ok || !mounted) return;
      _timer?.cancel();
      context.pushReplacement(OrderFlowRoutes.confirmedFor(orderId));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          PickupAcceptedBanner(vendorName: _vendor),
          SizedBox(height: 14.h),
          PickupPayTimerCard(
            timerLabel: _timerLabel,
            hint: OrderFlowStrings.payWithinHint,
          ),
          SizedBox(height: 14.h),
          PickupPayMethodCard(
            methodLabel: _method,
            balanceLabel: _subtitleForMethod(_methodApi),
            onChange: _expired ? null : _changePayment,
          ),
          SizedBox(height: 14.h),
          PickupPayBreakdownCard(
            subtotal: _subtotal,
            discountLabel: _discountLabel,
            discountValue: _discountValue,
            deliveryFee: _deliveryFee,
            serviceFee: _serviceFee,
            vat: _vat,
            tip: _tip,
            total: _total,
          ),
        ],
      ),
      bottom: PickupPayStickyFooter(
        timerLabel: _timerLabel,
        payAmount: _total,
        onPay: (_paying || _expired || _methodBusy || _secondsLeft <= 0)
            ? () {}
            : _pay,
      ),
    );
  }
}
