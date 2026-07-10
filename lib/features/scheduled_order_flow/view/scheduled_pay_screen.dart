import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class ScheduledPayScreen extends StatefulWidget {
  const ScheduledPayScreen({super.key});

  @override
  State<ScheduledPayScreen> createState() => _ScheduledPayScreenState();
}

class _ScheduledPayScreenState extends State<ScheduledPayScreen> {
  static const _totalSeconds = 299;
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
          const ScheduledAcceptedBanner(),
          SizedBox(height: 14.h),
          ScheduledPayTimerCard(timerLabel: _timerLabel),
          SizedBox(height: 14.h),
          const ScheduledPayMethodCard(),
          SizedBox(height: 14.h),
          const ScheduledPayBreakdownCard(),
        ],
      ),
      bottom: ScheduledPayStickyFooter(
        timerLabel: _timerLabel,
        onPay: () => context.pushReplacement(ScheduledOrderFlowRoutes.confirmed),
      ),
    );
  }
}
