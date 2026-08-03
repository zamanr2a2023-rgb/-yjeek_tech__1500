import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';

/// Food delivery: pay after vendor accept.
class OrderPayScreen extends ConsumerStatefulWidget {
  const OrderPayScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderPayScreen> createState() => _OrderPayScreenState();
}

class _OrderPayScreenState extends ConsumerState<OrderPayScreen> {
  static const _totalSeconds = 299;
  late int _secondsLeft;
  Timer? _timer;
  bool _paying = false;
  String _totalLabel = 'BHD —';
  String _methodLabel = 'Card / BenefitPay';

  @override
  void initState() {
    super.initState();
    _secondsLeft = _totalSeconds;
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

  bool _isPaidOrCash(String? method, String? paymentStatus) {
    final m = (method ?? '').toUpperCase();
    final p = (paymentStatus ?? '').toUpperCase();
    if (p == 'PAID' || p == 'AUTHORIZED') return true;
    return m == 'CASH' || m == 'COD' || m == 'CASH_ON_DELIVERY';
  }

  Future<void> _hydrate() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (!mounted || order == null) return;
    final total = order['totalAmount'];
    final method = order['paymentMethod']?.toString() ?? '';
    final paymentStatus = order['paymentStatus']?.toString() ??
        (order['payment'] is Map
            ? (order['payment'] as Map)['status']?.toString()
            : null);
    setState(() {
      _totalLabel = total is num ? formatBhd(total) : _totalLabel;
      _methodLabel = formatPaymentMethod(method);
    });
    if (_isPaidOrCash(method, paymentStatus)) {
      _timer?.cancel();
      context.pushReplacement(OrderFlowRoutes.confirmedFor(orderId));
    }
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString()}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _pay() async {
    if (_paying) return;
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      context.pushReplacement(OrderFlowRoutes.confirmed);
      return;
    }
    setState(() => _paying = true);
    final initiated =
        await ref.read(ordersRepositoryProvider).initiatePayment(orderId);
    final gatewayRef = initiated?['gatewayRef']?.toString();
    var ok = await ref.read(ordersRepositoryProvider).confirmPayment(
          orderId,
          status: 'PAID',
          gatewayRef: gatewayRef,
        );
    if (!ok) {
      // Already authorized/paid, or initiate failed — re-check order.
      final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
      final paymentStatus = order?['paymentStatus']?.toString() ??
          (order?['payment'] is Map
              ? (order!['payment'] as Map)['status']?.toString()
              : null);
      ok = paymentStatus == 'PAID' || paymentStatus == 'AUTHORIZED';
    }
    if (!mounted) return;
    setState(() => _paying = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed — try again'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }
    _timer?.cancel();
    context.pushReplacement(OrderFlowRoutes.confirmedFor(orderId));
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
          const PickupAcceptedBanner(),
          SizedBox(height: 14.h),
          PickupPayTimerCard(timerLabel: _timerLabel),
          SizedBox(height: 14.h),
          const PickupPayMethodCard(),
          SizedBox(height: 14.h),
          const PickupPayBreakdownCard(),
          SizedBox(height: 8.h),
          Text(
            '$_methodLabel · $_totalLabel',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      bottom: PickupPayStickyFooter(
        timerLabel: _timerLabel,
        onPay: _paying ? () {} : _pay,
      ),
    );
  }
}
