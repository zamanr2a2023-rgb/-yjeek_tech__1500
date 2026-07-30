import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesPayScreen extends ConsumerStatefulWidget {
  const ServicesPayScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<ServicesPayScreen> createState() => _ServicesPayScreenState();
}

class _ServicesPayScreenState extends ConsumerState<ServicesPayScreen> {
  static const _defaultSeconds = 299;

  late int _secondsLeft;
  Timer? _timer;
  bool _paying = false;
  String _vendor = ServicesOrderFlowData.providerName;
  String _method = ServicesOrderFlowStrings.yjeekWallet;
  String _balance = ServicesOrderFlowData.walletBalance;
  String _subtotal = ServicesOrderFlowData.subtotalAmount;
  String _serviceFee = ServicesOrderFlowData.serviceFeeAmount;
  String _total = ServicesOrderFlowData.payTotal;

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

  String get _circleTimerLabel {
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
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;

    final orderFuture = ref.read(ordersRepositoryProvider).getOrder(orderId);
    final walletFuture = ref.read(walletRepositoryProvider).fetchWallet();
    final order = await orderFuture;
    final wallet = await walletFuture;
    if (!mounted) return;

    final balanceText = wallet.balance != null
        ? 'Balance ${formatBhd(wallet.balance)}'
        : (wallet.balanceLabel.isNotEmpty && wallet.balanceLabel != '___'
            ? 'Balance ${wallet.balanceLabel}'
            : _balance);

    if (order == null) {
      setState(() => _balance = balanceText);
      return;
    }

    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final method = order['paymentMethod']?.toString() ?? '';
    final paymentStatus = order['paymentStatus']?.toString() ??
        (order['payment'] is Map
            ? (order['payment'] as Map)['status']?.toString()
            : null);
    final deadline =
        DateTime.tryParse(order['paymentDeadline']?.toString() ?? '')
            ?.toLocal();
    final left = deadline?.difference(DateTime.now()).inSeconds;

    setState(() {
      _balance = balanceText;
      if (vendorName != null && vendorName.isNotEmpty) _vendor = vendorName;
      _method = formatPaymentMethod(method);
      _subtotal = formatBhd(order['subtotal']);
      _serviceFee = formatBhd(order['serviceFee']);
      _total = formatBhd(order['totalAmount']);
      if (left != null && left > 0) _secondsLeft = left;
    });

    if (_isPaidOrCash(method, paymentStatus)) {
      _timer?.cancel();
      context.pushReplacement(
        ServicesOrderFlowRoutes.confirmedFor(orderId),
      );
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
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      context.pushReplacement(ServicesOrderFlowRoutes.confirmed);
      return;
    }
    if (_paying) return;
    setState(() => _paying = true);
    try {
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
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Try again.')),
        );
        return;
      }
      _timer?.cancel();
      context.pushReplacement(ServicesOrderFlowRoutes.confirmedFor(orderId));
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
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          ServicesAcceptedBanner(vendorName: _vendor),
          SizedBox(height: 14.h),
          ServicesPayTimerCard(timerLabel: _circleTimerLabel),
          SizedBox(height: 14.h),
          ServicesPayMethodCard(
            methodLabel: _method,
            balanceLabel: _balance,
            onChange: _changePayment,
          ),
          SizedBox(height: 14.h),
          ServicesPayBreakdownCard(
            subtotal: _subtotal,
            serviceFee: _serviceFee,
            total: _total,
          ),
        ],
      ),
      bottom: ServicesPayStickyFooter(
        timerLabel: _footerTimerLabel,
        payAmount: _total,
        onPay: _paying ? () {} : _pay,
      ),
    );
  }
}
