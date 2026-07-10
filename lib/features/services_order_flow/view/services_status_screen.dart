import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class ServicesStatusScreen extends StatelessWidget {
  const ServicesStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: ServicesOrderFlowStrings.yourBooking,
      subtitle: '${ServicesOrderFlowData.providerName} · #${ServicesOrderFlowData.bookingId}',
      bottomNavIndex: 1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          const ServicesStatusBadge(),
          SizedBox(height: 14.h),
          ServicesStatusTimeline(steps: ServicesOrderFlowData.statusTimeline),
          SizedBox(height: 14.h),
          const ServicesStatusDetailsCard(),
          SizedBox(height: 14.h),
          ServicesStatusActions(
            onReceipt: () => context.push(ServicesOrderFlowRoutes.receipt),
            onDirections: () {},
            onContact: () {},
          ),
        ],
      ),
    );
  }
}
