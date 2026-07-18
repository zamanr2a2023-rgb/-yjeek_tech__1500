import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';

class ScheduledConfirmedScreen extends StatelessWidget {
  const ScheduledConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma E · Order confirmed: mint check, #F2F7F2 bg, Track #2E9E4D h52.
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const Center(child: ScheduledConfirmedIcon()),
          SizedBox(height: 14.h),
          Text(
            ScheduledOrderFlowStrings.orderConfirmed,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium(color: const Color(0xFF1A1A1A)).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ScheduledOrderFlowStrings.preparedForDelivery,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: const Color(0xFF6B756E)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 1.25,
            ),
          ),
          SizedBox(height: 14.h),
          const ScheduledOrderDetailsCard(),
          SizedBox(height: 14.h),
          PrimaryGreenButton(
            label: ScheduledOrderFlowStrings.trackOrder,
            backgroundColor: const Color(0xFF2E9E4D),
            height: 52,
            onPressed: () => context.push(ScheduledOrderFlowRoutes.status),
          ),
          SizedBox(height: 12.h),
          OrderOutlineButton(
            label: ScheduledOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(ScheduledOrderFlowRoutes.receipt),
          ),
        ],
      ),
    );
  }
}
