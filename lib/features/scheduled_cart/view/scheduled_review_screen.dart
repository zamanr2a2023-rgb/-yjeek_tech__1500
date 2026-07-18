import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';
import 'package:yjeek_app/features/scheduled_order_flow/scheduled_order_flow_routes.dart';

class ScheduledReviewScreen extends StatefulWidget {
  const ScheduledReviewScreen({
    super.key,
    this.deliveryId = 'same-day',
  });

  final String deliveryId;

  @override
  State<ScheduledReviewScreen> createState() => _ScheduledReviewScreenState();
}

class _ScheduledReviewScreenState extends State<ScheduledReviewScreen> {
  static const _initialSeconds = 10;
  late int _secondsLeft;
  Timer? _timer;

  ScheduledDeliveryMethod get _deliveryMethod =>
      ScheduledCartData.deliveryMethods.firstWhere((m) => m.id == widget.deliveryId);

  String get _orderTotal => ScheduledCartData.checkoutTotalFor(
        method: _deliveryMethod,
        nextDayFree: widget.deliveryId == 'next-day',
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
        context.pushReplacement(ScheduledOrderFlowRoutes.waiting);
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
    // Figma: light header, Home nav, content gap 14, buttons above nav.
    return CartFlowScaffold(
      title: ScheduledCartStrings.reviewConfirm,
      lightHeader: true,
      bottomNavIndex: 0,
      backgroundColor: const Color(0xFFF2F7F2),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
              children: [
                ScheduledReviewStatusCard(secondsLeft: _secondsLeft),
                SizedBox(height: 14.h),
                ScheduledReviewSummaryCard(
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
                    label: ScheduledCartStrings.editOrder,
                    onPressed: () {
                      _timer?.cancel();
                      context.pop();
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryGreenButton(
                    label: ScheduledCartStrings.sendToVendor,
                    backgroundColor: const Color(0xFF4CAF50),
                    height: 53,
                    onPressed: () {
                      _timer?.cancel();
                      context.pushReplacement(ScheduledOrderFlowRoutes.waiting);
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
