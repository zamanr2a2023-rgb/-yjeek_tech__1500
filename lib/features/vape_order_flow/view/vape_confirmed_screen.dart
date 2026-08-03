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
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_api_mappers.dart';
import 'package:yjeek_app/features/vape_order_flow/model/vape_order_flow_data.dart';
import 'package:yjeek_app/features/vape_order_flow/vape_order_flow_routes.dart';
import 'package:yjeek_app/features/vape_order_flow/view/widgets/vape_order_flow_widgets.dart';

class VapeConfirmedScreen extends ConsumerStatefulWidget {
  const VapeConfirmedScreen({super.key, this.orderIds = const []});

  final List<String> orderIds;

  @override
  ConsumerState<VapeConfirmedScreen> createState() =>
      _VapeConfirmedScreenState();
}

class _VapeConfirmedScreenState extends ConsumerState<VapeConfirmedScreen> {
  String _subtitle = VapeOrderFlowStrings.preparedForDelivery;
  String _orderNumber = '—';
  String _items = '—';
  String _delivery = '—';
  String _payment = '—';
  String _total = '—';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    if (widget.orderIds.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    var total = 0.0;
    String? vendorName;
    String? orderNumber;
    String? items;
    String? delivery;
    String? payment;

    for (final id in widget.orderIds) {
      final order = await ref.read(ordersRepositoryProvider).getOrder(id);
      if (order == null) continue;
      total += (order['totalAmount'] as num?)?.toDouble() ?? 0;
      vendorName ??=
          order['vendor'] is Map ? (order['vendor'] as Map)['name']?.toString() : null;
      orderNumber ??= order['orderNumber']?.toString();
      items ??= itemsSummaryFromOrderApi(order);
      delivery ??= deliveryWindowFromOrderApi(order);
      payment ??= formatPaymentMethod(order['paymentMethod']?.toString());
    }

    if (!mounted) return;
    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) {
        _subtitle =
            'Prepared for delivery from $vendorName · ${formatBhd(total)}';
      }
      if (orderNumber != null && orderNumber.isNotEmpty) {
        _orderNumber = widget.orderIds.length > 1
            ? '$orderNumber +${widget.orderIds.length - 1}'
            : orderNumber;
      }
      if (items != null) _items = items;
      if (delivery != null) _delivery = delivery;
      if (payment != null) _payment = payment;
      if (total > 0) _total = formatBhd(total);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ids = widget.orderIds;
    // Figma E · Order confirmed: mint check, #F2F7F2 bg, Track #2E9E4D h52.
    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
                const Center(child: VapeConfirmedIcon()),
                SizedBox(height: 14.h),
                Text(
                  VapeOrderFlowStrings.orderConfirmed,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium(color: const Color(0xFF1A1A1A))
                      .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(color: const Color(0xFF6B756E))
                      .copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 14.h),
                VapeOrderDetailsCard(
                  orderNumber: _orderNumber,
                  items: _items,
                  delivery: _delivery,
                  payment: _payment,
                  total: _total,
                ),
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label: VapeOrderFlowStrings.trackOrder,
                  backgroundColor: const Color(0xFF2E9E4D),
                  height: 52,
                  onPressed: () =>
                      context.push(VapeOrderFlowRoutes.statusFor(ids)),
                ),
                SizedBox(height: 12.h),
                OrderOutlineButton(
                  label: VapeOrderFlowStrings.viewReceipt,
                  onPressed: () =>
                      context.push(VapeOrderFlowRoutes.receiptFor(ids)),
                ),
              ],
            ),
    );
  }
}
