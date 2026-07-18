import 'package:flutter/material.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/vape_order_flow/model/vape_order_flow_data.dart';
import 'package:yjeek_app/features/vape_order_flow/view/widgets/vape_order_flow_widgets.dart';

class VapeReceiptScreen extends StatelessWidget {
  const VapeReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma E · Receipt: light header, #F2F7F2, Home nav, Share #2E9E4D h50.
    return OrderFlowScaffold(
      title: VapeOrderFlowStrings.receipt,
      subtitle: '#${VapeOrderFlowData.orderId}',
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const VapeReceiptPaper(),
          SizedBox(height: 14.h),
          PrimaryGreenButton(
            label: VapeOrderFlowStrings.shareReceipt,
            backgroundColor: const Color(0xFF2E9E4D),
            height: 50,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
