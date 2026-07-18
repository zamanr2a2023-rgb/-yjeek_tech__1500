import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';

class ServicesLocationToggle extends StatelessWidget {
  const ServicesLocationToggle({
    super.key,
    required this.atVenue,
    required this.onChanged,
  });

  final bool atVenue;
  final ValueChanged<bool> onChanged;

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

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
          color: selected ? AppColors.offerBadgeGreenBg : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.cartTabActive : _chipBorder,
            width: selected ? 1.5 : 1.2,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: selected ? AppColors.offerBadgeGreenText : _labelMuted,
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

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

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
                color: selected ? AppColors.cartTabActive : AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected ? AppColors.cartTabActive : _chipBorder,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day,
                    style: AppTextStyles.caption(
                      color: selected ? AppColors.white : _labelMuted,
                    ).copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      height: 13 / 11,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${date.date}',
                    style: AppTextStyles.labelMedium(
                      color: selected ? AppColors.white : AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      height: 19 / 16,
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

  static const Color _chipBorder = Color(0xFFE0E6E0);

  static const Color _labelMuted = Color(0xFF6B756E);

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
            height: 29.h,
            padding: EdgeInsets.symmetric(horizontal: 13.w),
            decoration: BoxDecoration(
              color: selected ? AppColors.offerBadgeGreenBg : AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: selected ? AppColors.cartTabActive : _chipBorder,
                width: selected ? 1.5 : 1.2,
              ),
            ),
            // Center(widthFactor: 1) keeps chip intrinsic width so Wrap
            // lays out compact chips in a grid (not full-width rows).
            child: Center(
              widthFactor: 1,
              child: Text(
                slots[index],
                style: AppTextStyles.labelSmall(
                  color: selected ? AppColors.offerBadgeGreenText : _labelMuted,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.5.sp),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ServicesTipSelector extends StatelessWidget {
  const ServicesTipSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<TipOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (index) {
        final selected = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < options.length - 1 ? 8.w : 0),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                  color: selected ? AppColors.cartTabActive : AppColors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: selected ? AppColors.cartTabActive : _chipBorder,
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  options[index].label,
                  style: AppTextStyles.labelSmall(
                    color: selected ? AppColors.white : _labelMuted,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.5.sp),
                ),
              ),
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

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);
  static const Color _iconTile = Color(0xFFDBE8DE);

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
            color: selected ? AppColors.cartTabActive : _chipBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: _iconTile,
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
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 15.sp),
                  ),
                  Text(
                    '🕒 ${item.duration} · BHD ${item.price}',
                    style: AppTextStyles.caption(color: _labelMuted).copyWith(
                      fontSize: 12.5.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.cartTabActive
                    : AppColors.offerBadgeGreenBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: selected
                  ? Text(
                      '✓',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    )
                  : Text(
                      '+',
                      style: TextStyle(
                        color: AppColors.offerBadgeGreenText,
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

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _chipBorder),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  ServicesBookingStrings.enterPromoCode,
                  style: AppTextStyles.bodySmall(color: _labelMuted).copyWith(
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 84.w,
              height: 48.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cartTabActive,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                ServicesBookingStrings.apply,
                style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ],
        ),
        if (applied) ...[
          SizedBox(height: 8.h),
          Text(
            ServicesBookingStrings.promoApplied,
            style: AppTextStyles.labelSmall(
              color: AppColors.cartTabActive,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
          ),
        ],
      ],
    );
  }
}

class ServicesServiceCard extends StatelessWidget {
  const ServicesServiceCard({super.key});

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _chipBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServicesBookingData.mainService,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
                Text(
                  ServicesBookingData.mainServiceDuration,
                  style: AppTextStyles.caption(color: _labelMuted).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ServicesBookingData.mainServicePrice,
            style: AppTextStyles.labelSmall(
              color: AppColors.offerBadgeGreenText,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

class ServicesLocationCard extends StatelessWidget {
  const ServicesLocationCard({super.key});

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _chipBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.offerBadgeGreenBg,
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
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
                Text(
                  ServicesBookingStrings.venueAddress,
                  style: AppTextStyles.caption(color: _labelMuted).copyWith(
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

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _chipBorder),
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
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: _labelMuted).copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium(
              color: AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w500, fontSize: 13.sp),
          ),
        ],
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

  static const Color _ringTrack = Color(0xFF2C6B47);
  static const Color _ringProgress = Color(0xFFC9A84C);

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
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
                SizedBox(
                  width: 92.w,
                  height: 92.w,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 7,
                    backgroundColor: _ringTrack,
                    color: _ringProgress,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$secondsLeft',
                  style: AppTextStyles.titleMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 38.sp,
                    height: 1.1,
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
          SizedBox(height: 6.h),
          Text(
            ServicesBookingStrings.autoConfirmHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(
              color: const Color(0xFFCFE8D8),
            ).copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12.5.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: _ringTrack,
              color: _ringProgress,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesBookingSummaryCard extends StatelessWidget {
  const ServicesBookingSummaryCard({super.key});

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _chipBorder),
      ),
      child: Column(
        children: [
          _row(ServicesBookingStrings.service, ServicesBookingData.mainService),
          _row(ServicesBookingStrings.providerLabel, ServicesBookingStrings.provider),
          _row(ServicesBookingStrings.when, ServicesBookingData.appointmentWhen),
          _row(ServicesBookingStrings.location, ServicesBookingStrings.venueLocationShort),
          _row(ServicesBookingStrings.people, ServicesBookingData.peopleCount, isLast: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall(color: _labelMuted).copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              height: 16 / 13,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium(
                color: AppColors.textPrimary,
              ).copyWith(
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
