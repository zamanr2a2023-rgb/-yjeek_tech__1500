import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';

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
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 56.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [restaurant.gradientStart, restaurant.gradientEnd],
                    ),
                  ),
                ),
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '★ ${restaurant.rating}',
                      style: AppTextStyles.caption(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 5.h, 6.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 9.sp,
                    ),
                  ),
                  if (restaurant.badge != null) ...[
                    SizedBox(height: 3.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0D9),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        restaurant.badge!,
                        style: AppTextStyles.caption(color: const Color(0xFF7A5E12)).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                  ],
                ],
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: LinearGradient(
                  colors: [restaurant.gradientStart, restaurant.gradientEnd],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    restaurant.subtitle ?? restaurant.cuisine,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        statusLabel,
                        style: AppTextStyles.caption(color: statusColor).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        restaurant.distance,
                        style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '★ ${restaurant.rating}',
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
                if (restaurant.badge != null) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: restaurant.status == DineInVenueStatus.bookable
                          ? AppColors.accountIconBackground
                          : const Color(0xFFFFF0D9),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      restaurant.badge!,
                      style: AppTextStyles.caption(
                        color: restaurant.status == DineInVenueStatus.bookable
                            ? AppColors.primary
                            : const Color(0xFF7A5E12),
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 9.sp),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [restaurant.gradientStart, restaurant.gradientEnd],
              ),
            ),
          ),
          Positioned(
            top: 18.h,
            left: 18.w,
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
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    height: 1,
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
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '★ ${restaurant.rating} (${restaurant.reviewCount})  '
                  '${restaurant.subtitle ?? restaurant.cuisine}  ·  '
                  '${restaurant.distance} away',
                  style: AppTextStyles.labelSmall(color: const Color(0xFFDCE7D4)).copyWith(
                    fontSize: 12.sp,
                    height: 1.35,
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

class DineInOrderBar extends StatelessWidget {
  const DineInOrderBar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF3D9140),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${DineInData.cartItemCount}',
                style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'View order',
              style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
            const Spacer(),
            Text(
              'BHD ${DineInData.cartTotal}',
              style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15.sp,
              ),
            ),
          ],
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
