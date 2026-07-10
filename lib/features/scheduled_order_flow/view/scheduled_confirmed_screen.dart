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
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const Center(child: ScheduledConfirmedIcon()),
          SizedBox(height: 16.h),
          Text(
            ScheduledOrderFlowStrings.orderConfirmed,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ScheduledOrderFlowStrings.preparedForDelivery,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 20.h),
          const ScheduledOrderDetailsCard(),
          SizedBox(height: 20.h),
          PrimaryGreenButton(
            label: ScheduledOrderFlowStrings.trackOrder,
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
