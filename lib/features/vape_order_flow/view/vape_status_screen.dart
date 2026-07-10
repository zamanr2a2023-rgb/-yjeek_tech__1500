import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/vape_order_flow/model/vape_order_flow_data.dart';
import 'package:yjeek_app/features/vape_order_flow/vape_order_flow_routes.dart';
import 'package:yjeek_app/features/vape_order_flow/view/widgets/vape_order_flow_widgets.dart';

class VapeStatusScreen extends StatelessWidget {
  const VapeStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: VapeOrderFlowStrings.orderStatus,
      subtitle: VapeOrderFlowData.statusSubtitle,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const OrderMapPlaceholder(),
          SizedBox(height: 14.h),
          const VapeLiveMapBanner(),
          SizedBox(height: 10.h),
          const VapePackedBanner(),
          SizedBox(height: 14.h),
          VapeStatusTimeline(steps: VapeOrderFlowData.statusTimeline),
          SizedBox(height: 14.h),
          const VapeStatusSummaryCard(),
          SizedBox(height: 14.h),
          OrderOutlineButton(
            label: VapeOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(VapeOrderFlowRoutes.receipt),
          ),
        ],
      ),
    );
  }
}
