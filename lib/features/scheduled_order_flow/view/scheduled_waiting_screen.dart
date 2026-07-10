import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ScheduledWaitingScreen extends StatefulWidget {
  const ScheduledWaitingScreen({super.key});

  @override
  State<ScheduledWaitingScreen> createState() => _ScheduledWaitingScreenState();
}

class _ScheduledWaitingScreenState extends State<ScheduledWaitingScreen> {
  Timer? _acceptTimer;

  @override
  void initState() {
    super.initState();
    _acceptTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.pushReplacement(ScheduledOrderFlowRoutes.pay);
    });
  }

  @override
  void dispose() {
    _acceptTimer?.cancel();
    super.dispose();
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
          const Center(child: ScheduledWaitingTimer()),
          SizedBox(height: 10.h),
          const Center(child: ScheduledWaitingDots()),
          SizedBox(height: 16.h),
          Text(
            ScheduledOrderFlowStrings.sentToVendor,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ScheduledOrderFlowStrings.waitingSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
              fontSize: 14.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 16.h),
          const ScheduledSecureBanner(),
          SizedBox(height: 16.h),
          const ScheduledOrderSummaryRow(),
          SizedBox(height: 24.h),
          OrderOutlineButton(
            label: ScheduledOrderFlowStrings.cancelOrder,
            onPressed: () => context.go('${RouteNames.home}?tab=1'),
          ),
          SizedBox(height: 10.h),
          Text(
            ScheduledOrderFlowStrings.freeCancelHint,
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
