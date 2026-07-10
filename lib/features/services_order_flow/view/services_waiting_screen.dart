import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ServicesWaitingScreen extends StatefulWidget {
  const ServicesWaitingScreen({super.key});

  @override
  State<ServicesWaitingScreen> createState() => _ServicesWaitingScreenState();
}

class _ServicesWaitingScreenState extends State<ServicesWaitingScreen> {
  static const _totalSeconds = 300;
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
      context.pushReplacement(ServicesOrderFlowRoutes.pay);
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
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          Center(child: ServicesWaitingTimer(label: _timerLabel)),
          SizedBox(height: 16.h),
          Text(
            ServicesOrderFlowStrings.sentToProvider,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ServicesOrderFlowStrings.waitingSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
              fontSize: 14.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 16.h),
          const ServicesInfoBanner(),
          SizedBox(height: 16.h),
          const ServicesBookingSummaryRow(),
          SizedBox(height: 24.h),
          OrderOutlineButton(
            label: ServicesOrderFlowStrings.cancelBooking,
            onPressed: () => context.go('${RouteNames.home}?tab=1'),
          ),
          SizedBox(height: 10.h),
          Text(
            ServicesOrderFlowStrings.freeCancelHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
