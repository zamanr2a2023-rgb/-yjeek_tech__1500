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
    // Figma E · Order status: light header, #F2F7F2, Home nav, sticky View receipt.
    return OrderFlowScaffold(
      title: VapeOrderFlowStrings.orderStatus,
      subtitle: VapeOrderFlowData.statusSubtitle,
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        children: [
          const OrderMapPlaceholder(),
          SizedBox(height: 16.h),
          const VapeLiveMapBanner(),
          SizedBox(height: 16.h),
          const VapePackedBanner(),
          SizedBox(height: 16.h),
          VapeStatusTimeline(steps: VapeOrderFlowData.statusTimeline),
          SizedBox(height: 16.h),
          const VapeStatusSummaryCard(),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
          child: OrderOutlineButton(
            label: VapeOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(VapeOrderFlowRoutes.receipt),
          ),
        ),
      ),
    );
  }
}
