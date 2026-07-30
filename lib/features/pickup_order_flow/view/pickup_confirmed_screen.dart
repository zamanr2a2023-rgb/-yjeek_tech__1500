import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';
import 'package:yjeek_app/features/pickup_order_flow/view/widgets/pickup_order_flow_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';

class PickupConfirmedScreen extends ConsumerStatefulWidget {
  const PickupConfirmedScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<PickupConfirmedScreen> createState() =>
      _PickupConfirmedScreenState();
}

class _PickupConfirmedScreenState extends ConsumerState<PickupConfirmedScreen> {
  String _orderNumber = PickupOrderFlowData.orderId;
  String _items = PickupOrderFlowData.confirmedItems;
  String _pickup = PickupOrderFlowData.confirmedPickup;
  String _payment = PickupOrderFlowData.confirmedPayment;
  String _total = PickupOrderFlowData.confirmedTotal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final order = await ref.read(ordersRepositoryProvider).getOrder(id);
    if (!mounted) return;
    if (order == null) {
      setState(() => _loading = false);
      return;
    }

    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final area = vendor is Map
        ? (vendor['area']?.toString() ?? vendor['location']?.toString())
        : null;
    final loc = order['vendorLocation'] ?? order['pickup'];
    final locArea = loc is Map
        ? (loc['area']?.toString() ??
            loc['name']?.toString() ??
            loc['address']?.toString())
        : null;
    final eta = order['etaLabel']?.toString();
    final place = locArea ?? area;

    setState(() {
      _orderNumber =
          order['orderNumber']?.toString() ?? order['id']?.toString() ?? _orderNumber;
      _items = itemsSummaryFromOrderApi(order);
      if (vendorName != null && vendorName.isNotEmpty) {
        if (eta != null && eta.isNotEmpty) {
          _pickup = '$vendorName · ready in $eta';
        } else if (place != null && place.isNotEmpty) {
          _pickup = '$vendorName · $place';
        } else {
          _pickup = vendorName;
        }
      }
      _payment = formatPaymentMethod(order['paymentMethod']?.toString());
      _total = formatBhd(order['totalAmount']);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 1,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
                const Center(child: PickupConfirmedIcon()),
                SizedBox(height: 16.h),
                Text(
                  PickupOrderFlowStrings.orderConfirmed,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  PickupOrderFlowStrings.preparedForPickup,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall().copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: 20.h),
                PickupOrderDetailsCard(
                  orderNumber: _orderNumber,
                  items: _items,
                  pickup: _pickup,
                  payment: _payment,
                  total: _total,
                ),
                SizedBox(height: 20.h),
                PrimaryGreenButton(
                  label: PickupOrderFlowStrings.trackOrder,
                  onPressed: () =>
                      context.push(PickupOrderFlowRoutes.statusFor(orderId)),
                ),
                SizedBox(height: 12.h),
                OrderOutlineButton(
                  label: PickupOrderFlowStrings.viewReceipt,
                  onPressed: () =>
                      context.push(PickupOrderFlowRoutes.receiptFor(orderId)),
                ),
              ],
            ),
    );
  }
}
