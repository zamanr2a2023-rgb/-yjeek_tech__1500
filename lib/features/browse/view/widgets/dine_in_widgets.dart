import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';

class DineInRestaurantGridCard extends StatelessWidget {
  const DineInRestaurantGridCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final DineInRestaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8DD)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 68.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-0.6, -1),
                      end: const Alignment(0.6, 1),
                      colors: [restaurant.gradientStart, restaurant.gradientEnd],
                    ),
                  ),
                ),
                Positioned(
                  top: 5.h,
                  left: 5.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '★',
                          style: TextStyle(
                            color: const Color(0xFFC9A84C),
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption(color: AppColors.textPrimary).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 9.sp,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5.sp,
                        height: 1.2,
                      ),
                    ),
                    if (restaurant.badge != null) ...[
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F0DC),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          restaurant.badge!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(color: const Color(0xFF7A5E12)).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 9.sp,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DineInRestaurantListCard extends StatelessWidget {
  const DineInRestaurantListCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final DineInRestaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (restaurant.status) {
      DineInVenueStatus.open => 'Open now',
      DineInVenueStatus.bookable => 'Bookable',
      DineInVenueStatus.closed => 'Closed',
    };
    final statusColor = switch (restaurant.status) {
      DineInVenueStatus.open => AppColors.primary,
      DineInVenueStatus.bookable => AppColors.primary,
      DineInVenueStatus.closed => AppColors.error,
    };
    final statusBg = switch (restaurant.status) {
      DineInVenueStatus.open => const Color(0xFFD9EFE0),
      DineInVenueStatus.bookable => const Color(0xFFD9EFE0),
      DineInVenueStatus.closed => AppColors.errorBackground,
    };
    final showOfferOnImage = restaurant.badge != null &&
        restaurant.badge != 'Bookable' &&
        restaurant.status != DineInVenueStatus.closed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8DD)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      begin: const Alignment(-0.6, -1),
                      end: const Alignment(0.6, 1),
                      colors: [restaurant.gradientStart, restaurant.gradientEnd],
                    ),
                  ),
                ),
                if (showOfferOnImage)
                  Positioned(
                    top: 4.h,
                    left: 4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBC34A),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        restaurant.badge!,
                        style: AppTextStyles.caption(color: const Color(0xFF5A4503)).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 8.sp,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            height: 1.26,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '★',
                        style: TextStyle(
                          color: const Color(0xFFC9A84C),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.26,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          height: 1.26,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    restaurant.subtitle ?? restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      height: 1.26,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.caption(color: statusColor).copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10.5.sp,
                            height: 1.26,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '📍 ${restaurant.distance}',
                        style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                          height: 1.26,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DineInSortBar extends StatelessWidget {
  const DineInSortBar({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
    this.bookableOnly = false,
    this.onBookableChanged,
    this.offersOnly = false,
    this.onOffersChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final bool bookableOnly;
  final ValueChanged<bool>? onBookableChanged;
  final bool offersOnly;
  final ValueChanged<bool>? onOffersChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(
                  icon: Icons.tune_rounded,
                  label: 'Sort: Top rated',
                  trailing: Icons.keyboard_arrow_down_rounded,
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => onBookableChanged?.call(!bookableOnly),
                  child: _chip(
                    icon: Icons.calendar_month_outlined,
                    label: 'Bookable',
                    selected: bookableOnly,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => onOffersChanged?.call(!offersOnly),
                  child: _chip(
                    icon: Icons.local_offer_outlined,
                    label: 'Offers',
                    selected: offersOnly,
                    accent: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        CategoriesViewToggle(isGrid: isGridView, onChanged: onViewChanged),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    IconData? trailing,
    bool selected = false,
    bool accent = false,
  }) {
    final border = selected ? AppColors.primary : const Color(0xFFCDE3CF);
    final fg = selected
        ? AppColors.primary
        : accent
            ? const Color(0xFF2E7D32)
            : AppColors.textPrimary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F5E9) : AppColors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: fg),
          SizedBox(width: 5.w),
          Text(
            label,
            style: AppTextStyles.labelSmall(color: fg).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11.5.sp,
              height: 1.2,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 4.w),
            Icon(trailing, size: 14.sp, color: const Color(0xFF041F09)),
          ],
        ],
      ),
    );
  }
}

class DineInVendorHero extends StatelessWidget {
  const DineInVendorHero({super.key, required this.restaurant});

  final DineInRestaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-0.6, -1),
                end: const Alignment(0.6, 1),
                colors: [restaurant.gradientStart, restaurant.gradientEnd],
              ),
            ),
          ),
          Positioned(
            top: 18.h,
            left: 18.w,
            child: SafeArea(
              bottom: false,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '‹',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 18.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: AppTextStyles.displayMedium(color: AppColors.white).copyWith(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                      fontSize: 12.sp,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: '★ ${restaurant.rating.toStringAsFixed(1)} (${restaurant.reviewCount})',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: '  ${restaurant.subtitle ?? restaurant.cuisine}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: '  ·  ${restaurant.distance} away',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
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

class DineInStatusCard extends StatelessWidget {
  const DineInStatusCard({
    super.key,
    required this.leftTitle,
    required this.leftSubtitle,
    required this.rightTitle,
    required this.rightSubtitle,
  });

  final String leftTitle;
  final String leftSubtitle;
  final String rightTitle;
  final String rightSubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        children: [
          Expanded(child: _cell(leftTitle, leftSubtitle)),
          Expanded(child: _cell(rightTitle, rightSubtitle)),
        ],
      ),
    );
  }

  Widget _cell(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            height: 1.3,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11.sp,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class DineInMenuItemRow extends StatelessWidget {
  const DineInMenuItemRow({
    super.key,
    required this.item,
    required this.gradientStart,
    required this.gradientEnd,
    this.onTap,
  });

  final BrowseMenuItem item;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                gradient: LinearGradient(
                  begin: const Alignment(-0.6, -1),
                  end: const Alignment(0.6, 1),
                  colors: [gradientStart, gradientEnd],
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: AppColors.white).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'BHD ${item.price}',
                    style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11.r),
              ),
              alignment: Alignment.center,
              child: Text(
                '+',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DineInOrderBar extends StatelessWidget {
  const DineInOrderBar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 26.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${DineInData.cartItemCount}',
                  style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'View order',
                style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Text(
                'BHD ${DineInData.cartTotal}',
                style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DineInVisitCard extends StatelessWidget {
  const DineInVisitCard({
    super.key,
    required this.visit,
    this.onBookAgain,
  });

  final DineInVisit visit;
  final VoidCallback? onBookAgain;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    colors: [visit.gradientStart, visit.gradientEnd],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.restaurantName,
                      style: AppTextStyles.labelMedium().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      visit.itemsSummary,
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${visit.visitMeta} · ${visit.total}',
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: onBookAgain,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: AppColors.white, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Book again',
                    style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DineInOrderAgainRow extends StatelessWidget {
  const DineInOrderAgainRow({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order again',
          style: AppTextStyles.titleSmall().copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See all',
            style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }
}
