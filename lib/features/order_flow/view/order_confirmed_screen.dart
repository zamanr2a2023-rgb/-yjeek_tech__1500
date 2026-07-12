import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
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
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          const Align(
            alignment: Alignment.centerLeft,
            child: OrderSuccessIcon(),
          ),
          SizedBox(height: 14.h),
          Text(
            OrderFlowStrings.orderConfirmed,
            textAlign: TextAlign.left,
            style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 29 / 24,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            OrderFlowData.confirmedSubtitle(),
            textAlign: TextAlign.left,
            style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
          SizedBox(height: 14.h),
          const OrderSummaryCard(),
          SizedBox(height: 14.h),
          PrimaryGreenButton(
            label: OrderFlowStrings.trackOrder,
            backgroundColor: AppColors.cartTabActive,
            height: 52,
            onPressed: () => context.push(OrderFlowRoutes.status),
          ),
          SizedBox(height: 14.h),
          OrderOutlineButton(
            label: OrderFlowStrings.viewReceipt,
            onPressed: () => context.push(OrderFlowRoutes.receipt),
          ),
        ],
      ),
    );
  }
}
