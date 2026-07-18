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
    // Figma: 4×15 #4CAF50 rail · 15px title · View all #4CAF50.
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 15.h,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 7.w),
        Text(
          title,
          style: AppTextStyles.titleSmall(color: const Color(0xFF1A1A1A)).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            height: 1.28,
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
                  style: AppTextStyles.labelSmall(color: const Color(0xFF4CAF50)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                    height: 1.28,
                  ),
                ),
                Text(
                  ' ›',
                  style: AppTextStyles.labelSmall(color: const Color(0xFF4CAF50)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    height: 1.28,
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
    // Figma row height 73 · gap 10.
    return SizedBox(
      height: 73.h,
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
    // PK1 featured: 54×14 · PK6 grid: 62×18 · shadow 0 5 12 / 16%.
    final tile = compact ? 62.w : 54.w;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: tile,
          height: tile,
          decoration: BoxDecoration(
            color: category.backgroundColor,
            borderRadius: BorderRadius.circular(compact ? 18.r : 14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: compact ? 12 : 10,
                offset: Offset(0, compact ? 5 : 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            category.icon,
            size: compact ? 28.sp : 26.sp,
            color: const Color(0xFF2A2118),
          ),
        ),
        SizedBox(height: compact ? 7.h : 6.h),
        Text(
          category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: const Color(0xFF1A1A1A)).copyWith(
            fontWeight: compact ? FontWeight.w600 : FontWeight.w700,
            fontSize: compact ? 11.5.sp : 10.5.sp,
            height: 1.2,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: compact
          ? SizedBox(width: double.infinity, child: content)
          : SizedBox(width: 64.w, child: content),
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
    // Figma: white · #E6EBE3 · shadow 0 2 8 / 6% · radius 14 · pad 12.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE6EBE3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
              alignment: Alignment.center,
              child: Icon(
                Icons.storefront_outlined,
                size: 26.sp,
                color: const Color(0xFF2E7D32),
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
                          style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A)).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.star_rounded, size: 12.sp, color: const Color(0xFFC9A84C)),
                      SizedBox(width: 3.w),
                      Text(
                        spot.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption(color: const Color(0xFF1A1A1A)).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${spot.categoryLabel} · ${spot.distance}',
                    style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.5.sp,
                      height: 1.3,
                    ),
                  ),
                  if (spot.promoLabel != null) ...[
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F0DC),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        spot.promoLabel!,
                        style: AppTextStyles.caption(color: const Color(0xFF0F4D27)).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5.sp,
                          height: 1.3,
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
                      Icon(Icons.schedule, size: 12.sp, color: const Color(0xFFE08A1E)),
                      SizedBox(width: 4.w),
                      Text(
                        spot.pickupEta,
                        style: AppTextStyles.caption(color: const Color(0xFFE08A1E)).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Icon(Icons.chevron_right, size: 16.sp, color: const Color(0xFF6B7B6E)),
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
    // Figma PK6: 4 columns · cell 87.5×83.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 0,
        childAspectRatio: 87.5 / 90,
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
                border: Border.all(color: const Color(0xFFE6EBE3)),
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
                    child: Icon(category.icon, color: const Color(0xFF2A2118)),
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
                  Icon(Icons.chevron_right, color: const Color(0xFF6B7B6E), size: 22.sp),
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
    // Figma: #0F4D27 copy panel + brown/forest image strip · radius 18.
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: SizedBox(
        height: 124.h,
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: const Color(0xFF0F4D27),
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 12.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PickupData.weeklySpotlight,
                      style: AppTextStyles.caption(color: const Color(0xFFEBC34A)).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 9.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      PickupData.spotlightVendor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall(color: AppColors.white).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
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
                          style: AppTextStyles.labelMedium(
                            color: const Color(0xFF0F4D27),
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 120.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.8, -0.6),
                  end: Alignment(0.8, 0.8),
                  colors: [Color(0xFF6B4A2A), Color(0xFF15302B)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
