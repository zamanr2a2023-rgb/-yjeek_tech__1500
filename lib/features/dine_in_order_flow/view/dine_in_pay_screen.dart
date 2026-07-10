import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInPayScreen extends StatefulWidget {
  const DineInPayScreen({super.key});

  @override
  State<DineInPayScreen> createState() => _DineInPayScreenState();
}

class _DineInPayScreenState extends State<DineInPayScreen> {
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
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 1,
      body: Column(
        children: [
          const DineInAcceptedBanner(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
              children: [
                Center(
                  child: DineInCountdownCircle(
                    label: _timerLabel,
                    color: const Color(0xFFE6A700),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  DineInOrderFlowStrings.payWithinHint,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall().copyWith(
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20.h),
                const DineInPayMethodCard(),
                SizedBox(height: 14.h),
                const DineInPayBreakdownCard(),
              ],
            ),
          ),
        ],
      ),
      bottom: DineInPayStickyFooter(
        timerLabel: _timerLabel,
        onPay: () => context.pushReplacement(DineInOrderFlowRoutes.confirmed),
      ),
    );
  }
}
