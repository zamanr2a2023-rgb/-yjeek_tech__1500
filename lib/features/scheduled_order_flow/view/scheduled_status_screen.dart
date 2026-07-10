import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';

class ScheduledStatusScreen extends StatelessWidget {
  const ScheduledStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: ScheduledOrderFlowStrings.orderStatus,
      subtitle: ScheduledOrderFlowData.statusSubtitle,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const OrderMapPlaceholder(),
          SizedBox(height: 14.h),
          const ScheduledLiveMapBanner(),
          SizedBox(height: 10.h),
          const ScheduledPackedBanner(),
          SizedBox(height: 14.h),
          ScheduledStatusTimeline(steps: ScheduledOrderFlowData.statusTimeline),
          SizedBox(height: 14.h),
          const ScheduledStatusSummaryCard(),
          SizedBox(height: 14.h),
          OrderOutlineButton(
            label: ScheduledOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(ScheduledOrderFlowRoutes.receipt),
          ),
        ],
      ),
    );
  }
}
