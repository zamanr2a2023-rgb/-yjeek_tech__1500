import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/features/services_booking/view/widgets/services_booking_widgets.dart';

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
        _goToCheckout();
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

  double get _progress => _secondsLeft / _initialSeconds;

  void _goToCheckout() {
    if (!mounted) return;
    context.push(ServicesBookingRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: ServicesBookingStrings.reviewConfirm,
      subtitle: ServicesBookingStrings.provider,
      lightHeader: true,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        children: [
          ServicesBookingReviewStatusCard(
            secondsLeft: _secondsLeft,
            progress: _progress,
          ),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.bookingSummary),
          const ServicesBookingSummaryCard(),
          SizedBox(height: 14.h),
          const CartSectionTitle(ServicesBookingStrings.billSummary),
          BillSummaryCard(lines: ServicesBookingData.reviewBillLines),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
          child: PrimaryGreenButton(
            label: ServicesBookingStrings.confirmBooking,
            backgroundColor: AppColors.cartTabActive,
            height: 52,
            onPressed: () {
              _timer?.cancel();
              _goToCheckout();
            },
          ),
        ),
      ),
    );
  }
}
