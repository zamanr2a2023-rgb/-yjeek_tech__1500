import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/vape_order_flow/vape_order_flow_routes.dart';
import 'package:yjeek_app/features/vape_order_flow/view/widgets/vape_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class VapePayScreen extends StatefulWidget {
  const VapePayScreen({super.key});

  @override
  State<VapePayScreen> createState() => _VapePayScreenState();
}

class _VapePayScreenState extends State<VapePayScreen> {
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
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _footerTimerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Figma S5: Home nav, #F2F7F2, content gap 14.
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const VapeAcceptedBanner(),
          SizedBox(height: 14.h),
          VapePayTimerCard(
            timerLabel: _timerLabel,
            progress: _secondsLeft / _totalSeconds,
          ),
          SizedBox(height: 14.h),
          const VapePayMethodCard(),
          SizedBox(height: 14.h),
          const VapePayBreakdownCard(),
        ],
      ),
      bottom: VapePayStickyFooter(
        timerLabel: _footerTimerLabel,
        onPay: () => context.pushReplacement(VapeOrderFlowRoutes.confirmed),
      ),
    );
  }
}
