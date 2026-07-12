import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInStatusScreen extends StatelessWidget {
  const DineInStatusScreen({super.key});

  static const Color _screenBg = Color(0xFF8BAE9A);

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: DineInOrderFlowStrings.dineInOrder,
      subtitle: DineInOrderFlowStrings.orderHeaderSubtitle,
      lightHeader: true,
      backgroundColor: _screenBg,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const DineInArrivalCodeCard(compact: true),
          SizedBox(height: 16.h),
          const DineInPreparingPill(),
          SizedBox(height: 16.h),
          DineInStatusTimeline(steps: DineInOrderFlowData.statusTimeline),
          SizedBox(height: 16.h),
          const DineInStatusInfoCard(),
          SizedBox(height: 16.h),
          DineInStatusActions(
            onReceipt: () => context.push(DineInOrderFlowRoutes.receipt),
            onDirections: () {},
            onContact: () {},
          ),
        ],
      ),
    );
  }
}
