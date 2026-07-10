import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';

class PickupStatusScreen extends StatelessWidget {
  const PickupStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: PickupOrderFlowStrings.orderStatus,
      subtitle: PickupOrderFlowData.statusSubtitle,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const OrderMapPlaceholder(),
          SizedBox(height: 14.h),
          const PickupNotifyBanner(),
          SizedBox(height: 10.h),
          const PickupPreparingBanner(),
          SizedBox(height: 14.h),
          PickupStatusTimeline(steps: PickupOrderFlowData.statusTimeline),
          SizedBox(height: 14.h),
          const PickupStatusSummaryCard(),
          SizedBox(height: 14.h),
          OrderOutlineButton(
            label: PickupOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(PickupOrderFlowRoutes.receipt),
          ),
        ],
      ),
    );
  }
}
