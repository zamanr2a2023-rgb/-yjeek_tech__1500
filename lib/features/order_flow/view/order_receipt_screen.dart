import 'package:flutter/material.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class OrderReceiptScreen extends StatelessWidget {
  const OrderReceiptScreen({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: OrderFlowStrings.receipt,
      subtitle: OrderFlowData.orderIdDisplay,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const OrderReceiptPaper(),
          SizedBox(height: 20.h),
          PrimaryGreenButton(
            label: OrderFlowStrings.shareReceipt,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
