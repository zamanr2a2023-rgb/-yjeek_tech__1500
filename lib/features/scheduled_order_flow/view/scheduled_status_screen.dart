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
    // Figma E · Order status: light header, #F2F7F2, Home nav, sticky View receipt.
    return OrderFlowScaffold(
      title: ScheduledOrderFlowStrings.orderStatus,
      subtitle: ScheduledOrderFlowData.statusSubtitle,
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        children: [
          const OrderMapPlaceholder(),
          SizedBox(height: 16.h),
          const ScheduledLiveMapBanner(),
          SizedBox(height: 16.h),
          const ScheduledPackedBanner(),
          SizedBox(height: 16.h),
          ScheduledStatusTimeline(steps: ScheduledOrderFlowData.statusTimeline),
          SizedBox(height: 16.h),
          const ScheduledStatusSummaryCard(),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
          child: OrderOutlineButton(
            label: ScheduledOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(ScheduledOrderFlowRoutes.receipt),
          ),
        ),
      ),
    );
  }
}
