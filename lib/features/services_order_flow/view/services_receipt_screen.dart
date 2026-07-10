import 'package:flutter/material.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesReceiptScreen extends StatelessWidget {
  const ServicesReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: ServicesOrderFlowStrings.receipt,
      subtitle: '#${ServicesOrderFlowData.bookingId}',
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const ServicesReceiptPaper(),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OrderOutlineButton(
                  label: ServicesOrderFlowStrings.print,
                  icon: Icons.download_outlined,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: ServicesOrderFlowStrings.shareReceipt,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
