import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    // Figma S4: timer → title → subtitle → dots → banner → summary → cancel.
    // Home nav active. Screen gap 16.
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top + 10.h),
            const Center(child: ScheduledWaitingTimer()),
            SizedBox(height: 16.h),
            Text(
              ScheduledOrderFlowStrings.sentToVendor,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium(color: const Color(0xFF1A1A1A)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 23.sp,
                height: 1.32,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              ScheduledOrderFlowStrings.waitingSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: const Color(0xFF6B7B6E)).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
                height: 1.32,
              ),
            ),
            SizedBox(height: 12.h),
            const Center(child: ScheduledWaitingDots()),
            SizedBox(height: 16.h),
            const ScheduledSecureBanner(),
            SizedBox(height: 16.h),
            const ScheduledOrderSummaryRow(),
            const Spacer(),
            _CancelOrderBlock(
              onCancel: () {
                _acceptTimer?.cancel();
                context.go('${RouteNames.home}?tab=0');
              },
            ),
            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }
}

class _CancelOrderBlock extends StatelessWidget {
  const _CancelOrderBlock({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 53.h,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF7FAF7),
              foregroundColor: const Color(0xFF1A1A1A),
              side: const BorderSide(color: Color(0xFFE2E8DD), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              ScheduledOrderFlowStrings.cancelOrder,
              style: AppTextStyles.labelMedium(
                color: const Color(0xFF1A1A1A),
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                height: 1.32,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          ScheduledOrderFlowStrings.freeCancelHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            height: 1.32,
          ),
        ),
      ],
    );
  }
}
