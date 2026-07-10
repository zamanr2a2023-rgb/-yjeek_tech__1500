import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInCountdownCircle extends StatelessWidget {
  const DineInCountdownCircle({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.size,
  });

  final String label;
  final Color color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final circleSize = size ?? 120.w;
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.titleMedium(color: color).copyWith(
          fontWeight: FontWeight.w800,
          fontSize: (circleSize * 0.22).sp,
        ),
      ),
    );
  }
}

class DineInSecureBanner extends StatelessWidget {
  const DineInSecureBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B4A),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: AppColors.white, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                fontSize: 12.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DineInAcceptedBanner extends StatelessWidget {
  const DineInAcceptedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: const Color(0xFF1B4332),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.white, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            DineInOrderFlowStrings.vendorAccepted,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class DineInOrderSummaryRow extends StatelessWidget {
  const DineInOrderSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              DineInOrderFlowData.itemSummary,
              style: AppTextStyles.labelMedium().copyWith(fontSize: 14.sp),
            ),
          ),
          Text(
            DineInOrderFlowData.orderTotal,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class DineInArrivalCodeCard extends StatelessWidget {
  const DineInArrivalCodeCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14.w : 20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(compact ? 14.r : 18.r),
      ),
      child: Column(
        children: [
          Text(
            DineInOrderFlowData.arrivalCode,
            style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w800,
              fontSize: compact ? 20.sp : 26.sp,
              letterSpacing: 1.2,
            ),
          ),
          if (compact) ...[
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_active_outlined, color: AppColors.white, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  DineInOrderFlowStrings.showAtCounter,
                  style: AppTextStyles.caption(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class DineInDetailsCard extends StatelessWidget {
  const DineInDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          _row('Venue', DineInOrderFlowData.venue),
          _row('Dine-in time', DineInOrderFlowData.dineInTime),
          _row('Track', DineInOrderFlowData.prepTrack),
          _row('Status', DineInOrderFlowData.statusPreparing),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelMedium().copyWith(
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

class DineInStatusTimeline extends StatelessWidget {
  const DineInStatusTimeline({super.key, required this.steps});

  final List<DineInOrderTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          final done = step.completed;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: step.active ? 24.w : 20.w,
                    height: step.active ? 24.w : 20.w,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done ? AppColors.primary : AppColors.border,
                        width: done && !step.active ? 0 : 1.5,
                      ),
                    ),
                    child: done && !step.active
                        ? Icon(Icons.check, color: AppColors.white, size: 12.sp)
                        : step.active
                            ? null
                            : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: step.active ? 36.h : 28.h,
                      color: done ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.label,
                              style: AppTextStyles.labelMedium().copyWith(
                                fontWeight: step.active ? FontWeight.w800 : FontWeight.w600,
                                fontSize: step.active ? 15.sp : 14.sp,
                                color: done ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (step.time != null)
                            Text(
                              step.time!,
                              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                                fontSize: 12.sp,
                              ),
                            ),
                        ],
                      ),
                      if (step.subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          step.subtitle!,
                          style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class DineInPayMethodCard extends StatelessWidget {
  const DineInPayMethodCard({super.key, this.onChange});

  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DineInOrderFlowStrings.payWith,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 22.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yjeek Wallet',
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      'Balance ${DineInOrderFlowData.walletBalance}',
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onChange,
                child: Text(
                  DineInOrderFlowStrings.change,
                  style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
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

class DineInPayBreakdownCard extends StatelessWidget {
  const DineInPayBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          _line(DineInOrderFlowStrings.subtotal, DineInOrderFlowData.subtotalAmount),
          SizedBox(height: 8.h),
          _line(DineInOrderFlowStrings.serviceFee, DineInOrderFlowData.serviceFeeAmount),
          Divider(height: 20.h, color: AppColors.border),
          _line(DineInOrderFlowStrings.totalToPay, DineInOrderFlowData.orderTotal, bold: true),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: bold ? 16.sp : 14.sp,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium().copyWith(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 16.sp : 14.sp,
          ),
        ),
      ],
    );
  }
}

class DineInPayStickyFooter extends StatelessWidget {
  const DineInPayStickyFooter({
    super.key,
    required this.timerLabel,
    required this.onPay,
  });

  final String timerLabel;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DineInOrderFlowStrings.payIn,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  timerLabel,
                  style: AppTextStyles.labelMedium(color: const Color(0xFFE6A700)).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: PrimaryGreenButton(
                label: '${DineInOrderFlowStrings.pay} ${DineInOrderFlowData.orderTotal}',
                onPressed: onPay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DineInReceiptPaper extends StatelessWidget {
  const DineInReceiptPaper({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.accountIconBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              DineInOrderFlowStrings.dineInPaid,
              style: AppTextStyles.caption(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            DineInOrderFlowData.venueReceipt,
            style: AppTextStyles.titleSmall().copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${DineInOrderFlowData.venueAddress} · ${DineInOrderFlowData.crNumber}',
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontSize: 11.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 14.h),
          _meta('Order #', DineInOrderFlowData.orderId),
          _meta('Type', DineInOrderFlowStrings.typeDineIn),
          _meta('Table', DineInOrderFlowData.tableLabel),
          _meta('Time', DineInOrderFlowData.dineInTime),
          Divider(height: 24.h, color: AppColors.border),
          for (final item in DineInOrderFlowData.receiptItems) ...[
            _itemRow(item.name, item.price),
            SizedBox(height: 8.h),
          ],
          Divider(height: 24.h, color: AppColors.border),
          for (final line in DineInOrderFlowData.receiptBillLines) ...[
            _billRow(line),
            if (!line.isBold) SizedBox(height: 8.h),
          ],
          SizedBox(height: 8.h),
          _meta('${DineInOrderFlowStrings.paid}:', 'Yjeek Wallet'),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 72.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(fontSize: 12.sp),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(String name, String price) {
    return Row(
      children: [
        Expanded(child: Text(name, style: AppTextStyles.labelMedium().copyWith(fontSize: 13.sp))),
        Text(
          price,
          style: AppTextStyles.labelMedium().copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
        ),
      ],
    );
  }

  Widget _billRow(BillLine line) {
    return Row(
      children: [
        Expanded(
          child: Text(
            line.label,
            style: AppTextStyles.labelSmall(
              color: line.isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ).copyWith(
              fontWeight: line.isBold ? FontWeight.w800 : FontWeight.w500,
              fontSize: line.isBold ? 16.sp : 13.sp,
            ),
          ),
        ),
        Text(
          line.value,
          style: AppTextStyles.labelMedium(
            color: line.isDiscount ? AppColors.error : AppColors.textPrimary,
          ).copyWith(
            fontWeight: line.isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: line.isBold ? 18.sp : 13.sp,
          ),
        ),
      ],
    );
  }
}

class DineInTipChips extends StatefulWidget {
  const DineInTipChips({super.key});

  @override
  State<DineInTipChips> createState() => _DineInTipChipsState();
}

class _DineInTipChipsState extends State<DineInTipChips> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(DineInOrderFlowData.tipOptions.length, (index) {
        final selected = index == _selected;
        return GestureDetector(
          onTap: () => setState(() => _selected = index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              DineInOrderFlowData.tipOptions[index],
              style: AppTextStyles.labelSmall(
                color: selected ? AppColors.white : AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),
            ),
          ),
        );
      }),
    );
  }
}

class DineInReviewField extends StatelessWidget {
  const DineInReviewField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88.h,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.topLeft,
      child: Text(
        DineInOrderFlowStrings.reviewHint,
        style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(fontSize: 14.sp),
      ),
    );
  }
}

class DineInStatusActions extends StatelessWidget {
  const DineInStatusActions({
    super.key,
    this.onReceipt,
    this.onDirections,
    this.onContact,
  });

  final VoidCallback? onReceipt;
  final VoidCallback? onDirections;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrderOutlineButton(label: DineInOrderFlowStrings.viewReceipt, onPressed: onReceipt),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: OrderOutlineButton(
                label: DineInOrderFlowStrings.getDirections,
                onPressed: onDirections,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: GestureDetector(
                onTap: onContact,
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DineInOrderFlowStrings.contactVenue,
                    style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
