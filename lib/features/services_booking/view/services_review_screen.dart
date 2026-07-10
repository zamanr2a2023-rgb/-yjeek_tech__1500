import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/view/widgets/services_booking_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/services_order_flow_routes.dart';

class ServicesReviewScreen extends StatefulWidget {
  const ServicesReviewScreen({super.key});

  @override
  State<ServicesReviewScreen> createState() => _ServicesReviewScreenState();
}

class _ServicesReviewScreenState extends State<ServicesReviewScreen> {
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
        context.pushReplacement(ServicesOrderFlowRoutes.waiting);
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

  double get _progress => (_initialSeconds - _secondsLeft) / _initialSeconds;

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: ServicesBookingStrings.reviewConfirm,
      subtitle: ServicesBookingStrings.provider,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          ServicesBookingReviewStatusCard(
            secondsLeft: _secondsLeft,
            progress: _progress,
          ),
          SizedBox(height: 16.h),
          const ServicesBookingSummaryCard(),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.billSummary),
          BillSummaryCard(lines: ServicesBookingData.reviewBillLines),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: PrimaryGreenButton(
            label: ServicesBookingStrings.confirmBooking,
            onPressed: () => context.pushReplacement(ServicesOrderFlowRoutes.waiting),
          ),
        ),
      ),
    );
  }
}
