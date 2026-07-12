import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: OrderFlowData.orderIdDisplay,
      subtitle: OrderFlowData.vendor,
      lightHeader: true,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        children: [
          const OrderMapPlaceholder(height: 196),
          SizedBox(height: 16.h),
          const OrderStatusBadge(label: OrderFlowStrings.preparingOrder),
          SizedBox(height: 16.h),
          const OrderArrivalCard(),
          SizedBox(height: 16.h),
          const OrderTimeline(steps: OrderFlowData.timelineSteps),
          SizedBox(height: 16.h),
          const OrderVendorSummaryCard(),
          SizedBox(height: 16.h),
          OrderChampCard(
            onCall: () {},
            onChat: () => context.push(OrderFlowRoutes.chat),
          ),
          SizedBox(height: 16.h),
          const OrderPaymentRow(),
          SizedBox(height: 16.h),
          OrderContactSupportButton(
            onTap: () => context.push(RouteNames.helpSupport),
          ),
        ],
      ),
    );
  }
}
