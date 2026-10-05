import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/services_booking/model/services_booking_data.dart';

class ServicesLocationToggle extends StatelessWidget {
  const ServicesLocationToggle({
    super.key,
    required this.atVenue,
    required this.onChanged,
    this.allowVenue = true,
    this.allowHome = true,
  });

  final bool atVenue;
  final ValueChanged<bool> onChanged;
  final bool allowVenue;
  final bool allowHome;

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(
          ServicesBookingStrings.atVenue,
          selected: atVenue,
          enabled: allowVenue,
          onTap: () => onChanged(true),
        ),
        SizedBox(width: 8.w),
        _pill(
          ServicesBookingStrings.atHome,
          selected: !atVenue,
          enabled: allowHome,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }

  Widget _pill(
    String label, {
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
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
      ),
    );
  }
}

class ServicesBookingDateField extends StatelessWidget {
  const ServicesBookingDateField({
    super.key,
    required this.selectedDay,
    required this.firstDay,
    required this.lastDay,
    required this.selectableDayPredicate,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final bool Function(DateTime day) selectableDayPredicate;
  final ValueChanged<DateTime> onDaySelected;

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _clampInitial() {
    var d = _dayOnly(selectedDay);
    final first = _dayOnly(firstDay);
    final last = _dayOnly(lastDay);
    if (d.isBefore(first)) d = first;
    if (d.isAfter(last)) d = last;
    if (!selectableDayPredicate(d)) {
      for (var i = 0; i <= last.difference(first).inDays; i++) {
        final candidate = first.add(Duration(days: i));
        if (selectableDayPredicate(candidate)) return candidate;
      }
    }
    return d;
  }

  Future<void> _openCalendar(BuildContext context) async {
    final initial = _clampInitial();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _dayOnly(firstDay),
      lastDate: _dayOnly(lastDay),
      currentDate: _dayOnly(DateTime.now()),
      selectableDayPredicate: selectableDayPredicate,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.cartTabActive,
              onPrimary: AppColors.white,
            ),
          ),
          child: child,
        );
      },
    );
    if (picked == null) return;
    onDaySelected(_dayOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEE, d MMM yyyy').format(selectedDay);
    final textStyle = AppTextStyles.labelSmall(color: AppColors.textPrimary)
        .copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () => _openCalendar(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _chipBorder, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 20.sp, color: _labelMuted),
              SizedBox(width: 10.w),
              Expanded(child: Text(label, style: textStyle)),
              Icon(Icons.keyboard_arrow_down_rounded, color: _labelMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class ServicesTimeDropdown extends StatelessWidget {
  const ServicesTimeDropdown({
    super.key,
    required this.slots,
    required this.selectedIndex,
    required this.onSelected,
    this.available,
    this.hint = 'Select time',
  });

  final List<String> slots;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<bool>? available;
  final String hint;

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  @override
  Widget build(BuildContext context) {
    final indices = <int>[];
    for (var i = 0; i < slots.length; i++) {
      final ok = available == null ||
          (i < available!.length && available![i]);
      if (ok) indices.add(i);
    }

    final int? value;
    if (indices.isEmpty) {
      value = null;
    } else if (indices.contains(selectedIndex)) {
      value = selectedIndex;
    } else {
      value = indices.first;
    }

    final textStyle = AppTextStyles.labelSmall(color: AppColors.textPrimary)
        .copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _chipBorder, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.labelSmall(color: _labelMuted)
                .copyWith(fontSize: 14.sp),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _labelMuted),
          items: [
            for (final i in indices)
              DropdownMenuItem<int>(
                value: i,
                child: Text(slots[i], style: textStyle),
              ),
          ],
          onChanged: indices.isEmpty
              ? null
              : (i) {
                  if (i != null) onSelected(i);
                },
        ),
      ),
    );
  }
}

class ServicesTipSelector extends StatelessWidget {
  const ServicesTipSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.customController,
    this.onCustomChanged,
  });

  final List<TipOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final TextEditingController? customController;
  final ValueChanged<String>? onCustomChanged;

  static const Color _chipBorder = Color(0xFFE0E6E0);
  static const Color _labelMuted = Color(0xFF6B756E);

  bool get _customSelected {
    if (selectedIndex < 0 || selectedIndex >= options.length) return false;
    return isCustomTipOption(options[selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(options.length, (index) {
            final selected = index == selectedIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < options.length - 1 ? 8.w : 0,
                ),
                child: GestureDetector(
                  onTap: () => onSelected(index),
                  child: Container(
                    height: 36.h,
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.cartTabActive : AppColors.white,
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
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_customSelected && customController != null) ...[
          SizedBox(height: 10.h),
          TextField(
            controller: customController,
            onChanged: onCustomChanged,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyMedium().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              prefixText: 'BHD ',
              hintText: 'Enter tip amount',
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: _chipBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: _chipBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: AppColors.cartTabActive,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ],
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
                    '🕒 ${item.duration} · ${item.price.startsWith('BHD') ? item.price : 'BHD ${item.price}'}',
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
  const ServicesPromoField({
    super.key,
    this.controller,
    this.onApply,
    this.applying = false,
    this.appliedCode,
  });

  final TextEditingController? controller;
  final VoidCallback? onApply;
  final bool applying;
  final String? appliedCode;

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
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onApply?.call(),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: ServicesBookingStrings.enterPromoCode,
                    hintStyle:
                        AppTextStyles.bodySmall(color: _labelMuted).copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                  style: AppTextStyles.bodySmall(
                    color: AppColors.textPrimary,
                  ).copyWith(fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: applying ? null : onApply,
              child: Container(
                width: 84.w,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cartTabActive,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: applying
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        ServicesBookingStrings.apply,
                        style: AppTextStyles.labelSmall(color: AppColors.white)
                            .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (appliedCode != null && appliedCode!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            '✓ $appliedCode applied',
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
  ServicesServiceCard({
    super.key,
    String? name,
    String? durationLabel,
    String? priceLabel,
  })  : name = name ?? ServicesBookingData.mainService,
        durationLabel = durationLabel ?? ServicesBookingData.mainServiceDuration,
        priceLabel = priceLabel ?? ServicesBookingData.mainServicePrice;

  final String name;
  final String durationLabel;
  final String priceLabel;

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
                  name,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
                Text(
                  durationLabel,
                  style: AppTextStyles.caption(color: _labelMuted).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            priceLabel,
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
  const ServicesLocationCard({
    super.key,
    this.locationLabel,
    this.address,
  });

  final String? locationLabel;
  final String? address;

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
                  locationLabel ?? ServicesBookingStrings.venueLocationLabel,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
                if (address != null && address!.trim().isNotEmpty)
                  Text(
                    address!,
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
  const ServicesAppointmentCard({
    super.key,
    this.serviceName,
    this.whenLabel,
  });

  final String? serviceName;
  final String? whenLabel;

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
          _row(
            ServicesBookingStrings.service,
            serviceName ?? ServicesBookingData.mainService,
            multilineValue: true,
          ),
          _row(
            ServicesBookingStrings.when,
            whenLabel ?? ServicesBookingData.appointmentWhen,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool multilineValue = false}) {
    final valueStyle = AppTextStyles.labelMedium(
      color: AppColors.textPrimary,
    ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp, height: 1.35);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: _labelMuted).copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: multilineValue ? 6 : 2,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
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
    this.title,
    this.hint,
  });

  final int secondsLeft;
  final double progress;
  final String? title;
  final String? hint;

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
            title ?? ServicesBookingStrings.sendingBooking,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            hint ?? ServicesBookingStrings.autoConfirmHint,
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
  const ServicesBookingSummaryCard({
    super.key,
    this.serviceName,
    this.providerName,
    this.whenLabel,
    this.locationLabel,
  });

  final String? serviceName;
  final String? providerName;
  final String? whenLabel;
  final String? locationLabel;

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
          _row(
            ServicesBookingStrings.service,
            serviceName ?? ServicesBookingData.mainService,
            multiline: true,
          ),
          _row(
            ServicesBookingStrings.providerLabel,
            providerName ?? ServicesBookingStrings.provider,
          ),
          _row(
            ServicesBookingStrings.when,
            whenLabel ?? ServicesBookingData.appointmentWhen,
          ),
          _row(
            ServicesBookingStrings.location,
            locationLabel ?? ServicesBookingStrings.venueLocationShort,
            multiline: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool isLast = false,
    bool multiline = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72.w,
            child: Text(
              label,
              style: AppTextStyles.labelSmall(color: _labelMuted).copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 16 / 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: multiline ? 5 : 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
