import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';

class ServicesStatusScreen extends StatelessWidget {
  const ServicesStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: ServicesOrderFlowStrings.yourBooking,
      subtitle:
          '${ServicesOrderFlowData.providerName} · #${ServicesOrderFlowData.bookingId}',
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      // Figma sticky footer: Get directions + Contact venue
      bottom: ServicesStatusActions(
        stickyOnly: true,
        onDirections: () {},
        onContact: () {},
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: ServicesStatusBadge(),
          ),
          SizedBox(height: 16.h),
          ServicesStatusTimeline(steps: ServicesOrderFlowData.statusTimeline),
          SizedBox(height: 16.h),
          const ServicesStatusDetailsCard(),
          SizedBox(height: 16.h),
          OrderOutlineButton(
            label: ServicesOrderFlowStrings.viewReceipt,
            onPressed: () => context.push(ServicesOrderFlowRoutes.receipt),
          ),
        ],
      ),
    );
  }
}
