import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';

class ServicesLocationToggle extends StatelessWidget {
  const ServicesLocationToggle({
    super.key,
    required this.atVenue,
    required this.onChanged,
  });

  final bool atVenue;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(
          ServicesBookingStrings.atVenue,
          selected: atVenue,
          onTap: () => onChanged(true),
        ),
        SizedBox(width: 8.w),
        _pill(
          ServicesBookingStrings.atHome,
          selected: !atVenue,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }

  Widget _pill(String label, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE3F2EB) : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1.2,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.5.sp),
        ),
      ),
    );
  }
}

class ServicesDatePicker extends StatelessWidget {
  const ServicesDatePicker({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<BookingDateOption> dates;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              width: 58.w,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE3F2EB) : AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.5 : 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.date}',
                      style: AppTextStyles.labelMedium(
                        color: selected ? AppColors.white : AppColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ServicesTimeGrid extends StatelessWidget {
  const ServicesTimeGrid({
    super.key,
    required this.slots,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> slots;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(slots.length, (index) {
        final selected = index == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE3F2EB) : AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1.2,
              ),
            ),
            child: Text(
              slots[index],
              style: AppTextStyles.labelSmall(
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
          ),
        );
      }),
    );
  }
}

class ServicesUpsellCard extends StatelessWidget {
  const ServicesUpsellCard({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggle,
  });

  final BookingUpsellItem item;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 12.w, 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2EB),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Text(item.emoji, style: TextStyle(fontSize: 20.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    '${item.duration} · BHD ${item.price}',
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : const Color(0xFFE3F2EB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: selected
                  ? Icon(Icons.check, color: AppColors.white, size: 14.sp)
                  : Text(
                      '+',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesPromoField extends StatelessWidget {
  const ServicesPromoField({super.key, this.applied = true});

  final bool applied;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  applied ? 'WELCOME10' : ServicesBookingStrings.promoCode,
                  style: AppTextStyles.bodySmall(
                    color: applied ? AppColors.textPrimary : AppColors.textSecondary,
                  ).copyWith(fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                ServicesBookingStrings.apply,
                style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
        if (applied) ...[
          SizedBox(height: 8.h),
          Text(
            ServicesBookingStrings.promoApplied,
            style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }
}

class ServicesServiceCard extends StatelessWidget {
  const ServicesServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServicesBookingData.mainService,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  ServicesBookingData.mainServiceDuration,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ServicesBookingData.mainServicePrice,
            style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesLocationCard extends StatelessWidget {
  const ServicesLocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2EB),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text('📍', style: TextStyle(fontSize: 18.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServicesBookingStrings.venueLocationLabel,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  ServicesBookingStrings.venueAddress,
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 12.sp,
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

class ServicesAppointmentCard extends StatelessWidget {
  const ServicesAppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _row(ServicesBookingStrings.service, ServicesBookingData.mainService),
          _row(ServicesBookingStrings.when, ServicesBookingData.appointmentWhen),
          _row(ServicesBookingStrings.specialist, ServicesBookingData.specialistName),
          _row(ServicesBookingStrings.people, ServicesBookingData.peopleCount),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

class ServicesPaymentMethodList extends StatelessWidget {
  const ServicesPaymentMethodList({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ServicesPaymentOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final selected = option.id == selectedId;
          return Column(
            children: [
              if (index > 0) Divider(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
              InkWell(
                onTap: () => onSelected(option.id),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    children: [
                      if (option.icon != null)
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2EB),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(option.icon, size: 20.sp, color: AppColors.primary),
                        ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: AppTextStyles.labelMedium().copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            if (option.subtitle != null)
                              Text(
                                option.subtitle!,
                                style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                            width: selected ? 6 : 1.5,
                          ),
                        ),
                      ),
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

class ServicesBookingReviewStatusCard extends StatelessWidget {
  const ServicesBookingReviewStatusCard({
    super.key,
    required this.secondsLeft,
    required this.progress,
  });

  final int secondsLeft;
  final double progress;

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
          SizedBox(
            width: 92.w,
            height: 92.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFF2C6B47),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2C6B47)),
                ),
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC9A84C),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$secondsLeft',
                    style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 38.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            ServicesBookingStrings.sendingBooking,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ServicesBookingStrings.autoConfirmHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: AppColors.white.withValues(alpha: 0.95)).copyWith(
              fontSize: 12.5.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4.h,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesBookingSummaryCard extends StatelessWidget {
  const ServicesBookingSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ServicesBookingStrings.bookingSummary,
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          _row(ServicesBookingStrings.service, ServicesBookingData.mainService),
          _row(ServicesBookingStrings.providerLabel, ServicesBookingStrings.provider),
          _row(ServicesBookingStrings.when, ServicesBookingData.appointmentWhen),
          _row(ServicesBookingStrings.location, ServicesBookingStrings.venueLocationLabel),
          _row(ServicesBookingStrings.people, ServicesBookingData.peopleCount),
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
            width: 72.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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
