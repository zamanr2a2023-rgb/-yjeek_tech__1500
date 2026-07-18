import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';
import 'package:yjeek_app/features/vape_order_flow/vape_order_flow_routes.dart';

/// Same flow as Electronics review: timer → summary → Edit / Send to vendor.
class VapeReviewScreen extends StatefulWidget {
  const VapeReviewScreen({
    super.key,
    this.deliveryId = 'same-day',
  });

  final String deliveryId;

  @override
  State<VapeReviewScreen> createState() => _VapeReviewScreenState();
}

class _VapeReviewScreenState extends State<VapeReviewScreen> {
  static const _initialSeconds = 10;
  late int _secondsLeft;
  Timer? _timer;

  VapeDeliveryMethod get _deliveryMethod =>
      VapeCartData.deliveryMethods.firstWhere((m) => m.id == widget.deliveryId);

  String get _orderTotal => VapeCartData.checkoutTotalFor(
        method: _deliveryMethod,
        tip: 0.3,
      );

  @override
  void initState() {
    super.initState();
    _secondsLeft = _initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        context.pushReplacement(VapeOrderFlowRoutes.waiting);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                  deliveryLabel: _deliveryMethod.label,
                  total: _orderTotal,
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
                    onPressed: () {
                      _timer?.cancel();
                      context.pop();
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryGreenButton(
                    label: VapeCartStrings.sendToVendor,
                    backgroundColor: const Color(0xFF4CAF50),
                    height: 53,
                    onPressed: () {
                      _timer?.cancel();
                      context.pushReplacement(VapeOrderFlowRoutes.waiting);
                    },
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
