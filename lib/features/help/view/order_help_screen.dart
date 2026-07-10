import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class OrderHelpScreen extends StatelessWidget {
  const OrderHelpScreen({
    super.key,
    required this.orderId,
    required this.bottomNavIndex,
  });

  final String orderId;
  final int bottomNavIndex;

  @override
  Widget build(BuildContext context) {
    final contextData = HelpData.contextForOrderId(orderId);
    final options = HelpData.visibleOrderHelpOptionsFor(contextData);

    return HelpScreenScaffold(
      title: 'Order help',
      bottomNavIndex: bottomNavIndex,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          HelpOrderDetailCard(order: contextData.order),
          SizedBox(height: 16.h),
          const HelpSectionTitle(label: 'What do you need?'),
          SizedBox(height: 10.h),
          HelpCard(
            child: Column(
              children: [
                for (var i = 0; i < options.length; i++)
                  HelpIssueTile(
                    option: options[i],
                    showDivider: i < options.length - 1,
                    onTap: () => _openIssue(context, options[i].type),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openIssue(BuildContext context, HelpIssueType type) {
    if (type == HelpIssueType.trackOrder) {
      context.push('${RouteNames.orderDetails}?id=$orderId');
      return;
    }
    final contextData = HelpData.contextForOrderId(orderId);
    if (type == HelpIssueType.cancelOrder && contextData.isScheduled) {
      context.push(
        HelpRoutes.helpFlow(
          flow: HelpFlowType.scheduledCancelFree,
          tab: bottomNavIndex,
        ),
      );
      return;
    }
    context.push(
      HelpRoutes.helpIssue(
        type: type,
        orderId: orderId,
        tab: bottomNavIndex,
      ),
    );
  }
}
