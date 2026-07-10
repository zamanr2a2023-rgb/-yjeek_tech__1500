import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';

class PickupConfirmedScreen extends StatelessWidget {
  const PickupConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
          const Center(child: PickupConfirmedIcon()),
          SizedBox(height: 16.h),
          Text(
            PickupOrderFlowStrings.orderConfirmed,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            PickupOrderFlowStrings.preparedForPickup,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 20.h),
          const PickupOrderDetailsCard(),
          SizedBox(height: 20.h),
          PrimaryGreenButton(
            label: PickupOrderFlowStrings.trackOrder,
            onPressed: () => context.push(PickupOrderFlowRoutes.status),
          ),
          SizedBox(height: 12.h),
          OrderOutlineButton(
            label: PickupOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(PickupOrderFlowRoutes.receipt),
          ),
        ],
      ),
    );
  }
}
