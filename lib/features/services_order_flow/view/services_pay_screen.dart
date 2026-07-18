import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesPayScreen extends StatefulWidget {
  const ServicesPayScreen({super.key});

  @override
  State<ServicesPayScreen> createState() => _ServicesPayScreenState();
}

class _ServicesPayScreenState extends State<ServicesPayScreen> {
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

  /// Circle uses `4:59`; footer uses `04:59`.
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

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const ServicesAcceptedBanner(),
          SizedBox(height: 14.h),
          ServicesPayTimerCard(timerLabel: _circleTimerLabel),
          SizedBox(height: 14.h),
          const ServicesPayMethodCard(),
          SizedBox(height: 14.h),
          const ServicesPayBreakdownCard(),
        ],
      ),
      bottom: ServicesPayStickyFooter(
        timerLabel: _footerTimerLabel,
        onPay: () => context.pushReplacement(ServicesOrderFlowRoutes.confirmed),
      ),
    );
  }
}
