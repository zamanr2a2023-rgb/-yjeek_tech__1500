import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';

class ServicesWaitingTimer extends StatelessWidget {
  const ServicesWaitingTimer({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116.w,
      height: 116.w,
      decoration: const BoxDecoration(
        color: Color(0xFF4DB04F),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 30.sp,
          height: 36 / 30,
        ),
      ),
    );
  }
}

class ServicesInfoBanner extends StatelessWidget {
  const ServicesInfoBanner({super.key});

  static const Color _bannerBg = Color(0xFFE6F2FA);
  static const Color _bannerText = Color(0xFF1F5C8F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _bannerBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('🔒', style: TextStyle(fontSize: 15.sp, height: 1)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ServicesOrderFlowStrings.notChargedYet,
              style: AppTextStyles.labelSmall(color: _bannerText).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                height: 16 / 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesBookingSummaryRow extends StatelessWidget {
  const ServicesBookingSummaryRow({super.key});

  static const Color _muted = Color(0xFF6B7A6E);

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
              ServicesOrderFlowData.bookingSummary,
              style: AppTextStyles.labelSmall(color: _muted).copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                height: 16 / 13,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            ServicesOrderFlowData.payTotal,
            style: AppTextStyles.labelMedium(
              color: AppColors.textPrimary,
            ).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 19 / 16,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesCancelBookingButton extends StatelessWidget {
  const ServicesCancelBookingButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: Color(0xFFE3E8DE), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          ServicesOrderFlowStrings.cancelBooking,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
            height: 18 / 15,
          ),
        ),
      ),
    );
  }
}

class ServicesAcceptedBanner extends StatelessWidget {
  const ServicesAcceptedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 16.w, 12.h),
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
              color: Color(0xFF4DB04F),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '✓',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ServicesOrderFlowStrings.providerAccepted,
              style: AppTextStyles.labelMedium(
                color: const Color(0xFF0F4D26),
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                height: 17 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesPayTimerCard extends StatelessWidget {
  const ServicesPayTimerCard({super.key, required this.timerLabel});

  final String timerLabel;

  static const Color _panel = Color(0xFF4DB04F);
  static const Color _timerFill = Color(0xFFE8A33D);
  static const Color _hintMuted = Color(0xFFD9F0E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Container(
            width: 116.w,
            height: 116.w,
            decoration: const BoxDecoration(
              color: _timerFill,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              timerLabel,
              style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 30.sp,
                height: 36 / 30,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            ServicesOrderFlowStrings.payWithinTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              height: 19 / 16,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            ServicesOrderFlowStrings.payWithinBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: _hintMuted).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.5.sp,
              height: 15 / 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesPayMethodCard extends StatelessWidget {
  const ServicesPayMethodCard({super.key, this.onChange});

  final VoidCallback? onChange;

  static const Color _muted = Color(0xFF6B7A6E);
  static const Color _accent = Color(0xFF4DB04F);
  static const Color _iconTile = Color(0xFFEBF2E6);
  static const Color _border = Color(0xFFE3E8DE);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ServicesOrderFlowStrings.payWith,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            height: 18 / 15,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: _iconTile,
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
                      ServicesOrderFlowStrings.yjeekWallet,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        height: 17 / 14,
                      ),
                    ),
                    Text(
                      'Balance ${ServicesOrderFlowData.walletBalance}',
                      style: AppTextStyles.caption(color: _muted).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        height: 15 / 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onChange,
                child: Text(
                  ServicesOrderFlowStrings.change,
                  style: AppTextStyles.labelSmall(color: _accent).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    height: 16 / 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ServicesPayBreakdownCard extends StatelessWidget {
  const ServicesPayBreakdownCard({super.key});

  static const Color _muted = Color(0xFF6B7A6E);

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          _line(ServicesOrderFlowStrings.subtotal, ServicesOrderFlowData.subtotalAmount),
          SizedBox(height: 8.h),
          _line(ServicesOrderFlowStrings.serviceFee, ServicesOrderFlowData.serviceFeeAmount),
          Divider(height: 20.h, color: AppColors.border),
          _line(ServicesOrderFlowStrings.totalToPay, ServicesOrderFlowData.payTotal, bold: true),
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
              color: bold ? AppColors.textPrimary : _muted,
            ).copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              fontSize: bold ? 16.sp : 13.sp,
              height: bold ? 19 / 16 : 16 / 13,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(
            color: AppColors.textPrimary,
          ).copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            fontSize: bold ? 17.sp : 13.sp,
            height: bold ? 21 / 17 : 16 / 13,
          ),
        ),
      ],
    );
  }
}

class ServicesPayStickyFooter extends StatelessWidget {
  const ServicesPayStickyFooter({
    super.key,
    required this.timerLabel,
    required this.onPay,
  });

  final String timerLabel;
  final VoidCallback onPay;

  static const Color _accent = Color(0xFFE8A33D);
  static const Color _payGreen = Color(0xFF4DB04F);
  static const Color _border = Color(0xFFE3E8DE);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: _border)),
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
                    ServicesOrderFlowStrings.payIn,
                    style: AppTextStyles.caption(color: _accent).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                      height: 13 / 11,
                    ),
                  ),
                  Text(
                    timerLabel,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                      height: 27 / 22,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 190.w,
              height: 52.h,
              child: ElevatedButton(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _payGreen,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                ),
                child: Text(
                  '${ServicesOrderFlowStrings.pay} ${ServicesOrderFlowData.payTotal}',
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    height: 19 / 16,
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

class ServicesConfirmedIcon extends StatelessWidget {
  const ServicesConfirmedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: 64×36 mint capsule, dark green check (#127036).
    return Container(
      width: 64.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(32.r),
      ),
      alignment: Alignment.center,
      child: Text(
        '✓',
        style: GoogleFonts.inter(
          color: const Color(0xFF127036),
          fontSize: 30.sp,
          fontWeight: FontWeight.w700,
          height: 36 / 30,
        ),
      ),
    );
  }
}

class ServicesBookingDetailsCard extends StatelessWidget {
  const ServicesBookingDetailsCard({super.key, this.showPaid = false});

  final bool showPaid;

  static const Color _muted = Color(0xFF6B756E);
  static const Color _value = Color(0xFF1A1A1A);
  static const Color _border = Color(0xFFE0E6E0);

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      (ServicesOrderFlowStrings.service, ServicesOrderFlowData.serviceName),
      (ServicesOrderFlowStrings.provider, ServicesOrderFlowData.providerName),
      (ServicesOrderFlowStrings.when, ServicesOrderFlowData.appointmentWhen),
      (ServicesOrderFlowStrings.location, ServicesOrderFlowData.locationLabel),
      if (showPaid)
        (ServicesOrderFlowStrings.paid, ServicesOrderFlowData.confirmedPaid),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _row(rows[i].$1, rows[i].$2),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return SizedBox(
      height: 16.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _muted,
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _value,
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesStatusBadge extends StatelessWidget {
  const ServicesStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        ServicesOrderFlowStrings.statusConfirmed,
        style: GoogleFonts.inter(
          color: const Color(0xFF127036),
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
          height: 16 / 13,
        ),
      ),
    );
  }
}

class ServicesStatusTimeline extends StatelessWidget {
  const ServicesStatusTimeline({super.key, required this.steps});

  final List<ServicesOrderTimelineStep> steps;

  static const Color _statusLabel = Color(0xFF8C948C);
  static const Color _border = Color(0xFFE0E6E0);

  @override
  Widget build(BuildContext context) {
    // Figma: white card, left-aligned STATUS + rows (no thick connector).
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ServicesOrderFlowStrings.statusLabel,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: _statusLabel,
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              height: 13 / 11,
            ),
          ),
          SizedBox(height: 10.h),
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _StatusTimelineRow(step: steps[i]),
          ],
        ],
      ),
    );
  }
}

class _StatusTimelineRow extends StatelessWidget {
  const _StatusTimelineRow({required this.step});

  final ServicesOrderTimelineStep step;

  @override
  Widget build(BuildContext context) {
    final done = step.completed;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: done ? const Color(0xFF2E9E4D) : AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: done
                ? null
                : Border.all(color: const Color(0xFFE0E6E0), width: 1.5),
          ),
          alignment: Alignment.center,
          child: done
              ? Text(
                  '✓',
                  style: GoogleFonts.inter(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    height: 13 / 11,
                  ),
                )
              : null,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            step.label,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: done ? const Color(0xFF1A1A1A) : const Color(0xFF6B756E),
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
        ),
        Text(
          step.time ?? '—',
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
            color: const Color(0xFF6B756E),
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
            height: 15 / 12,
          ),
        ),
      ],
    );
  }
}

class ServicesStatusDetailsCard extends StatelessWidget {
  const ServicesStatusDetailsCard({super.key});

  static const Color _muted = Color(0xFF6B756E);
  static const Color _value = Color(0xFF1A1A1A);
  static const Color _border = Color(0xFFE0E6E0);

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      (ServicesOrderFlowStrings.service, ServicesOrderFlowData.serviceName),
      (ServicesOrderFlowStrings.when, ServicesOrderFlowData.appointmentWhenShort),
      (ServicesOrderFlowStrings.location, ServicesOrderFlowData.locationLabel),
      (ServicesOrderFlowStrings.provider, ServicesOrderFlowData.providerName),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _row(rows[i].$1, rows[i].$2),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return SizedBox(
      height: 16.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _muted,
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _value,
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesStatusActions extends StatelessWidget {
  const ServicesStatusActions({
    super.key,
    this.onReceipt,
    this.onDirections,
    this.onContact,
    this.stickyOnly = false,
  });

  final VoidCallback? onReceipt;
  final VoidCallback? onDirections;
  final VoidCallback? onContact;

  /// When true, renders only the Figma sticky footer (directions + contact).
  final bool stickyOnly;

  @override
  Widget build(BuildContext context) {
    final pair = Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 49.h,
              child: OutlinedButton(
                onPressed: onDirections,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A1A),
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: Color(0xFFE2E8DD), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                child: Text(
                  ServicesOrderFlowStrings.getDirections,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    height: 1.28,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 49.h,
              child: ElevatedButton(
                onPressed: onContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
                  ServicesOrderFlowStrings.contactVenue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    height: 1.28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (stickyOnly) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8DD))),
        ),
        child: pair,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onReceipt != null) ...[
          OrderOutlineButton(
            label: ServicesOrderFlowStrings.viewReceipt,
            onPressed: onReceipt,
          ),
          SizedBox(height: 10.h),
        ],
        pair,
      ],
    );
  }
}

class ServicesReceiptPaper extends StatelessWidget {
  const ServicesReceiptPaper({super.key});

  static const Color _muted = Color(0xFF6B756E);
  static const Color _text = Color(0xFF1A1A1A);
  static const Color _dash = Color(0xFFC7CCC7);

  @override
  Widget build(BuildContext context) {
    // Figma receipt: centered header block, then label/value rows.
    return OrderFlowCard(
      padding: EdgeInsets.all(18.w),
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
                  ServicesOrderFlowStrings.servicePaid,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF127036),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    height: 13 / 11,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                ServicesOrderFlowData.venueReceipt,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: _text,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 19 / 16,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                ServicesOrderFlowData.venueAddress,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: _muted,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  height: 15 / 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const _ServicesReceiptDashedDivider(color: _dash),
          SizedBox(height: 12.h),
          _metaRow('Booking #', ServicesOrderFlowData.bookingId),
          SizedBox(height: 8.h),
          _metaRow(ServicesOrderFlowStrings.service, ServicesOrderFlowData.serviceName),
          SizedBox(height: 8.h),
          _metaRow(ServicesOrderFlowStrings.when, ServicesOrderFlowData.appointmentWhen),
          SizedBox(height: 8.h),
          _metaRow(ServicesOrderFlowStrings.location, ServicesOrderFlowData.locationLabel),
          SizedBox(height: 12.h),
          const _ServicesReceiptDashedDivider(color: _dash),
          SizedBox(height: 12.h),
          for (var i = 0; i < ServicesOrderFlowData.receiptBillLines.length; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            _billRow(ServicesOrderFlowData.receiptBillLines[i]),
          ],
          SizedBox(height: 8.h),
          _metaRow(ServicesOrderFlowStrings.paid, ServicesOrderFlowStrings.paymentCard),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: _muted,
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
            color: _text,
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            height: 16 / 13,
          ),
        ),
      ],
    );
  }

  Widget _billRow(BillLine line) {
    final bold = line.isBold;
    return Row(
      children: [
        Expanded(
          child: Text(
            line.label,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: bold ? _text : _muted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              fontSize: bold ? 15.sp : 13.sp,
              height: bold ? 18 / 15 : 16 / 13,
            ),
          ),
        ),
        Text(
          line.value,
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
            color: _text,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontSize: bold ? 16.sp : 13.sp,
            height: bold ? 19 / 16 : 16 / 13,
          ),
        ),
      ],
    );
  }
}

class _ServicesReceiptDashedDivider extends StatelessWidget {
  const _ServicesReceiptDashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: _ServicesDashedLinePainter(color: color),
      ),
    );
  }
}

class _ServicesDashedLinePainter extends CustomPainter {
  _ServicesDashedLinePainter({required this.color});

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
  bool shouldRepaint(covariant _ServicesDashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class ServicesTipChips extends StatefulWidget {
  const ServicesTipChips({super.key});

  @override
  State<ServicesTipChips> createState() => _ServicesTipChipsState();
}

class _ServicesTipChipsState extends State<ServicesTipChips> {
  int _selected = 1;

  static const Color _muted = Color(0xFF6B756E);
  static const Color _border = Color(0xFFE0E6E0);
  static const Color _selectedBg = Color(0xFF2E9E4D);

  @override
  Widget build(BuildContext context) {
    // Figma: single left-aligned row, chips padding 7/13, radius 20.
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(ServicesOrderFlowData.tipOptions.length, (index) {
            final selected = index == _selected;
            return Padding(
              padding: EdgeInsets.only(
                right: index < ServicesOrderFlowData.tipOptions.length - 1 ? 8.w : 0,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _selected = index),
                child: Container(
                  height: 29.h,
                  padding: EdgeInsets.symmetric(horizontal: 13.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? _selectedBg : AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected ? _selectedBg : _border,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    ServicesOrderFlowData.tipOptions[index],
                    style: GoogleFonts.inter(
                      color: selected ? AppColors.white : _muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5.sp,
                      height: 15 / 12.5,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
