import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';

class ScheduledWaitingTimer extends StatelessWidget {
  const ScheduledWaitingTimer({super.key});

  @override
  Widget build(BuildContext context) {
    // Design: hollow mint track + bright #4CAF50 arc (not solid forest fill).
    return SizedBox(
      width: 108.w,
      height: 108.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 108.w,
            height: 108.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 108.w,
            height: 108.w,
            child: CircularProgressIndicator(
              value: 0.72,
              strokeWidth: 7,
              backgroundColor: const Color(0xFFDBE6D4),
              color: const Color(0xFF4CAF50),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '~3m',
            style: AppTextStyles.titleMedium(
              color: const Color(0xFF4CAF50),
            ).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledWaitingDots extends StatefulWidget {
  const ScheduledWaitingDots({super.key});

  @override
  State<ScheduledWaitingDots> createState() => _ScheduledWaitingDotsState();
}

class _ScheduledWaitingDotsState extends State<ScheduledWaitingDots> {
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
    // Figma: 9px dots · #4CAF50 at 100% / 50% / 25%.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final opacity = index == _active
            ? 1.0
            : index == (_active + 1) % 3
                ? 0.5
                : 0.25;
        return Container(
          margin: EdgeInsets.only(right: index < 2 ? 8.w : 0),
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class ScheduledSecureBanner extends StatelessWidget {
  const ScheduledSecureBanner({super.key});

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
        children: [
          Icon(Icons.shield_outlined, color: const Color(0xFF3D7BD9), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ScheduledOrderFlowStrings.notChargedYet,
              style: AppTextStyles.labelSmall(color: const Color(0xFF1F5B8F)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                height: 1.32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledOrderSummaryRow extends StatelessWidget {
  const ScheduledOrderSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: compact 12×14 card, radius 14, middle-dot summary copy.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ScheduledOrderFlowData.waitingSummary,
              style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E)).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                height: 1.32,
              ),
            ),
          ),
          Text(
            ScheduledOrderFlowData.payTotal,
            style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledAcceptedBanner extends StatelessWidget {
  const ScheduledAcceptedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: #D9EFE0 · radius 14 · check disc #4CAF50.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD9EFE0),
        borderRadius: BorderRadius.circular(14.r),
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
            alignment: Alignment.center,
            child: Icon(Icons.check, color: AppColors.white, size: 15.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ScheduledOrderFlowStrings.vendorAccepted,
              style: AppTextStyles.labelMedium(color: const Color(0xFF0F4D27)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5.sp,
                height: 1.32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledPayTimerCard extends StatelessWidget {
  const ScheduledPayTimerCard({
    super.key,
    required this.timerLabel,
    this.progress = 1,
  });

  final String timerLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // Figma CSS: card #4CAF50 · ring track #2C6B47 · fill #E8A33D · white time.
    // Single ring (no solid disc / no double forest ring).
    const cardGreen = Color(0xFF4CAF50);
    const trackGreen = Color(0xFF2C6B47);
    const ringOrange = Color(0xFFE8A33D);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 108.w,
            height: 108.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(108.w, 108.w),
                  painter: _PayCountdownRingPainter(
                    progress: progress.clamp(0.0, 1.0),
                    trackColor: trackGreen,
                    progressColor: ringOrange,
                    strokeWidth: 8,
                  ),
                ),
                Text(
                  timerLabel,
                  style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 26.sp,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            ScheduledOrderFlowStrings.payWithinTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.32,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            ScheduledOrderFlowStrings.payWithinSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: const Color(0xFFCFE8D8)).copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12.5.sp,
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayCountdownRingPainter extends CustomPainter {
  _PayCountdownRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PayCountdownRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class ScheduledPayMethodCard extends StatelessWidget {
  const ScheduledPayMethodCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: "Pay with" title outside · green 2px card · mint icon tile · Change.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ScheduledOrderFlowStrings.payWith,
          style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            height: 1.32,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1E6),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.apple, size: 20.sp, color: const Color(0xFF0F4D27)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScheduledOrderFlowStrings.applePay,
                      style: AppTextStyles.labelMedium(
                        color: const Color(0xFF1A1A1A),
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        height: 1.32,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ScheduledOrderFlowStrings.tapPayToComplete,
                      style: AppTextStyles.caption(
                        color: const Color(0xFF6B7B6E),
                      ).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.5.sp,
                        height: 1.32,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                ScheduledOrderFlowStrings.change,
                style: AppTextStyles.labelSmall(color: const Color(0xFF4CAF50)).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  height: 1.32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScheduledPayBreakdownCard extends StatelessWidget {
  const ScheduledPayBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Column(
        children: [
          _row(ScheduledOrderFlowStrings.subtotal, ScheduledOrderFlowData.paySubtotal),
          _row(
            ScheduledOrderFlowStrings.sameDayDelivery,
            ScheduledOrderFlowData.payDelivery,
          ),
          Divider(height: 16.h, thickness: 1, color: const Color(0xFFE2E8DD)),
          _row(
            ScheduledOrderFlowStrings.totalToPay,
            ScheduledOrderFlowData.payTotal,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall(
              color: bold ? const Color(0xFF1A1A1A) : const Color(0xFF6B7B6E),
            ).copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: bold ? 15.sp : 14.sp,
              height: 1.32,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              fontSize: bold ? 16.sp : 14.sp,
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledPayStickyFooter extends StatelessWidget {
  const ScheduledPayStickyFooter({
    super.key,
    required this.timerLabel,
    required this.onPay,
  });

  final String timerLabel;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    // Figma: PAY IN + time left · compact Pay pill 185×53 (not full-width Expanded).
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8DD))),
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
                  ScheduledOrderFlowStrings.payIn,
                  style: AppTextStyles.caption(color: const Color(0xFFE8A33D)).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                    height: 1.32,
                  ),
                ),
                Text(
                  timerLabel,
                  style: AppTextStyles.titleSmall(color: const Color(0xFF1A1A1A)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                    height: 1.32,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: onPay,
              child: Container(
                width: 185.w,
                height: 53.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  // Same brand green as timer card (Figma #4CAF50).
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(28.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${ScheduledOrderFlowStrings.pay} ${ScheduledOrderFlowData.payTotal}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    height: 1.32,
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

class ScheduledConfirmedIcon extends StatelessWidget {
  const ScheduledConfirmedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: 72 mint disc #E3F2EB · check #127036 (not solid brand green).
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2EB),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check_rounded,
        color: const Color(0xFF127036),
        size: 36.sp,
      ),
    );
  }
}

class ScheduledOrderDetailsCard extends StatelessWidget {
  const ScheduledOrderDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: white card padding 14×16, gap 10, border #E0E6E0, labels #6B756E.
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
          _row(ScheduledOrderFlowStrings.orderNumber, ScheduledOrderFlowData.orderId),
          _row(ScheduledOrderFlowStrings.items, ScheduledOrderFlowData.confirmedItems),
          _row(ScheduledOrderFlowStrings.delivery, ScheduledOrderFlowData.confirmedDelivery),
          _row(ScheduledOrderFlowStrings.payment, ScheduledOrderFlowData.confirmedPayment),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: const Divider(height: 1, thickness: 1, color: Color(0xFFE0E6E0)),
          ),
          _row(
            ScheduledOrderFlowStrings.total,
            ScheduledOrderFlowData.confirmedTotal,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelSmall(
                color: bold ? const Color(0xFF1A1A1A) : const Color(0xFF6B756E),
              ).copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                fontSize: bold ? 15.sp : 13.sp,
                height: 1.2,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: bold ? 16.sp : 13.sp,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledLiveMapBanner extends StatelessWidget {
  const ScheduledLiveMapBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: #E6F1FB · lock icon #3D7BD9 · copy #1F5B8F.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: const Color(0xFF3D7BD9), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ScheduledOrderFlowStrings.liveMapHint,
              style: AppTextStyles.labelSmall(color: const Color(0xFF1F5B8F)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                height: 1.28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledPackedBanner extends StatelessWidget {
  const ScheduledPackedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: #E3F2EB · text #127036 13.5.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        ScheduledOrderFlowStrings.packedBanner,
        style: AppTextStyles.labelMedium(color: const Color(0xFF127036)).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13.5.sp,
          height: 1.2,
        ),
      ),
    );
  }
}

class ScheduledStatusTimeline extends StatelessWidget {
  const ScheduledStatusTimeline({super.key, required this.steps});

  final List<ScheduledOrderTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    // Figma: STATUS label · #2E9E4D check discs · incomplete outline · no thick green rail.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUS',
            style: AppTextStyles.caption(color: const Color(0xFF8C948C)).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              height: 1.2,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 10.h),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: step.completed
                          ? const Color(0xFF2E9E4D)
                          : AppColors.white,
                      shape: BoxShape.circle,
                      border: step.completed
                          ? null
                          : Border.all(
                              color: const Color(0xFFE0E6E0),
                              width: 1.5,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: step.completed
                        ? Icon(Icons.check, color: AppColors.white, size: 12.sp)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      step.label,
                      style: AppTextStyles.labelMedium(
                        color: step.completed
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF6B756E),
                      ).copyWith(
                        fontWeight: step.completed ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13.sp,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    step.time ?? '—',
                    style: AppTextStyles.caption(color: const Color(0xFF6B756E)).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ScheduledStatusSummaryCard extends StatelessWidget {
  const ScheduledStatusSummaryCard({super.key});

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
          _row(ScheduledOrderFlowStrings.items, ScheduledOrderFlowData.statusItems),
          _row(ScheduledOrderFlowStrings.delivery, ScheduledOrderFlowData.statusDelivery),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: const Divider(height: 1, thickness: 1, color: Color(0xFFE0E6E0)),
          ),
          _row(
            ScheduledOrderFlowStrings.orderTotal,
            ScheduledOrderFlowData.confirmedTotal,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelSmall(
                color: bold ? const Color(0xFF1A1A1A) : const Color(0xFF6B756E),
              ).copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                fontSize: bold ? 15.sp : 13.sp,
                height: 1.2,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: bold ? 16.sp : 13.sp,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledReceiptPaper extends StatelessWidget {
  const ScheduledReceiptPaper({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: white paper · mint ✓ PAID · dashed dividers · flat bill rows (no grey box).
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2EB),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 12.sp, color: const Color(0xFF127036)),
                SizedBox(width: 4.w),
                Text(
                  ScheduledOrderFlowStrings.paidBadge,
                  style: AppTextStyles.caption(color: const Color(0xFF127036)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            ScheduledOrderFlowData.receiptVendor,
            style: AppTextStyles.titleSmall(color: const Color(0xFF1A1A1A)).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            ScheduledOrderFlowData.receiptDate,
            style: AppTextStyles.caption(color: const Color(0xFF6B756E)).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 1.25,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: _dashedDivider(),
          ),
          ...ScheduledOrderFlowData.receiptItems.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF6B756E),
                      ).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    item.price,
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: _dashedDivider(),
          ),
          ...ScheduledOrderFlowData.receiptBillLines.map((line) {
            final isTotal = line.isBold;
            return Padding(
              padding: EdgeInsets.only(bottom: isTotal ? 0 : 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.label,
                      style: AppTextStyles.labelSmall(
                        color: isTotal
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF6B756E),
                      ).copyWith(
                        fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
                        fontSize: isTotal ? 15.sp : 13.sp,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    line.value,
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: isTotal ? 16.sp : 13.sp,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Paid',
                  style: AppTextStyles.labelSmall(color: const Color(0xFF6B756E)).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                'Yjeek Wallet',
                style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  height: 1.2,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: _dashedDivider(),
          ),
          Row(
            children: [
              Text('🛡', style: TextStyle(fontSize: 13.sp, height: 1.2)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  ScheduledOrderFlowStrings.warrantyNote,
                  style: AppTextStyles.caption(color: const Color(0xFF6B756E)).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(count, (index) {
            return Container(
              width: dashWidth,
              height: 1,
              margin: EdgeInsets.only(right: index == count - 1 ? 0 : dashSpace),
              color: const Color(0xFFC7CCC7),
            );
          }),
        );
      },
    );
  }
}
