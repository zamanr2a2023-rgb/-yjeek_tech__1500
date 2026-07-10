import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';
import 'package:yjeek_app/features/vape_order_flow/vape_order_flow_routes.dart';

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

  @override
  void initState() {
    super.initState();
    _secondsLeft = _initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        _finishOrder();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _finishOrder() {
    context.pushReplacement(VapeOrderFlowRoutes.waiting);
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
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          VapeReviewStatusCard(secondsLeft: _secondsLeft),
          SizedBox(height: 16.h),
          VapeReviewSummaryCard(deliveryLabel: _deliveryMethod.label),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: Row(
            children: [
              Expanded(
                child: CartOutlineButton(
                  label: VapeCartStrings.editOrder,
                  onPressed: () => context.pop(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: VapeCartStrings.sendToVendor,
                  onPressed: _finishOrder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
