import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_api_mappers.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class PickupPayScreen extends ConsumerStatefulWidget {
  const PickupPayScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<PickupPayScreen> createState() => _PickupPayScreenState();
}

class _PickupPayScreenState extends ConsumerState<PickupPayScreen> {
  static const _defaultSeconds = 119;

  late int _secondsLeft;
  Timer? _timer;
  bool _paying = false;
  bool _expiring = false;
  bool _expired = false;
  String _vendor = PickupOrderFlowData.vendorName;
  String _method = PickupOrderFlowStrings.yjeekWallet;
  String _balance = PickupOrderFlowData.walletBalance;
  String _subtotal = PickupOrderFlowData.paySubtotal;
  String? _discountLabel;
  String? _discountValue;
  String _serviceFee = PickupOrderFlowData.payServiceFee;
  String _total = PickupOrderFlowData.payTotal;

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
    final status = (order['status']?.toString() ?? '').toUpperCase();
    final deadline =
        DateTime.tryParse(order['paymentDeadline']?.toString() ?? '')
            ?.toLocal();
    final left = deadline?.difference(DateTime.now()).inSeconds;

    final pickupAmt = order['pickupDiscountAmount'];
    final pickupNum = pickupAmt is num
        ? pickupAmt.toDouble()
        : double.tryParse(pickupAmt?.toString() ?? '') ?? 0;

    setState(() {
      _balance = balanceText;
      if (vendorName != null && vendorName.isNotEmpty) _vendor = vendorName;
      _method = formatPaymentMethod(method);
      _subtotal = formatBhd(order['subtotal']);
      _serviceFee = formatBhd(order['serviceFee']);
      _total = formatBhd(order['totalAmount']);
      if (pickupNum > 0) {
        _discountLabel = pickupDiscountLabelFromOrder(order);
        _discountValue = '− ${formatBhd(pickupNum)}';
      } else {
        _discountLabel = null;
        _discountValue = null;
      }
      if (left != null) {
        if (left > 0) {
          _secondsLeft = left;
        } else if (!_isPaidOrCash(method, paymentStatus)) {
          _secondsLeft = 0;
        }
      }
    });

    if (_isPaidOrCash(method, paymentStatus)) {
      _timer?.cancel();
      context.pushReplacement(PickupOrderFlowRoutes.confirmedFor(orderId));
      return;
    }

    if (status == 'CANCELLED' || status == 'EXPIRED' || (left != null && left <= 0)) {
      await _onPaymentWindowExpired(alreadyCancelled: status == 'CANCELLED');
    }
  }

  Future<void> _onPaymentWindowExpired({bool alreadyCancelled = false}) async {
    if (_expiring || _expired || _paying) return;
    _expiring = true;
    _timer?.cancel();
    final orderId = widget.orderId;
    if (!alreadyCancelled && orderId != null && orderId.isNotEmpty) {
      await ref.read(ordersRepositoryProvider).cancel(
            orderId,
            reason: 'Payment window expired',
          );
    }
    if (!mounted) return;
    setState(() {
      _expired = true;
      _secondsLeft = 0;
      _expiring = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(PickupOrderFlowStrings.paymentExpired),
        backgroundColor: Color(0xFFB42318),
      ),
    );
    context.go('${RouteNames.home}?tab=1');
  }

  Future<void> _changePayment() async {
    if (_expired) return;
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;
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
    if (_paying || _expired || _secondsLeft <= 0) return;
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      context.pushReplacement(PickupOrderFlowRoutes.confirmed);
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
    context.pushReplacement(PickupOrderFlowRoutes.confirmedFor(orderId));
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
          PickupPayTimerCard(timerLabel: _timerLabel),
          SizedBox(height: 14.h),
          PickupPayMethodCard(
            methodLabel: _method,
            balanceLabel: _balance,
            onChange: _expired ? null : _changePayment,
          ),
          SizedBox(height: 14.h),
          PickupPayBreakdownCard(
            subtotal: _subtotal,
            discountLabel: _discountLabel,
            discountValue: _discountValue,
            serviceFee: _serviceFee,
            total: _total,
          ),
        ],
      ),
      bottom: PickupPayStickyFooter(
        timerLabel: _timerLabel,
        payAmount: _total,
        onPay: (_paying || _expired || _secondsLeft <= 0) ? () {} : _pay,
      ),
    );
  }
}
