import 'package:flutter/material.dart';
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
        ),
      ),
    );
  }
}

class ServicesInfoBanner extends StatelessWidget {
  const ServicesInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🔒', style: TextStyle(fontSize: 15.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ServicesOrderFlowStrings.notChargedYet,
              style: AppTextStyles.labelSmall(color: const Color(0xFF1F5C8F)).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                height: 1.3,
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
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Text(
            ServicesOrderFlowData.payTotal,
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

class ServicesAcceptedBanner extends StatelessWidget {
  const ServicesAcceptedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD9F0E0),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        ServicesOrderFlowStrings.providerAccepted,
        style: AppTextStyles.labelMedium().copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}

class ServicesPayTimerCard extends StatelessWidget {
  const ServicesPayTimerCard({super.key, required this.timerLabel});

  final String timerLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
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
            ServicesOrderFlowStrings.payWithinHint,
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

class ServicesPayMethodCard extends StatelessWidget {
  const ServicesPayMethodCard({super.key, this.onChange});

  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ServicesOrderFlowStrings.payWith,
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
                      'V-look Wallet',
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      'Balance ${ServicesOrderFlowData.walletBalance}',
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
                  ServicesOrderFlowStrings.change,
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

class ServicesPayBreakdownCard extends StatelessWidget {
  const ServicesPayBreakdownCard({super.key});

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

class ServicesPayStickyFooter extends StatelessWidget {
  const ServicesPayStickyFooter({
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
                  ServicesOrderFlowStrings.payIn,
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
              child: GestureDetector(
                onTap: onPay,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${ServicesOrderFlowStrings.pay} ${ServicesOrderFlowData.payTotal}',
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
      ),
    );
  }
}

class ServicesConfirmedIcon extends StatelessWidget {
  const ServicesConfirmedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(32.r),
      ),
      alignment: Alignment.center,
      child: Text(
        '✓',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 30.sp,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class ServicesBookingDetailsCard extends StatelessWidget {
  const ServicesBookingDetailsCard({super.key, this.showPaid = false});

  final bool showPaid;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        children: [
          _row(ServicesOrderFlowStrings.service, ServicesOrderFlowData.serviceName),
          _row(ServicesOrderFlowStrings.provider, ServicesOrderFlowData.providerName),
          _row(ServicesOrderFlowStrings.when, ServicesOrderFlowData.appointmentWhen),
          _row(ServicesOrderFlowStrings.location, ServicesOrderFlowData.locationLabel),
          if (showPaid) _row(ServicesOrderFlowStrings.paid, ServicesOrderFlowData.confirmedPaid),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
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
        style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

class ServicesStatusTimeline extends StatelessWidget {
  const ServicesStatusTimeline({super.key, required this.steps});

  final List<ServicesOrderTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return OrderFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ServicesOrderFlowStrings.statusLabel,
            style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10.h),
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

class ServicesStatusDetailsCard extends StatelessWidget {
  const ServicesStatusDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2EB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _row(ServicesOrderFlowStrings.service, ServicesOrderFlowData.serviceName),
          _row(ServicesOrderFlowStrings.when, ServicesOrderFlowData.appointmentWhenShort),
          _row(ServicesOrderFlowStrings.location, ServicesOrderFlowData.locationLabel),
          _row(ServicesOrderFlowStrings.provider, ServicesOrderFlowData.providerName),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 72.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall().copyWith(fontSize: 12.sp),
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

class ServicesStatusActions extends StatelessWidget {
  const ServicesStatusActions({
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
        OrderOutlineButton(label: ServicesOrderFlowStrings.viewReceipt, onPressed: onReceipt),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: OrderOutlineButton(
                label: ServicesOrderFlowStrings.getDirections,
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
                    ServicesOrderFlowStrings.contactVenue,
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

class ServicesReceiptPaper extends StatelessWidget {
  const ServicesReceiptPaper({super.key});

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
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              ServicesOrderFlowStrings.servicePaid,
              style: AppTextStyles.caption(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            ServicesOrderFlowData.venueReceipt,
            style: AppTextStyles.titleSmall().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            ServicesOrderFlowData.venueAddress,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 14.h),
          _meta('Booking #', ServicesOrderFlowData.bookingId),
          _meta('Service', ServicesOrderFlowData.serviceName),
          _meta('Date', ServicesOrderFlowData.appointmentWhen),
          _meta('Location', ServicesOrderFlowData.locationLabel),
          Divider(height: 24.h, color: AppColors.border),
          for (final line in ServicesOrderFlowData.receiptBillLines) ...[
            _billRow(line),
            if (!line.isBold) SizedBox(height: 8.h),
          ],
          SizedBox(height: 8.h),
          _meta('Paid', ServicesOrderFlowStrings.paymentCard),
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

class ServicesTipChips extends StatefulWidget {
  const ServicesTipChips({super.key});

  @override
  State<ServicesTipChips> createState() => _ServicesTipChipsState();
}

class _ServicesTipChipsState extends State<ServicesTipChips> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(ServicesOrderFlowData.tipOptions.length, (index) {
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
              ServicesOrderFlowData.tipOptions[index],
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
