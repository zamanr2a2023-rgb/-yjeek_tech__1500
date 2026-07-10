import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 2,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const Center(child: OrderSuccessIcon()),
          SizedBox(height: 20.h),
          Text(
            OrderFlowStrings.orderConfirmed,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            OrderFlowData.confirmedSubtitle(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
          const OrderSummaryCard(),
          SizedBox(height: 24.h),
          PrimaryGreenButton(
            label: OrderFlowStrings.trackOrder,
            onPressed: () => context.push(OrderFlowRoutes.status),
          ),
          SizedBox(height: 12.h),
          OrderOutlineButton(
            label: OrderFlowStrings.viewReceipt,
            onPressed: () => context.push(OrderFlowRoutes.receipt),
          ),
        ],
      ),
    );
  }
}
