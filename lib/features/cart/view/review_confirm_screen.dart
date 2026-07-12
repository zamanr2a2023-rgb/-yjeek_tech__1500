import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
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

  void _confirmNow() {
    _timer?.cancel();
    context.pushReplacement(OrderFlowRoutes.confirmed);
  }

  @override
  Widget build(BuildContext context) {
    return CartFlowScaffold(
      title: CartFlowStrings.reviewConfirm,
      lightHeader: true,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
        children: [
          CartReviewStatusCard(
            secondsLeft: _secondsLeft,
            totalSeconds: _initialSeconds,
          ),
          SizedBox(height: 14.h),
          Text(
            CartFlowStrings.orderSummary,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 8.h),
          CartReviewSummaryCard(
            onEditAddress: () => context.push(CartRoutes.changeAddress),
          ),
        ],
      ),
      bottom: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
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
                  height: 53,
                  onPressed: _confirmNow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
