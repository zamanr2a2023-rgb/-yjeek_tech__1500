import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';
import 'package:yjeek_app/features/vape_order_flow/vape_order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/routes/route_names.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
    this.onReorder,
  });

  final VoidCallback? onReorder;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _timeFilterIndex = 0;
  int _categoryFilterIndex = 0;

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

  List<OrderHistoryItem> get _filteredOrders {
    var items = NavigationData.orders;

    if (_timeFilterIndex == 1) {
      items = items.where((order) => order.isActive).toList();
    } else if (_timeFilterIndex == 2) {
      items = items.where((order) => !order.isActive).toList();
    }

    final category = OrderCategoryFilter.values[_categoryFilterIndex + 1];
    items = items.where((order) => order.category == category).toList();

    return items;
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
                onChanged: (index) => setState(() => _timeFilterIndex = index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: HorizontalFilterChips(
                labels: _categoryFilters,
                selectedIndex: _categoryFilterIndex,
                onChanged: (index) =>
                    setState(() => _categoryFilterIndex = index),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                itemCount: _filteredOrders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return OrderHistoryCard(
                    order: order,
                    onTap: () => context.push(
                      '${RouteNames.orderDetails}?id=${order.id}',
                    ),
                    onAction: (action) {
                      if (action == NavigationStrings.reorder) {
                        widget.onReorder?.call();
                        return;
                      }
                      if (action == NavigationStrings.trackOrder) {
                        if (order.category == OrderCategoryFilter.dineIn) {
                          context.push(DineInOrderFlowRoutes.status);
                        } else if (order.category == OrderCategoryFilter.services) {
                          if (order.vendor == 'Vapeology') {
                            context.push(VapeOrderFlowRoutes.status);
                          } else {
                            context.push(ServicesOrderFlowRoutes.status);
                          }
                        } else if (order.category == OrderCategoryFilter.pickup) {
                          context.push(PickupOrderFlowRoutes.status);
                        } else {
                          context.push(OrderFlowRoutes.statusFor(order.id));
                        }
                        return;
                      }
                      if (action == NavigationStrings.receipt) {
                        if (order.category == OrderCategoryFilter.dineIn) {
                          context.push(DineInOrderFlowRoutes.receipt);
                        } else if (order.category == OrderCategoryFilter.services) {
                          if (order.vendor == 'Vapeology') {
                            context.push(VapeOrderFlowRoutes.receipt);
                          } else {
                            context.push(ServicesOrderFlowRoutes.receipt);
                          }
                        } else if (order.category == OrderCategoryFilter.pickup) {
                          context.push(PickupOrderFlowRoutes.receipt);
                        } else {
                          context.push(OrderFlowRoutes.receiptFor(order.id));
                        }
                        return;
                      }
                      if (action == NavigationStrings.rate) {
                        if (order.category == OrderCategoryFilter.dineIn) {
                          context.push(DineInOrderFlowRoutes.complete);
                        } else if (order.category == OrderCategoryFilter.services) {
                          context.push(ServicesOrderFlowRoutes.complete);
                        } else {
                          context.push(OrderFlowRoutes.delivered);
                        }
                        return;
                      }
                      if (action == NavigationStrings.getHelp) {
                        context.push(
                          HelpRoutes.orderHelp(orderId: order.id, tab: 1),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
