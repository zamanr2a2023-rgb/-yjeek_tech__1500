import 'package:flutter/material.dart';
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
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const Center(child: OrderSuccessIcon(size: 64)),
          SizedBox(height: 18.h),
          Text(
            OrderFlowStrings.delivered,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            OrderFlowStrings.deliveredSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
          const OrderStarRatingCard(title: OrderFlowStrings.rateYourOrder),
          SizedBox(height: 12.h),
          OrderStarRatingCard(
            title: '${OrderFlowStrings.rateYourChamp} · ${OrderFlowData.driverName}',
          ),
          SizedBox(height: 24.h),
          PrimaryGreenButton(
            label: OrderFlowStrings.submitAndDone,
            onPressed: () => context.goHome(tab: 1),
          ),
          SizedBox(height: 16.h),
          OrderReorderButton(onPressed: () => context.goHome(tab: 2, cartHasItems: true)),
        ],
      ),
    );
  }
}
