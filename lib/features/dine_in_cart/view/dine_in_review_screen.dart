import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/features/dine_in_cart/view/widgets/dine_in_cart_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/dine_in_order_flow/dine_in_order_flow_routes.dart';

class DineInReviewScreen extends StatefulWidget {
  const DineInReviewScreen({
    super.key,
    this.prepMode = DineInPrepMode.prepareNow,
  });

  final DineInPrepMode prepMode;

  @override
  State<DineInReviewScreen> createState() => _DineInReviewScreenState();
}

class _DineInReviewScreenState extends State<DineInReviewScreen> {
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
        context.pushReplacement(DineInOrderFlowRoutes.waiting);
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
      title: DineInCartStrings.reviewConfirm,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          DineInReviewStatusCard(secondsLeft: _secondsLeft),
          SizedBox(height: 16.h),
          DineInReviewSummaryCard(prepMode: widget.prepMode),
          SizedBox(height: 14.h),
          BillSummaryCard(lines: DineInCartData.billLines),
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
                  label: DineInCartStrings.editOrder,
                  onPressed: () => context.pop(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryGreenButton(
                  label: DineInCartStrings.confirmNow,
                  onPressed: () => context.pushReplacement(DineInOrderFlowRoutes.waiting),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
