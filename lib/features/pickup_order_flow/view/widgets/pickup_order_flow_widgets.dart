import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';

class PickupWaitingTimer extends StatelessWidget {
  const PickupWaitingTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108.w,
      height: 108.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 108.w,
            height: 108.w,
            child: CircularProgressIndicator(
              value: 0.72,
              strokeWidth: 5,
              backgroundColor: const Color(0xFFE3F2EB),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          Text(
            '~3m',
            style: AppTextStyles.titleMedium(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 28.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupWaitingDots extends StatefulWidget {
  const PickupWaitingDots({super.key});

  @override
  State<PickupWaitingDots> createState() => _PickupWaitingDotsState();
}

class _PickupWaitingDotsState extends State<PickupWaitingDots> {
  int _active = 0;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return false;
      setState(() => _active = (_active + 1) % 3);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: index == _active ? AppColors.primary : const Color(0xFFC8E6D4),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class PickupSecureBanner extends StatelessWidget {
  const PickupSecureBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: const Color(0xFF3D7BD9), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              PickupOrderFlowStrings.notChargedYet,
              style: AppTextStyles.labelSmall(color: const Color(0xFF1F5B8F)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickupOrderSummaryRow extends StatelessWidget {
  const PickupOrderSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              PickupOrderFlowData.waitingSummary,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Text(
            PickupOrderFlowData.payTotal,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupAcceptedBanner extends StatelessWidget {
  const PickupAcceptedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD9F0E0),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: AppColors.white, size: 15.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              PickupOrderFlowStrings.vendorAccepted,
              style: AppTextStyles.labelMedium(color: const Color(0xFF0F4D27)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickupPayTimerCard extends StatelessWidget {
  const PickupPayTimerCard({super.key, required this.timerLabel});

  final String timerLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: const Color(0xFFE6A700), width: 4),
            ),
            alignment: Alignment.center,
            child: Text(
              timerLabel,
              style: AppTextStyles.titleMedium(color: const Color(0xFFE6A700)).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 28.sp,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            PickupOrderFlowStrings.payWithinHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: AppColors.white).copyWith(
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupPayMethodCard extends StatelessWidget {
  const PickupPayMethodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PickupOrderFlowStrings.payWith,
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 22.sp),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PickupOrderFlowStrings.yjeekWallet,
                          style: AppTextStyles.labelMedium().copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        Text(
                          PickupOrderFlowData.walletBalance,
                          style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            PickupOrderFlowStrings.change,
            style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupPayBreakdownCard extends StatelessWidget {
  const PickupPayBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          _row(PickupOrderFlowStrings.subtotal, PickupOrderFlowData.paySubtotal),
          SizedBox(height: 8.h),
          _row(
            PickupOrderFlowStrings.pickupDiscount,
            PickupOrderFlowData.payDiscount,
            isDiscount: true,
          ),
          SizedBox(height: 8.h),
          _row(
            PickupOrderFlowStrings.serviceFee,
            PickupOrderFlowData.payServiceFee,
          ),
          Divider(height: 20.h, color: AppColors.border),
          _row(
            PickupOrderFlowStrings.totalToPay,
            PickupOrderFlowData.payTotal,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ).copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontSize: bold ? 15.sp : 14.sp,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(
            color: isDiscount ? AppColors.error : null,
          ).copyWith(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 16.sp : 14.sp,
          ),
        ),
      ],
    );
  }
}

class PickupPayStickyFooter extends StatelessWidget {
  const PickupPayStickyFooter({
    super.key,
    required this.timerLabel,
    required this.onPay,
  });

  final String timerLabel;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E8),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '${PickupOrderFlowStrings.payIn} $timerLabel',
                style: AppTextStyles.caption(color: const Color(0xFF8A5A12)).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: onPay,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${PickupOrderFlowStrings.pay} ${PickupOrderFlowData.payTotal}',
                    style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PickupConfirmedIcon extends StatelessWidget {
  const PickupConfirmedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88.w,
      height: 88.w,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, color: AppColors.white, size: 44.sp),
    );
  }
}

class PickupOrderDetailsCard extends StatelessWidget {
  const PickupOrderDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          _row(PickupOrderFlowStrings.orderNumber, PickupOrderFlowData.orderId),
          _row(PickupOrderFlowStrings.items, PickupOrderFlowData.confirmedItems),
          _row(PickupOrderFlowStrings.pickup, PickupOrderFlowData.confirmedPickup),
          _row(PickupOrderFlowStrings.payment, PickupOrderFlowData.confirmedPayment),
          Divider(height: 20.h, color: AppColors.border),
          _row(
            PickupOrderFlowStrings.total,
            PickupOrderFlowData.confirmedTotal,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 16.sp : 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupNotifyBanner extends StatelessWidget {
  const PickupNotifyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_outlined, color: const Color(0xFF3D7BD9), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              PickupOrderFlowStrings.notifyBanner,
              style: AppTextStyles.labelSmall(color: const Color(0xFF1F5B8F)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickupPreparingBanner extends StatelessWidget {
  const PickupPreparingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant_outlined, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              PickupOrderFlowStrings.preparingBanner,
              style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickupStatusTimeline extends StatelessWidget {
  const PickupStatusTimeline({super.key, required this.steps});

  final List<PickupOrderTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PickupOrderFlowStrings.statusSection,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: step.completed ? AppColors.primary : AppColors.white,
                      shape: BoxShape.circle,
                      border: step.completed
                          ? null
                          : Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: step.completed
                        ? Icon(Icons.check, color: AppColors.white, size: 11.sp)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 18.h,
                      color: step.completed
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : AppColors.border,
                    ),
                ],
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: AppTextStyles.labelMedium().copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: step.completed
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (step.time != null)
                        Text(
                          step.time!,
                          style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
        ],
      ),
    );
  }
}

class PickupStatusSummaryCard extends StatelessWidget {
  const PickupStatusSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          _row(PickupOrderFlowStrings.items, PickupOrderFlowData.statusItems),
          _row(PickupOrderFlowStrings.pickup, PickupOrderFlowData.statusPickup),
          Divider(height: 20.h, color: AppColors.border),
          _row(
            PickupOrderFlowStrings.orderTotal,
            PickupOrderFlowData.confirmedTotal,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontSize: 13.sp,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 16.sp : 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class PickupReceiptPaper extends StatelessWidget {
  const PickupReceiptPaper({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              PickupOrderFlowStrings.paidBadge,
              style: AppTextStyles.caption(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            PickupOrderFlowData.vendorName,
            style: AppTextStyles.titleSmall().copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            PickupOrderFlowData.receiptDate,
            style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
              fontSize: 12.sp,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(
              color: AppColors.border,
              height: 1,
              thickness: 1,
            ),
          ),
          ...PickupOrderFlowData.receiptItems.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  Text(
                    item.price,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: AppColors.border, height: 1),
          ),
          BillSummaryCard(
            lines: PickupOrderFlowData.receiptBillLines,
            showPromo: false,
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              PickupOrderFlowStrings.paidWith,
              style: AppTextStyles.labelSmall().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.card_giftcard_outlined, size: 16.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  PickupOrderFlowStrings.collectNote,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
