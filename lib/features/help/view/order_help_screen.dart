import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
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
  HelpOrderContext? _contextData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    setState(() => _loading = true);
    final order =
        await ref.read(ordersRepositoryProvider).getOrder(widget.orderId);
    if (!mounted) return;
    if (order == null) {
      setState(() {
        _contextData = null;
        _loading = false;
      });
      return;
    }
    final vendor = order['vendor'];
    final vendorName = vendor is Map<String, dynamic>
        ? (vendor['name'] as String? ?? 'Order')
        : 'Order';
    final itemCount = (order['itemCount'] as num?)?.toInt() ??
        ((order['items'] is List) ? (order['items'] as List).length : 0);
    final total = order['totalAmount'];
    final totalStr = total is num ? total.toStringAsFixed(3) : '0.000';
    final orderNumber = order['orderNumber']?.toString() ?? widget.orderId;
    final statusRaw = order['status']?.toString() ?? '';
    final statusLabel = statusRaw.isEmpty
        ? 'Unknown'
        : statusRaw.replaceAll('_', ' ');
    final orderType = (order['orderType'] as String?)?.toUpperCase() ?? '';
    final category = switch (orderType) {
      'SERVICE' => OrderCategoryFilter.services,
      'DINE_IN' => OrderCategoryFilter.dineIn,
      'PICKUP' => OrderCategoryFilter.pickup,
      _ => OrderCategoryFilter.orders,
    };
    setState(() {
      _contextData = HelpOrderContext(
        category: category,
        isScheduled: (order['fulfillmentType'] as String?) == 'SCHEDULED',
        order: HelpOrder(
          vendorName: vendorName,
          orderId: widget.orderId,
          shortId: orderNumber.startsWith('#') ? orderNumber : '#$orderNumber',
          statusLabel: statusLabel,
          itemCount: itemCount,
          totalBhd: totalStr,
          deliveredAt: statusLabel,
          compactSubtitle: '$orderNumber · $itemCount items · BHD $totalStr',
        ),
      );
      _loading = false;
    });
  }

  Future<void> _openIssue(HelpIssueType type) async {
    if (type == HelpIssueType.trackOrder) {
      context.push(OrderFlowRoutes.statusFor(widget.orderId));
      return;
    }

    if (type == HelpIssueType.cancelOrder &&
        (_contextData?.isScheduled ?? false)) {
      context.push(
        HelpRoutes.helpFlow(
          flow: HelpFlowType.scheduledCancelFree,
          orderId: widget.orderId,
          tab: widget.bottomNavIndex,
        ),
      );
      return;
    }

    final active = await ref
        .read(supportRepositoryProvider)
        .findActiveTicketForOrder(widget.orderId);
    if (!mounted) return;
    if (active != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Continuing your existing request')),
      );
      context.push(
        HelpRoutes.helpChat(
          ticketId: active.id,
          orderId: widget.orderId,
          tab: widget.bottomNavIndex,
        ),
      );
      return;
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
    if (_loading) {
      return HelpScreenScaffold(
        title: 'Order help',
        bottomNavIndex: widget.bottomNavIndex,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    final contextData = _contextData;
    if (contextData == null) {
      return HelpScreenScaffold(
        title: 'Order help',
        bottomNavIndex: widget.bottomNavIndex,
        body: const Center(child: Text('Order not found')),
      );
    }
    final options = HelpData.visibleOrderHelpOptionsFor(contextData);

    return HelpScreenScaffold(
      title: 'Order help',
      bottomNavIndex: widget.bottomNavIndex,
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
