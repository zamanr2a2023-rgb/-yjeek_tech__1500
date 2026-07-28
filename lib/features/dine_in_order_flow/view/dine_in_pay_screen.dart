import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInPayScreen extends ConsumerStatefulWidget {
  const DineInPayScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<DineInPayScreen> createState() => _DineInPayScreenState();
}

class _DineInPayScreenState extends ConsumerState<DineInPayScreen> {
  static const Color _screenBg = Color(0xFF8BAE9A);
  static const _defaultSeconds = 299;

  late int _secondsLeft;
  Timer? _timer;
  bool _paying = false;
  String _vendor = DineInOrderFlowData.vendor;
  String _method = 'Yjeek Wallet';
  String _subtotal = DineInOrderFlowData.subtotalAmount;
  String _serviceFee = DineInOrderFlowData.serviceFeeAmount;
  String _total = DineInOrderFlowData.orderTotal;

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
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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

    final vendor = order['vendor'];
    final vendorName =
        vendor is Map ? vendor['name']?.toString() : null;
    final method = order['paymentMethod']?.toString() ?? '';
    final paymentStatus = order['paymentStatus']?.toString() ??
        (order['payment'] is Map
            ? (order['payment'] as Map)['status']?.toString()
            : null);
    final deadline =
        DateTime.tryParse(order['paymentDeadline']?.toString() ?? '')
            ?.toLocal();
    if (deadline != null) {
      final left = deadline.difference(DateTime.now()).inSeconds;
      if (left > 0) _secondsLeft = left;
    }

    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) _vendor = vendorName;
      _method = formatPaymentMethod(method);
      _subtotal = formatBhd(order['subtotal']);
      _serviceFee = formatBhd(order['serviceFee']);
      _total = formatBhd(order['totalAmount']);
    });

    if (_isPaidOrCash(method, paymentStatus)) {
      _timer?.cancel();
      context.pushReplacement(DineInOrderFlowRoutes.confirmedFor(orderId));
    }
  }

  Future<void> _changePayment() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;
    const options = <(String, String)>[
      ('YJEEK_WALLET', 'Yjeek Wallet'),
      ('CARD', 'Card'),
      ('BENEFIT_PAY', 'BenefitPay'),
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
    final ok = await ref
        .read(ordersRepositoryProvider)
        .changePaymentMethod(orderId, selected);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not change payment method')),
      );
      return;
    }
    setState(() => _method = formatPaymentMethod(selected));
  }

  Future<void> _pay() async {
    if (_paying) return;
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      context.pushReplacement(DineInOrderFlowRoutes.confirmed);
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
    context.pushReplacement(DineInOrderFlowRoutes.confirmedFor(orderId));
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      backgroundColor: _screenBg,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          DineInAcceptedBanner(vendorName: _vendor),
          SizedBox(height: 14.h),
          DineInPayTimerCard(timerLabel: _timerLabel),
          SizedBox(height: 14.h),
          Text(
            DineInOrderFlowStrings.payWith,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              height: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          DineInPayMethodCard(
            methodLabel: _method,
            onChange: _changePayment,
          ),
          SizedBox(height: 14.h),
          DineInPayBreakdownCard(
            subtotal: _subtotal,
            serviceFee: _serviceFee,
            total: _total,
          ),
        ],
      ),
      bottom: DineInPayStickyFooter(
        timerLabel: _timerLabel,
        payAmount: _total,
        onPay: _paying ? () {} : _pay,
      ),
    );
  }
}
