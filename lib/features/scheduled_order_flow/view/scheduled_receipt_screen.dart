import 'package:flutter/material.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/view/widgets/scheduled_order_flow_widgets.dart';

class ScheduledReceiptScreen extends StatelessWidget {
  const ScheduledReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: ScheduledOrderFlowStrings.receipt,
      subtitle: '#${ScheduledOrderFlowData.orderId}',
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const ScheduledReceiptPaper(),
          SizedBox(height: 20.h),
          PrimaryGreenButton(
            label: ScheduledOrderFlowStrings.shareReceipt,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
