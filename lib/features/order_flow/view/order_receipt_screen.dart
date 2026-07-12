import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
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
      subtitle: OrderFlowStrings.receiptSubtitle,
      lightHeader: true,
      trailing: Icon(
        Icons.more_horiz,
        color: AppColors.textPrimary,
        size: 24.sp,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const OrderReceiptPaper(),
          SizedBox(height: 14.h),
          PrimaryGreenButton(
            label: OrderFlowStrings.shareReceipt,
            backgroundColor: AppColors.cartTabActive,
            height: 50,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
