import 'package:flutter/material.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInReceiptScreen extends StatelessWidget {
  const DineInReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: DineInOrderFlowStrings.receipt,
      subtitle: DineInOrderFlowData.orderId,
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const DineInReceiptPaper(),
          SizedBox(height: 20.h),
          PrimaryGreenButton(
            label: DineInOrderFlowStrings.shareReceipt,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
