import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';

class OrderHelpScreen extends ConsumerStatefulWidget {
  const OrderHelpScreen({
    super.key,
    required this.orderId,
    required this.bottomNavIndex,
  });

  final String orderId;
  final int bottomNavIndex;

  @override
  ConsumerState<OrderHelpScreen> createState() => _OrderHelpScreenState();
}

class _OrderHelpScreenState extends ConsumerState<OrderHelpScreen> {
  late HelpOrderContext _contextData = HelpData.contextForOrderId(widget.orderId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    final order = await ref.read(ordersRepositoryProvider).getOrder(widget.orderId);
    if (!mounted || order == null) return;
    final vendor = order['vendor'];
    final vendorName = vendor is Map<String, dynamic>
        ? (vendor['name'] as String? ?? _contextData.order.vendorName)
        : _contextData.order.vendorName;
    final itemCount = (order['itemCount'] as num?)?.toInt() ??
        ((order['items'] is List) ? (order['items'] as List).length : 0);
    final total = order['totalAmount'];
    final totalStr = total is num ? total.toStringAsFixed(3) : '0.000';
    final orderNumber = order['orderNumber']?.toString() ?? widget.orderId;
    setState(() {
      _contextData = HelpOrderContext(
        category: _contextData.category,
        isScheduled: (order['fulfillmentType'] as String?) == 'SCHEDULED',
        order: HelpOrder(
          vendorName: vendorName,
          orderId: widget.orderId,
          shortId: orderNumber,
          statusLabel: (order['status'] as String?)?.replaceAll('_', ' ') ??
              _contextData.order.statusLabel,
          itemCount: itemCount,
          totalBhd: totalStr,
          deliveredAt: _contextData.order.deliveredAt,
          compactSubtitle:
              '$orderNumber · $itemCount items · BHD $totalStr',
        ),
      );
    });
  }

  Future<void> _openIssue(HelpIssueType type) async {
    if (type == HelpIssueType.trackOrder) {
      context.push(OrderFlowRoutes.statusFor(widget.orderId));
      return;
    }

    final issueType = switch (type) {
      HelpIssueType.orderLate => 'order_late',
      HelpIssueType.missingItems => 'missing_items',
      HelpIssueType.wrongOrder => 'wrong_items',
      HelpIssueType.notReceived => 'order_never_arrived',
      HelpIssueType.foodQuality => 'food_quality',
      HelpIssueType.damagedSpilled => 'damaged_items',
      HelpIssueType.paymentIssue => 'payment_issue',
      HelpIssueType.champComplaint => 'driver_behaviour',
      HelpIssueType.cancelOrder => 'other',
      _ => 'other',
    };

    await ref.read(ordersRepositoryProvider).createSupportTicket(
          subject: 'Help · ${_contextData.order.shortId} · ${type.name}',
          remark: 'Customer opened help for ${type.name}',
          orderId: widget.orderId,
          issueType: issueType,
        );

    if (!mounted) return;

    if (type == HelpIssueType.cancelOrder && _contextData.isScheduled) {
      context.push(
        HelpRoutes.helpFlow(
          flow: HelpFlowType.scheduledCancelFree,
          tab: widget.bottomNavIndex,
        ),
      );
      return;
    }

    if (type == HelpIssueType.cancelOrder) {
      await ref.read(ordersRepositoryProvider).cancel(
            widget.orderId,
            reason: 'Customer requested cancel via help',
          );
      if (!mounted) return;
    }

    context.push(
      HelpRoutes.helpIssue(
        type: type,
        orderId: widget.orderId,
        tab: widget.bottomNavIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = HelpData.visibleOrderHelpOptionsFor(_contextData);

    return HelpScreenScaffold(
      title: 'Order help',
      bottomNavIndex: widget.bottomNavIndex,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          HelpOrderDetailCard(order: _contextData.order),
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
                    onTap: () => _openIssue(options[i].type),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
