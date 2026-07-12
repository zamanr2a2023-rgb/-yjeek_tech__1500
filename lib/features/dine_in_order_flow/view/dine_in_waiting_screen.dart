import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class DineInWaitingScreen extends StatefulWidget {
  const DineInWaitingScreen({super.key});

  @override
  State<DineInWaitingScreen> createState() => _DineInWaitingScreenState();
}

class _DineInWaitingScreenState extends State<DineInWaitingScreen> {
  static const _totalSeconds = 300;
  static const Color _screenBg = Color(0xFF8BAE9A);

  late int _secondsLeft;
  Timer? _timer;
  Timer? _acceptTimer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 0) return;
      setState(() => _secondsLeft--);
    });
    _acceptTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.pushReplacement(DineInOrderFlowRoutes.pay);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _acceptTimer?.cancel();
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
      backgroundColor: _screenBg,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 12.h),
          Center(child: DineInCountdownCircle(label: _timerLabel)),
          SizedBox(height: 16.h),
          Text(
            DineInOrderFlowStrings.sentToVendor,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
              height: 1.23,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            DineInOrderFlowStrings.waitingSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: const Color(0xFFCFE8D9)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              height: 1.25,
            ),
          ),
          SizedBox(height: 16.h),
          const DineInSecureBanner(message: DineInOrderFlowStrings.notChargedYet),
          SizedBox(height: 16.h),
          const DineInOrderSummaryRow(),
          SizedBox(height: 24.h),
          OrderOutlineButton(
            label: DineInOrderFlowStrings.cancelOrder,
            onPressed: () {
              _timer?.cancel();
              _acceptTimer?.cancel();
              context.go('${RouteNames.home}?tab=1');
            },
          ),
          SizedBox(height: 6.h),
          Text(
            DineInOrderFlowStrings.freeCancelHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: const Color(0xFFCFE8D9)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
