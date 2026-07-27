import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({
    super.key,
    this.orderId,
    this.bottomNavIndex = 4,
  });

  final String? orderId;
  final int bottomNavIndex;

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  late HelpOrder _order = HelpData.contextForOrderId(widget.orderId).order;
  List<String> _popularTopics = HelpData.popularTopics;
  bool _loadingTopics = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateOrder();
      _loadTopics();
    });
  }

  Future<void> _hydrateOrder() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (!mounted || order == null) return;

    final vendor = order['vendor'];
    final vendorName = vendor is Map<String, dynamic>
        ? (vendor['name'] as String? ?? _order.vendorName)
        : _order.vendorName;
    final itemCount = (order['itemCount'] as num?)?.toInt() ??
        ((order['items'] is List) ? (order['items'] as List).length : 0);
    final total = order['totalAmount'];
    final totalStr = total is num ? total.toStringAsFixed(3) : '0.000';
    final orderNumber = order['orderNumber']?.toString() ?? orderId;
    final status = (order['status'] as String?)?.replaceAll('_', ' ') ??
        _order.statusLabel;
    final shortId = orderNumber.length > 6
        ? '#YJK-…${orderNumber.substring(orderNumber.length - 2)}'
        : '#$orderNumber';

    setState(() {
      _order = HelpOrder(
        vendorName: vendorName,
        orderId: orderId,
        shortId: shortId,
        statusLabel: status,
        itemCount: itemCount,
        totalBhd: totalStr,
        deliveredAt: status,
        compactSubtitle: '$shortId · $status',
      );
    });
  }

  Future<void> _loadTopics() async {
    final help = await ref.read(contentRepositoryProvider).fetchHelp();
    if (!mounted) return;
    final labels = help?.popularTopicLabels ?? const <String>[];
    setState(() {
      if (labels.isNotEmpty) _popularTopics = labels;
      _loadingTopics = false;
    });
  }

  String get _resolvedOrderId =>
      widget.orderId?.isNotEmpty == true
          ? widget.orderId!
          : HelpData.defaultOrderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GreenScreenHeader(title: NavigationStrings.helpSupport),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              children: [
                const HelpSectionTitle(label: 'Help with an order'),
                SizedBox(height: 10.h),
                HelpOrderCompactCard(
                  order: _order,
                  actionLabel: NavigationStrings.getHelp,
                  onAction: () => context.push(
                    HelpRoutes.orderHelp(
                      orderId: _resolvedOrderId,
                      tab: widget.bottomNavIndex,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                const HelpSectionTitle(label: 'Popular help topics'),
                SizedBox(height: 10.h),
                HelpCard(
                  child: _loadingTopics
                      ? Padding(
                          padding: EdgeInsets.all(18.w),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < _popularTopics.length; i++)
                              HelpChevronRow(
                                title: _popularTopics[i],
                                dense: true,
                                showDivider: i < _popularTopics.length - 1,
                                onTap: () => _openPopularTopic(context, i),
                              ),
                          ],
                        ),
                ),
                SizedBox(height: 12.h),
                HelpCard(
                  child: HelpChevronRow(
                    title: 'Policies — Refund · Terms · Privacy',
                    dense: true,
                    showDivider: false,
                    leading: Icon(
                      Icons.description_outlined,
                      size: 18.sp,
                      color: const Color(0xFF6B7B6E),
                    ),
                    onTap: () => context.push(
                      HelpRoutes.helpPoliciesLegal(tab: widget.bottomNavIndex),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  void _openPopularTopic(BuildContext context, int index) {
    final label = _popularTopics[index].toLowerCase();
    if (label.contains('wallet') || label.contains('withdraw')) {
      context.push(RouteNames.withdrawBank);
      return;
    }
    if (label.contains('delay') || label.contains('late')) {
      context.push(
        HelpRoutes.helpIssue(
          type: HelpIssueType.orderLate,
          orderId: _resolvedOrderId,
          tab: widget.bottomNavIndex,
        ),
      );
      return;
    }
    if (label.contains('payment') || label.contains('pay')) {
      context.push(HelpRoutes.helpChat(tab: widget.bottomNavIndex));
      return;
    }
    context.push(HelpRoutes.helpFaq(tab: widget.bottomNavIndex));
  }
}
