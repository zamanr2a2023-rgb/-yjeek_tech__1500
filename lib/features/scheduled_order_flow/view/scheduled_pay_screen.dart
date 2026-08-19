import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';
import 'package:yjeek_app/features/payments/pay_now_helper.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ScheduledPayScreen extends ConsumerStatefulWidget {
  const ScheduledPayScreen({super.key, this.orderIds = const []});

  final List<String> orderIds;

  @override
  ConsumerState<ScheduledPayScreen> createState() => _ScheduledPayScreenState();
}

class _ScheduledPayScreenState extends ConsumerState<ScheduledPayScreen> {
  static const _defaultSeconds = 299;

  late int _secondsLeft;
  Timer? _timer;
  bool _paying = false;
  bool _expiring = false;
  bool _expired = false;
  bool _methodBusy = false;
  DateTime? _payArmedAt;
  String _vendor = '—';
  String _method = 'BenefitPay';
  String _methodApi = 'BENEFIT_PAY';
  String _balance = 'Balance BHD 0.000';
  num _totalAmount = 0;
  String _subtotal = '—';
  String _delivery = '—';
  String _deliveryLabel = ScheduledOrderFlowStrings.sameDayDelivery;
  String _total = '—';
  int _windowSeconds = _defaultSeconds;
  List<PayNowOption> _paymentOptions =
      List.of(PayNowHelper.defaultPaymentOptions);

  PayNowHelper get _payHelper => PayNowHelper(ref, context);

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
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _footerTimerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _hydrate() async {
    final ids = widget.orderIds;
    if (ids.isEmpty) return;

    final wallet = await ref.read(walletRepositoryProvider).fetchWallet();
    final balanceNum = wallet.balance ?? parseMoney(wallet.balanceLabel) ?? 0;
    final balanceText = 'Balance ${formatBhd(balanceNum)}';

    var total = 0.0;
    var subtotal = 0.0;
    var delivery = 0.0;
    String? vendorName;
    String? method;
    String? deliverySpeed;
    DateTime? minDeadline;
    var allPaid = true;
    dynamic availableMethods;
    var anyUnpaidExpired = false;

    for (final id in ids) {
      final order = await ref.read(ordersRepositoryProvider).getOrder(id);
      if (order == null) continue;
      total += (parseMoney(order['totalAmount']) ?? 0).toDouble();
      subtotal += (parseMoney(order['subtotal']) ?? 0).toDouble();
      delivery += (parseMoney(order['deliveryFee']) ?? 0).toDouble();
      vendorName ??= (order['vendor'] is Map)
          ? (order['vendor'] as Map)['name']?.toString()
          : null;
      method ??= order['paymentMethod']?.toString();
      deliverySpeed ??= order['deliverySpeed']?.toString();
      availableMethods ??= order['availablePaymentMethods'];
      final paymentStatus = PayNowHelper.paymentStatusOf(order);
      if (!PayNowHelper.isSettled(paymentStatus)) allPaid = false;
      final status = (order['status']?.toString() ?? '').toUpperCase();
      final deadline =
          DateTime.tryParse(order['paymentDeadline']?.toString() ?? '')
              ?.toLocal();
      if (deadline != null &&
          (minDeadline == null || deadline.isBefore(minDeadline))) {
        minDeadline = deadline;
      }
      if (!PayNowHelper.isSettled(paymentStatus) &&
          (status == 'CANCELLED' ||
              status == 'EXPIRED' ||
              (deadline != null && deadline.isBefore(DateTime.now())))) {
        anyUnpaidExpired = true;
      }
    }

    if (!mounted) return;
    setState(() {
      _balance = balanceText;
      _totalAmount = total;
      _paymentOptions = PayNowHelper.parsePayNowOptions(
        availableMethods,
        orderPaymentMethod: method,
      );
      if (vendorName != null && vendorName.isNotEmpty) _vendor = vendorName;
      if (method != null && method.isNotEmpty) {
        _methodApi = method.toUpperCase();
        _method = formatPaymentMethod(method);
      }
      if (deliverySpeed != null) {
        _deliveryLabel = scheduledDeliveryFeeLabel(deliverySpeed);
      }
      _subtotal = formatBhd(subtotal);
      _delivery = formatBhd(delivery);
      _total = formatBhd(total);
      if (minDeadline != null) {
        final left = minDeadline.difference(DateTime.now()).inSeconds;
        if (left > 0) {
          _secondsLeft = left;
          _windowSeconds = left;
        } else if (!allPaid) {
          _secondsLeft = 0;
        }
      }
    });

    if (allPaid) {
      _timer?.cancel();
      context.pushReplacement(
        ScheduledOrderFlowRoutes.confirmedFor(widget.orderIds),
      );
      return;
    }

    if (anyUnpaidExpired || _secondsLeft <= 0) {
      await _onPaymentWindowExpired();
    }
  }

  Future<void> _onPaymentWindowExpired({bool alreadyCancelled = false}) async {
    if (_expiring || _expired || _paying) return;
    _expiring = true;
    _timer?.cancel();
    if (!alreadyCancelled) {
      for (final id in widget.orderIds) {
        await ref.read(ordersRepositoryProvider).cancel(
              id,
              reason: 'Payment window expired',
            );
      }
    }
    if (!mounted) return;
    setState(() {
      _expired = true;
      _secondsLeft = 0;
      _expiring = false;
    });
    _payHelper.snack(
      'Payment window expired — order cancelled',
      color: const Color(0xFFB42318),
    );
    context.go('${RouteNames.home}?tab=1');
  }

  Future<void> _changePayment() async {
    if (_expired || _methodBusy || _paying || widget.orderIds.isEmpty) return;

    setState(() => _methodBusy = true);
    try {
      final selected = await _payHelper.showMethodSheet(
        options: _paymentOptions,
        currentApi: _methodApi,
        balanceLabel: _balance,
      );
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      if (selected == null) return;
      if (PayNowHelper.methodsMatch(selected, _methodApi)) {
        _payArmedAt = DateTime.now().add(const Duration(milliseconds: 400));
        return;
      }
      final ok = await _payHelper.changeMethod(
        orderIds: widget.orderIds,
        selected: selected,
      );
      if (!ok || !mounted) return;
      setState(() {
        _methodApi = selected;
        _method = formatPaymentMethod(selected);
        _payArmedAt = DateTime.now().add(const Duration(milliseconds: 400));
      });
    } finally {
      if (mounted) setState(() => _methodBusy = false);
    }
  }

  Future<void> _pay() async {
    if (_paying || _expired || _methodBusy || _secondsLeft <= 0) return;
    final armed = _payArmedAt;
    if (armed != null && DateTime.now().isBefore(armed)) return;
    final ids = widget.orderIds;
    if (ids.isEmpty) {
      _payHelper.snack('Order not found', color: const Color(0xFFB42318));
      return;
    }
    setState(() => _paying = true);
    try {
      final ok = await _payHelper.pay(
        orderIds: ids,
        methodApi: _methodApi,
        totalAmount: _totalAmount,
      );
      if (!ok || !mounted) return;
      _timer?.cancel();
      context.pushReplacement(ScheduledOrderFlowRoutes.confirmedFor(ids));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          ScheduledAcceptedBanner(vendorName: _vendor),
          SizedBox(height: 14.h),
          ScheduledPayTimerCard(
            timerLabel: _timerLabel,
            progress: _windowSeconds <= 0
                ? 0
                : (_secondsLeft / _windowSeconds).clamp(0.0, 1.0),
          ),
          SizedBox(height: 14.h),
          ScheduledPayMethodCard(
            methodLabel: _method,
            balanceLabel:
                PayNowHelper.subtitleForMethod(_methodApi, _balance),
            isWallet: PayNowHelper.isWallet(_methodApi),
            onChange: _expired ? null : _changePayment,
          ),
          SizedBox(height: 14.h),
          ScheduledPayBreakdownCard(
            subtotal: _subtotal,
            delivery: _delivery,
            deliveryLabel: _deliveryLabel,
            total: _total,
          ),
        ],
      ),
      bottom: ScheduledPayStickyFooter(
        timerLabel: _footerTimerLabel,
        payAmount: _total,
        onPay: (_paying || _expired || _methodBusy || _secondsLeft <= 0)
            ? () {}
            : _pay,
      ),
    );
  }
}
