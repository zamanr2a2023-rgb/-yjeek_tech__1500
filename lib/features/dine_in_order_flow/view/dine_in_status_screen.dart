import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInStatusScreen extends StatelessWidget {
  const DineInStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: DineInOrderFlowStrings.dineInOrder,
      subtitle: DineInOrderFlowData.orderId,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const DineInArrivalCodeCard(compact: true),
          SizedBox(height: 16.h),
          DineInStatusTimeline(steps: DineInOrderFlowData.statusTimeline),
          SizedBox(height: 14.h),
          OrderFlowCard(
            child: Column(
              children: [
                _infoRow(DineInOrderFlowStrings.venue, DineInOrderFlowData.venue),
                _infoRow(DineInOrderFlowStrings.table, DineInOrderFlowData.tableLabel),
                _infoRow(DineInOrderFlowStrings.time, DineInOrderFlowData.dineInTime),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          DineInStatusActions(
            onReceipt: () => context.push(DineInOrderFlowRoutes.receipt),
            onDirections: () {},
            onContact: () {},
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 56.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall().copyWith(fontSize: 12.sp),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
