import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DineInCountdownCircle extends StatelessWidget {
  const DineInCountdownCircle({
    super.key,
    required this.label,
    this.color = const Color(0xFF4DB04F),
    this.size,
    this.filled = true,
  });

  final String label;
  final Color color;
  final double? size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final circleSize = size ?? 116.w;
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : null,
        border: filled ? null : Border.all(color: color, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.titleMedium(
          color: filled ? AppColors.white : color,
        ).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 30.sp,
          height: 1.2,
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1F4D66),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: const Color(0xFFC9A84C), size: 16.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelSmall(color: const Color(0xFFD1E8F7)).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                height: 1.23,
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
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A572E),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              color: Color(0xFF4DB04F),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '✓',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              DineInOrderFlowStrings.vendorAccepted,
              style: AppTextStyles.labelMedium(color: const Color(0xFFCCF2D9)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DineInPayTimerCard extends StatelessWidget {
  const DineInPayTimerCard({super.key, required this.timerLabel});

  final String timerLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: const Color(0xFF4DB04F),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          DineInCountdownCircle(
            label: timerLabel,
            color: const Color(0xFFE8A33D),
            filled: true,
            size: 116.w,
          ),
          SizedBox(height: 10.h),
          Text(
            DineInOrderFlowStrings.payWithinTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              height: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            DineInOrderFlowStrings.payWithinSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: const Color(0xFFD9F0E0)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.5.sp,
              height: 1.2,
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              DineInOrderFlowData.itemSummary,
              style: AppTextStyles.labelMedium(color: const Color(0xFF6B7A6E)).copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                height: 1.23,
              ),
            ),
          ),
          Text(
            DineInOrderFlowData.orderTotal,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class DineInSuccessIcon extends StatelessWidget {
  const DineInSuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check,
        color: AppColors.white,
        size: 34.sp,
        weight: 700,
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
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: compact ? 16.h : 18.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(compact ? 18.r : 18.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#',
                style: TextStyle(
                  color: const Color(0xFFEBC34A),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                compact
                    ? DineInOrderFlowStrings.showAtCounter
                    : DineInOrderFlowStrings.arrivalCodeLabel,
                style: AppTextStyles.caption(color: const Color(0xFF9FD8B8)).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
                  height: 1.28,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            DineInOrderFlowData.arrivalCode,
            style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
              height: 1.28,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class DineInDetailsCard extends StatelessWidget {
  const DineInDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Column(
        children: [
          _row('Venue', DineInOrderFlowData.venue),
          SizedBox(height: 10.h),
          _row('Dine-in time', DineInOrderFlowData.dineInTime),
          SizedBox(height: 10.h),
          _row('Track', DineInOrderFlowData.prepTrack),
          SizedBox(height: 10.h),
          _row('Status', DineInOrderFlowData.statusPreparing),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E)).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 1.3,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class DineInStatusTimeline extends StatelessWidget {
  const DineInStatusTimeline({super.key, required this.steps});

  final List<DineInOrderTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          final done = step.completed && !step.active;
          final active = step.active;
          final pending = !step.completed && !step.active;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: pending
                          ? const Color(0xFFDCE7D4)
                          : const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: done
                        ? Icon(Icons.check, color: AppColors.white, size: 14.sp)
                        : active
                            ? Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 34.h,
                      color: done || active
                          ? (active ? const Color(0xFFE2E8DD) : const Color(0xFF4CAF50))
                          : const Color(0xFFE2E8DD),
                    ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: AppTextStyles.labelMedium(
                          color: pending
                              ? const Color(0xFF6B7B6E)
                              : AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 14.5.sp,
                          height: 1.28,
                        ),
                      ),
                      if (step.time != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          step.time!,
                          style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            height: 1.28,
                          ),
                        ),
                      ],
                      if (step.subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          step.subtitle!,
                          style: AppTextStyles.caption(
                            color: active
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF6B7B6E),
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            height: 1.28,
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

class DineInStatusInfoCard extends StatelessWidget {
  const DineInStatusInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Column(
        children: [
          _row(DineInOrderFlowStrings.venue, DineInOrderFlowData.venue),
          SizedBox(height: 10.h),
          _row(DineInOrderFlowStrings.table, DineInOrderFlowData.tableLabel),
          SizedBox(height: 10.h),
          _row(DineInOrderFlowStrings.time, DineInOrderFlowData.dineInTime),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: const Color(0xFF6B756E)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 1.23,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 1.23,
          ),
        ),
      ],
    );
  }
}

class DineInPreparingPill extends StatelessWidget {
  const DineInPreparingPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2EB),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          DineInOrderFlowStrings.preparingPill,
          style: AppTextStyles.labelSmall(color: const Color(0xFF127036)).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            height: 1.23,
          ),
        ),
      ),
    );
  }
}

class DineInPayMethodCard extends StatelessWidget {
  const DineInPayMethodCard({super.key, this.onChange});

  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E8DE)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2E6),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              AppAssets.payPinkPurse,
              width: 17.w,
              height: 17.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yjeek Wallet',
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Balance ${DineInOrderFlowData.walletBalance}',
                  style: AppTextStyles.caption(color: const Color(0xFF6B7A6E)).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Text(
              DineInOrderFlowStrings.change,
              style: AppTextStyles.labelSmall(color: const Color(0xFF4DB04F)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                height: 1.23,
              ),
            ),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _line(DineInOrderFlowStrings.subtotal, DineInOrderFlowData.subtotalAmount),
          SizedBox(height: 8.h),
          _line(DineInOrderFlowStrings.serviceFee, DineInOrderFlowData.serviceFeeAmount),
          SizedBox(height: 8.h),
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
            style: AppTextStyles.labelMedium(
              color: bold ? AppColors.textPrimary : const Color(0xFF6B7A6E),
            ).copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              fontSize: bold ? 15.sp : 13.sp,
              height: 1.23,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            fontSize: bold ? 15.sp : 13.sp,
            height: 1.23,
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
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFE3E8DE))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DineInOrderFlowStrings.payIn,
                    style: AppTextStyles.caption(color: const Color(0xFFE8A33D)).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    timerLabel,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                      height: 1.23,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 190.w,
              height: 52.h,
              child: ElevatedButton(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB04F),
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  '${DineInOrderFlowStrings.pay} ${DineInOrderFlowData.orderTotal}',
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
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

class DineInReceiptPaper extends StatelessWidget {
  const DineInReceiptPaper({super.key});

  static const Color _labelGrey = Color(0xFF6B756E);
  static const Color _dashColor = Color(0xFFC7CCC7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2EB),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  DineInOrderFlowStrings.dineInPaid,
                  style: AppTextStyles.caption(color: const Color(0xFF127036)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    height: 13 / 11,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                DineInOrderFlowData.venueReceipt,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 19 / 16,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${DineInOrderFlowData.venueAddress} · ${DineInOrderFlowData.crNumber}',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall(color: _labelGrey).copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  height: 15 / 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const _DineInReceiptDashedDivider(color: _dashColor),
          SizedBox(height: 12.h),
          _metaRow('Order #', DineInOrderFlowData.receiptOrderId),
          SizedBox(height: 8.h),
          _metaRow('Type', DineInOrderFlowStrings.typeDineIn),
          SizedBox(height: 8.h),
          _metaRow('Table', DineInOrderFlowData.tableLabel),
          SizedBox(height: 8.h),
          _metaRow('Time', DineInOrderFlowData.dineInTime),
          SizedBox(height: 12.h),
          const _DineInReceiptDashedDivider(color: _dashColor),
          SizedBox(height: 12.h),
          _columnHeader(
            DineInOrderFlowStrings.itemColumn,
            DineInOrderFlowStrings.priceColumn,
          ),
          SizedBox(height: 8.h),
          for (var i = 0; i < DineInOrderFlowData.receiptItems.length; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            _itemRow(
              DineInOrderFlowData.receiptItems[i].name,
              DineInOrderFlowData.receiptItems[i].price,
            ),
          ],
          SizedBox(height: 12.h),
          const _DineInReceiptDashedDivider(color: _dashColor),
          SizedBox(height: 12.h),
          for (var i = 0; i < DineInOrderFlowData.receiptBillLines.length; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            _billRow(DineInOrderFlowData.receiptBillLines[i]),
          ],
          SizedBox(height: 8.h),
          _metaRow(DineInOrderFlowStrings.paid, 'Yjeek Wallet'),
        ],
      ),
    );
  }

  Widget _columnHeader(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: AppTextStyles.labelSmall(color: _labelGrey).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
        ),
        Text(
          right,
          style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 16 / 13,
          ),
        ),
      ],
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: _labelGrey).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 16 / 13,
          ),
        ),
      ],
    );
  }

  Widget _itemRow(String name, String price) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.labelMedium(color: _labelGrey).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
        ),
        Text(
          price,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 16 / 13,
          ),
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
              color: line.isBold ? AppColors.textPrimary : _labelGrey,
            ).copyWith(
              fontWeight: line.isBold ? FontWeight.w700 : FontWeight.w400,
              fontSize: line.isBold ? 15.sp : 13.sp,
              height: line.isBold ? 18 / 15 : 16 / 13,
            ),
          ),
        ),
        Text(
          line.value,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: line.isBold ? FontWeight.w700 : FontWeight.w500,
            fontSize: line.isBold ? 16.sp : 13.sp,
            height: line.isBold ? 19 / 16 : 16 / 13,
          ),
        ),
      ],
    );
  }
}

class _DineInReceiptDashedDivider extends StatelessWidget {
  const _DineInReceiptDashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: _DineInDashedLinePainter(color: color),
      ),
    );
  }
}

class _DineInDashedLinePainter extends CustomPainter {
  _DineInDashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dashWidth).clamp(0, size.width), y),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DineInDashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class DineInTipChips extends StatefulWidget {
  const DineInTipChips({super.key});

  @override
  State<DineInTipChips> createState() => _DineInTipChipsState();
}

class _DineInTipChipsState extends State<DineInTipChips> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(DineInOrderFlowData.tipOptions.length, (index) {
        final selected = index == _selected;
        return GestureDetector(
          onTap: () => setState(() => _selected = selected ? null : index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected ? AppColors.cartTabActive : AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: selected ? AppColors.cartTabActive : const Color(0xFFE0E6E0),
                width: 1.2,
              ),
            ),
            child: Text(
              DineInOrderFlowData.tipOptions[index],
              style: AppTextStyles.labelSmall(
                color: selected ? AppColors.white : const Color(0xFF6B756E),
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                height: 1.2,
              ),
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
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        DineInOrderFlowStrings.reviewHint,
        style: AppTextStyles.bodySmall(color: const Color(0xFF6B756E)).copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 13.sp,
          height: 1.23,
        ),
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
