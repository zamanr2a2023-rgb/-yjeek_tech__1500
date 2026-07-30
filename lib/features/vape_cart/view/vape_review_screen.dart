import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';
import 'package:yjeek_app/features/vape_order_flow/vape_order_flow_routes.dart';

/// Same flow as Electronics review: timer → summary → Edit / Send to vendor.
class VapeReviewScreen extends ConsumerStatefulWidget {
  const VapeReviewScreen({
    super.key,
    this.deliveryId = 'same-day',
    this.orderIds = const [],
  });

  final String deliveryId;
  final List<String> orderIds;

  @override
  ConsumerState<VapeReviewScreen> createState() => _VapeReviewScreenState();
}

class _VapeReviewScreenState extends ConsumerState<VapeReviewScreen> {
  static const _initialSeconds = 10;
  late int _secondsLeft;
  Timer? _timer;
  bool _leaving = false;

  String _vendorLabel = VapeCartStrings.orderType;
  String _deliveryLabel = 'Same Day';
  String _address = '—';
  String _payment = '—';
  String _total = '—';

  @override
  void initState() {
    super.initState();
    _deliveryLabel = VapeCartData.deliveryMethods
        .firstWhere(
          (m) => m.id == widget.deliveryId,
          orElse: () => VapeCartData.deliveryMethods.first,
        )
        .label;
    _secondsLeft = _initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _leaving) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        _goWaiting();
        return;
      }
      setState(() => _secondsLeft--);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _hydrate() async {
    final ids = widget.orderIds;
    if (ids.isEmpty) return;
    final order = await ref.read(ordersRepositoryProvider).getOrder(ids.first);
    if (!mounted || order == null) return;
    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final address = order['address'];
    final addressLabel = address is Map
        ? [
            address['label']?.toString(),
            address['area']?.toString() ?? address['city']?.toString(),
          ].whereType<String>().where((s) => s.isNotEmpty).join(' - ')
        : order['deliverToLabel']?.toString();
    final speed = deliveryUiIdFromApi(order['deliverySpeed']?.toString());
    final methodLabel = VapeCartData.deliveryMethods
        .firstWhere(
          (m) => m.id == speed,
          orElse: () => VapeCartData.deliveryMethods.first,
        )
        .label;
    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) {
        _vendorLabel = '${vendorName.toUpperCase()} · VAPE DELIVERY';
      }
      _deliveryLabel = methodLabel;
      if (addressLabel != null && addressLabel.isNotEmpty) {
        _address = addressLabel;
      }
      _payment = formatPaymentMethod(order['paymentMethod']?.toString());
      _total = formatBhd(order['totalAmount']);
    });
  }

  Future<void> _goWaiting() async {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    if (!mounted) return;
    context.pushReplacement(
      VapeOrderFlowRoutes.waitingFor(widget.orderIds),
    );
  }

  Future<void> _edit() async {
    _timer?.cancel();
    final ids = widget.orderIds;
    for (final id in ids) {
      await ref
          .read(ordersRepositoryProvider)
          .cancel(id, reason: 'Edit order');
    }
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: VapeCartStrings.reviewConfirm,
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
              children: [
                VapeReviewStatusCard(secondsLeft: _secondsLeft),
                SizedBox(height: 14.h),
                VapeReviewSummaryCard(
                  deliveryLabel: _deliveryLabel,
                  total: _total,
                  vendorLabel: _vendorLabel,
                  addressLabel: _address,
                  paymentLabel: _payment,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: CartOutlineButton(
                    label: VapeCartStrings.editOrder,
                    onPressed: _leaving ? () {} : _edit,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryGreenButton(
                    label: VapeCartStrings.sendToVendor,
                    backgroundColor: const Color(0xFF4CAF50),
                    height: 53,
                    onPressed: _leaving ? null : _goWaiting,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
