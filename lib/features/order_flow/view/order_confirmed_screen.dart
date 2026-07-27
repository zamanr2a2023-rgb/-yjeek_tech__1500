import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class OrderConfirmedScreen extends ConsumerStatefulWidget {
  const OrderConfirmedScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderConfirmedScreen> createState() =>
      _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends ConsumerState<OrderConfirmedScreen> {
  String _subtitle = OrderFlowData.confirmedSubtitle();
  String _items = OrderFlowData.itemCount;
  String _deliverTo = OrderFlowData.deliveryAddress;
  String _arrives = OrderFlowData.arrivalWindow;
  String _total = OrderFlowData.orderTotal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (!mounted) return;
    if (order == null) {
      setState(() => _loading = false);
      return;
    }
    final orderNumber =
        order['orderNumber']?.toString() ?? order['id']?.toString() ?? '';
    final vendor = order['vendor'];
    final vendorName = vendor is Map
        ? vendor['name']?.toString() ?? 'vendor'
        : 'vendor';
    final items = order['items'];
    final itemCount = items is List
        ? items.length
        : (order['itemCount'] as num?)?.toInt();
    final address = order['deliveryAddress'] ?? order['address'];
    String deliverTo = OrderFlowData.deliveryAddress;
    if (address is Map) {
      final label = address['label']?.toString();
      final area = address['area']?.toString();
      final line = address['formatted']?.toString() ??
          address['line1']?.toString() ??
          [
            if (area != null && area.isNotEmpty) area,
            if (address['road'] != null) 'Road ${address['road']}',
          ].whereType<String>().join(' · ');
      deliverTo = [
        if (label != null && label.isNotEmpty) label,
        if (line.isNotEmpty) line,
      ].join(' · ');
    }
    final etaMin = order['estimatedArrivalMin'] ?? order['etaMin'];
    final etaMax = order['estimatedArrivalMax'] ?? order['etaMax'];
    final etaLabel = order['etaLabel']?.toString();
    setState(() {
      _subtitle =
          'Order ${orderNumber.isEmpty ? '' : '#$orderNumber'} · sent to $vendorName.';
      _items = itemCount == null
          ? OrderFlowData.itemCount
          : '$itemCount ${itemCount == 1 ? 'item' : 'items'}';
      _deliverTo = deliverTo.isEmpty ? OrderFlowData.deliveryAddress : deliverTo;
      _arrives = etaLabel ??
          (etaMin != null
              ? '$etaMin–${etaMax ?? etaMin} min'
              : OrderFlowData.arrivalWindow);
      _total = formatBhd(order['totalAmount']);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: OrderSuccessIcon(),
                ),
                SizedBox(height: 14.h),
                Text(
                  OrderFlowStrings.orderConfirmed,
                  textAlign: TextAlign.left,
                  style:
                      AppTextStyles.titleMedium(color: AppColors.textPrimary)
                          .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                    height: 29 / 24,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  _subtitle,
                  textAlign: TextAlign.left,
                  style:
                      AppTextStyles.bodySmall(color: AppColors.textSecondary)
                          .copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    height: 16 / 13,
                  ),
                ),
                SizedBox(height: 14.h),
                OrderSummaryCard(
                  items: _items,
                  deliverTo: _deliverTo,
                  arrivesIn: _arrives,
                  orderTotal: _total,
                ),
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label: OrderFlowStrings.trackOrder,
                  backgroundColor: AppColors.cartTabActive,
                  height: 52,
                  onPressed: () => context.push(
                    OrderFlowRoutes.statusFor(orderId),
                  ),
                ),
                SizedBox(height: 14.h),
                OrderOutlineButton(
                  label: OrderFlowStrings.viewReceipt,
                  onPressed: () => context.push(
                    OrderFlowRoutes.receiptFor(orderId),
                  ),
                ),
              ],
            ),
    );
  }
}
