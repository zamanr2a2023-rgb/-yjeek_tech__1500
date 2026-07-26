import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Food delivery: wait for vendor accept (same chrome as Pickup/Vape waiting).
class OrderWaitingScreen extends StatefulWidget {
  const OrderWaitingScreen({super.key});

  @override
  State<OrderWaitingScreen> createState() => _OrderWaitingScreenState();
}

class _OrderWaitingScreenState extends State<OrderWaitingScreen> {
  Timer? _acceptTimer;

  @override
  void initState() {
    super.initState();
    _acceptTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.pushReplacement(OrderFlowRoutes.pay);
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
          const Center(child: PickupWaitingTimer()),
          SizedBox(height: 10.h),
          const Center(child: PickupWaitingDots()),
          SizedBox(height: 16.h),
          Text(
            OrderFlowStrings.sentToVendor,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            OrderFlowStrings.waitingSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 14.sp, height: 1.35),
          ),
          SizedBox(height: 16.h),
          const PickupSecureBanner(),
          SizedBox(height: 16.h),
          const PickupOrderSummaryRow(),
          SizedBox(height: 24.h),
          OrderOutlineButton(
            label: OrderFlowStrings.cancelOrder,
            onPressed: () {
              _acceptTimer?.cancel();
              context.go('${RouteNames.home}?tab=1');
            },
          ),
          SizedBox(height: 10.h),
          Text(
            OrderFlowStrings.freeCancelHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}
