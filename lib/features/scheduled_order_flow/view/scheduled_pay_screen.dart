import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';

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
  String _vendor = '—';
  String _method = '—';
  String _subtotal = '—';
  String _delivery = '—';
  String _deliveryLabel = ScheduledOrderFlowStrings.sameDayDelivery;
  String _total = '—';
  int _windowSeconds = _defaultSeconds;

  String? get _primaryId =>
      widget.orderIds.isEmpty ? null : widget.orderIds.first;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _defaultSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 0) return;
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

  bool _isPaidOrCash(String? method, String? paymentStatus) {
    final m = (method ?? '').toUpperCase();
    final p = (paymentStatus ?? '').toUpperCase();
    if (p == 'PAID' || p == 'AUTHORIZED') return true;
    return m == 'CASH' || m == 'COD' || m == 'CASH_ON_DELIVERY';
  }

  Future<void> _hydrate() async {
    final ids = widget.orderIds;
    if (ids.isEmpty) return;

    var total = 0.0;
    var subtotal = 0.0;
    var delivery = 0.0;
    String? vendorName;
    String? method;
    String? deliverySpeed;
    DateTime? minDeadline;
    var allPaid = true;

    for (final id in ids) {
      final order = await ref.read(ordersRepositoryProvider).getOrder(id);
      if (order == null) continue;
      total += (order['totalAmount'] as num?)?.toDouble() ?? 0;
      subtotal += (order['subtotal'] as num?)?.toDouble() ?? 0;
      delivery += (order['deliveryFee'] as num?)?.toDouble() ?? 0;
      vendorName ??= (order['vendor'] is Map)
          ? (order['vendor'] as Map)['name']?.toString()
          : null;
      method ??= order['paymentMethod']?.toString();
      deliverySpeed ??= order['deliverySpeed']?.toString();
      final paymentStatus = order['paymentStatus']?.toString() ??
          (order['payment'] is Map
              ? (order['payment'] as Map)['status']?.toString()
              : null);
      if (!_isPaidOrCash(method, paymentStatus)) allPaid = false;
      final deadline =
          DateTime.tryParse(order['paymentDeadline']?.toString() ?? '')
              ?.toLocal();
      if (deadline != null &&
          (minDeadline == null || deadline.isBefore(minDeadline))) {
        minDeadline = deadline;
      }
    }

    if (!mounted) return;
    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) _vendor = vendorName;
      if (method != null) _method = formatPaymentMethod(method);
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
        }
      }
    });

    if (allPaid) {
      _timer?.cancel();
      context.pushReplacement(
        ScheduledOrderFlowRoutes.confirmedFor(widget.orderIds),
      );
    }
  }

  Future<void> _changePayment() async {
    final orderId = _primaryId;
    if (orderId == null) return;
    const options = <(String, String)>[
      ('YJEEK_WALLET', 'Yjeek Wallet'),
      ('CARD', 'Card'),
      ('BENEFIT_PAY', 'BenefitPay'),
      ('APPLE_PAY', 'Apple Pay'),
      ('CASH', 'Cash'),
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final opt in options)
              ListTile(
                title: Text(opt.$2),
                onTap: () => Navigator.pop(ctx, opt.$1),
              ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    for (final id in widget.orderIds) {
      await ref
          .read(ordersRepositoryProvider)
          .changePaymentMethod(id, selected);
    }
    if (!mounted) return;
    setState(() => _method = formatPaymentMethod(selected));
  }

  Future<void> _pay() async {
    if (_paying) return;
    final ids = widget.orderIds;
    if (ids.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order not found')),
      );
      return;
    }
    setState(() => _paying = true);
    try {
      var allOk = true;
      for (final id in ids) {
        final initiated =
            await ref.read(ordersRepositoryProvider).initiatePayment(id);
        final gatewayRef = initiated?['gatewayRef']?.toString();
        var ok = await ref.read(ordersRepositoryProvider).confirmPayment(
              id,
              status: 'PAID',
              gatewayRef: gatewayRef,
            );
        if (!ok) {
          final order = await ref.read(ordersRepositoryProvider).getOrder(id);
          final paymentStatus = order?['paymentStatus']?.toString() ??
              (order?['payment'] is Map
                  ? (order!['payment'] as Map)['status']?.toString()
                  : null);
          ok = paymentStatus == 'PAID' || paymentStatus == 'AUTHORIZED';
        }
        if (!ok) allOk = false;
      }
      if (!mounted) return;
      if (!allOk) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Try again.')),
        );
        return;
      }
      _timer?.cancel();
      context.pushReplacement(ScheduledOrderFlowRoutes.confirmedFor(ids));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
            onChange: _changePayment,
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
        onPay: _paying ? () {} : _pay,
      ),
    );
  }
}
