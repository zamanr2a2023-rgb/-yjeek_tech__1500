import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';

class ReviewConfirmScreen extends StatefulWidget {
  const ReviewConfirmScreen({super.key});

  @override
  State<ReviewConfirmScreen> createState() => _ReviewConfirmScreenState();
}

class _ReviewConfirmScreenState extends State<ReviewConfirmScreen> {
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
        context.pushReplacement(OrderFlowRoutes.confirmed);
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
      title: CartFlowStrings.reviewConfirm,
      body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          children: [
            CartReviewStatusCard(secondsLeft: _secondsLeft),
            SizedBox(height: 16.h),
            const CartReviewSummaryCard(),
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
                  label: CartFlowStrings.editOrder,
                  onPressed: () => context.pop(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: CartFlowStrings.confirmNow,
                  onPressed: () => context.pushReplacement(OrderFlowRoutes.confirmed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
