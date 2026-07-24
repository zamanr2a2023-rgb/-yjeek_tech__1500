import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.onReorder});

  final VoidCallback? onReorder;

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _timeFilterIndex = 0;
  int _categoryFilterIndex = 0;
  List<OrderHistoryItem> _orders = const [];
  bool _loading = true;

  static const _timeFilters = [
    NavigationStrings.filterAll,
    NavigationStrings.filterActive,
    NavigationStrings.filterPast,
  ];

  static const _categoryFilters = [
    NavigationStrings.categoryOrders,
    NavigationStrings.categoryServices,
    NavigationStrings.categoryDineIn,
    NavigationStrings.categoryPickup,
  ];

  String get _statusQuery => switch (_timeFilterIndex) {
    1 => 'active',
    2 => 'past',
    _ => 'all',
  };

  OrderCategoryFilter get _category =>
      OrderCategoryFilter.values[_categoryFilterIndex + 1];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await ref
          .read(ordersRepositoryProvider)
          .listOrders(status: _statusQuery, category: _category);
      if (!mounted) return;
      setState(() {
        _orders = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _orders = const [];
        _loading = false;
      });
    }
  }

  Future<void> _onAction(OrderHistoryItem order, String action) async {
    if (action == NavigationStrings.reorder) {
      final ok = await ref.read(ordersRepositoryProvider).reorder(order.id);
      if (!mounted) return;
      if (ok) {
        widget.onReorder?.call();
        context.goHome(tab: 2, cartHasItems: true);
      } else {
        widget.onReorder?.call();
      }
      return;
    }
    if (action == NavigationStrings.trackOrder) {
      context.push(OrderFlowRoutes.statusFor(order.id));
      return;
    }
    if (action == NavigationStrings.receipt) {
      context.push(OrderFlowRoutes.receiptFor(order.id));
      return;
    }
    if (action == NavigationStrings.rate) {
      context.push(OrderFlowRoutes.deliveredFor(order.id));
      return;
    }
    if (action == NavigationStrings.getHelp) {
      context.push(HelpRoutes.orderHelp(orderId: order.id, tab: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                NavigationStrings.yourOrders,
                style: AppTextStyles.displayMedium().copyWith(fontSize: 26),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: PillSegmentBar(
                labels: _timeFilters,
                selectedIndex: _timeFilterIndex,
                onChanged: (index) {
                  setState(() => _timeFilterIndex = index);
                  _load();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: HorizontalFilterChips(
                labels: _categoryFilters,
                selectedIndex: _categoryFilterIndex,
                onChanged: (index) {
                  setState(() => _categoryFilterIndex = index);
                  _load();
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: _loading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      )
                    : _orders.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              'No orders yet',
                              style: AppTextStyles.bodyMedium(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                        itemCount: _orders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return OrderHistoryCard(
                            order: order,
                            onTap: () => context.push(
                              '${RouteNames.orderDetails}?id=${order.id}',
                            ),
                            onAction: (action) => _onAction(order, action),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
