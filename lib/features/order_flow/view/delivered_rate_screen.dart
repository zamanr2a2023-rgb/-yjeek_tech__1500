import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class DeliveredRateScreen extends StatelessWidget {
  const DeliveredRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          const Align(
            alignment: Alignment.centerLeft,
            child: OrderSuccessIcon(size: 64),
          ),
          SizedBox(height: 14.h),
          Text(
            OrderFlowStrings.delivered,
            style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 29 / 24,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            OrderFlowStrings.deliveredSubtitle,
            style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
          SizedBox(height: 14.h),
          const OrderStarRatingCard(title: OrderFlowStrings.rateYourOrder),
          SizedBox(height: 14.h),
          OrderStarRatingCard(
            title: '${OrderFlowStrings.rateYourChamp} · ${OrderFlowData.driverName}',
          ),
          SizedBox(height: 14.h),
          PrimaryGreenButton(
            label: OrderFlowStrings.submitAndDone,
            backgroundColor: AppColors.cartTabActive,
            height: 52,
            onPressed: () => context.goHome(tab: 1),
          ),
          SizedBox(height: 14.h),
          OrderReorderButton(
            onPressed: () => context.goHome(tab: 2, cartHasItems: true),
          ),
        ],
      ),
    );
  }
}
