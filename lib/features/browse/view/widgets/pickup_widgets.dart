import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/pickup_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';

class PickupSectionHeader extends StatelessWidget {
  const PickupSectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
  });

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall().copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
        const Spacer(),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  PickupData.viewAll,
                  style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                  ),
                ),
                Text(
                  ' ›',
                  style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class PickupCategoryRow extends StatelessWidget {
  const PickupCategoryRow({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<PickupCategory> categories;
  final ValueChanged<PickupCategory>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          return PickupCategoryChip(
            category: category,
            onTap: onCategoryTap == null ? null : () => onCategoryTap!(category),
          );
        },
      ),
    );
  }
}

class PickupCategoryChip extends StatelessWidget {
  const PickupCategoryChip({
    super.key,
    required this.category,
    this.onTap,
    this.compact = false,
  });

  final PickupCategory category;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: compact ? 88.w : 64.w,
        child: Column(
          children: [
            Container(
              width: compact ? 62.w : 54.w,
              height: compact ? 62.w : 54.w,
              decoration: BoxDecoration(
                color: category.backgroundColor,
                borderRadius: BorderRadius.circular(compact ? 18.r : 14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                category.icon,
                size: compact ? 28.sp : 24.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11.5.sp : 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PickupSpotCard extends StatelessWidget {
  const PickupSpotCard({
    super.key,
    required this.spot,
    this.onTap,
  });

  final PickupSpot spot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: spot.imageColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 24.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          spot.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium().copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.star_rounded, size: 12.sp, color: const Color(0xFFC9A84C)),
                      SizedBox(width: 2.w),
                      Text(
                        spot.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption().copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${spot.categoryLabel} · ${spot.distance}',
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 11.5.sp,
                    ),
                  ),
                  if (spot.promoLabel != null) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        spot.promoLabel!,
                        style: AppTextStyles.caption(color: AppColors.primary).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBEFE0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 12.sp, color: const Color(0xFFD98C1A)),
                      SizedBox(width: 4.w),
                      Text(
                        spot.pickupEta,
                        style: AppTextStyles.caption(color: const Color(0xFFD98C1A)).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Icon(Icons.chevron_right, size: 20.sp, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PickupCategoriesToolbar extends StatelessWidget {
  const PickupCategoriesToolbar({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          PickupData.pickUpFromAnyCategory,
          style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        const Spacer(),
        CategoriesViewToggle(isGrid: isGridView, onChanged: onViewChanged),
      ],
    );
  }
}

class PickupCategoryGrid extends StatelessWidget {
  const PickupCategoryGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<PickupCategory> categories;
  final ValueChanged<PickupCategory>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 0.92,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return PickupCategoryChip(
          category: category,
          compact: true,
          onTap: onCategoryTap == null ? null : () => onCategoryTap!(category),
        );
      },
    );
  }
}

class PickupCategoryList extends StatelessWidget {
  const PickupCategoryList({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<PickupCategory> categories;
  final ValueChanged<PickupCategory>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: categories.map((category) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: GestureDetector(
            onTap: onCategoryTap == null ? null : () => onCategoryTap!(category),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: category.backgroundColor,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(category.icon, color: AppColors.textPrimary),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      category.name,
                      style: AppTextStyles.titleSmall().copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 22.sp),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class PickupSpotlightBanner extends StatelessWidget {
  const PickupSpotlightBanner({super.key, this.onOrderNow});

  final VoidCallback? onOrderNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F4D27), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PickupData.weeklySpotlight,
            style: AppTextStyles.caption(color: const Color(0xFFEBC34A)).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 9.sp,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            PickupData.spotlightVendor,
            style: AppTextStyles.titleSmall(color: AppColors.white).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: onOrderNow,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                PickupData.orderNow,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
