import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/pickup_cart/model/pickup_cart_data.dart';
import 'package:yjeek_app/features/pickup_cart/view/widgets/pickup_cart_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/pickup_order_flow_routes.dart';

class PickupReviewScreen extends StatefulWidget {
  const PickupReviewScreen({super.key});

  @override
  State<PickupReviewScreen> createState() => _PickupReviewScreenState();
}

class _PickupReviewScreenState extends State<PickupReviewScreen> {
  static const _initialSeconds = 10;
  late int _secondsLeft;
  Timer? _timer;

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
    context.pushReplacement(PickupOrderFlowRoutes.waiting);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: PickupCartStrings.reviewConfirm,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          PickupReviewStatusCard(secondsLeft: _secondsLeft),
          SizedBox(height: 16.h),
          const PickupReviewSummaryCard(),
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
                  label: PickupCartStrings.editOrder,
                  onPressed: () => context.pop(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: PickupCartStrings.sendToVendor,
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
