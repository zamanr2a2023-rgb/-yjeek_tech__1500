import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';

/// Food delivery: pay after vendor accept (5 min window — same chrome as other flows).
class OrderPayScreen extends StatefulWidget {
  const OrderPayScreen({super.key});

  @override
  State<OrderPayScreen> createState() => _OrderPayScreenState();
}

class _OrderPayScreenState extends State<OrderPayScreen> {
  static const _totalSeconds = 299; // 5 min
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 0) return;
      setState(() => _secondsLeft--);
    });
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
        ],
      ),
      bottom: PickupPayStickyFooter(
        timerLabel: _timerLabel,
        onPay: () {
          _timer?.cancel();
          context.pushReplacement(OrderFlowRoutes.confirmed);
        },
      ),
    );
  }
}
