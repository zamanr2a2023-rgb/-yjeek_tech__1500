import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';

class ElectronicsStoreListCard extends StatelessWidget {
  const ElectronicsStoreListCard({
    super.key,
    required this.store,
    this.onTap,
  });

  final ElectronicsStore store;
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
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2EB),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.devices_other_outlined,
                size: 24.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '★ ${store.rating} (${store.reviewCount}) · ${store.distance}',
                    style: AppTextStyles.caption(color: const Color(0xFFD98C1A)).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    store.categories,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 22.sp, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class ElectronicsStoreTopBar extends StatelessWidget {
  const ElectronicsStoreTopBar({
    super.key,
    required this.store,
    this.onBack,
  });

  final ElectronicsStore store;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Text(
                '‹',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: AppTextStyles.titleMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    '${store.productCount} products',
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_horiz, size: 22.sp, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }
}

class ElectronicsProductRow extends StatelessWidget {
  const ElectronicsProductRow({
    super.key,
    required this.product,
    required this.gradientStart,
    required this.gradientEnd,
    this.onTap,
    this.onAdd,
  });

  final ElectronicsProduct product;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

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
                color: const Color(0xFFE3F2EB),
                borderRadius: BorderRadius.circular(14.r),
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                ),
              ),
              child: Icon(
                Icons.smartphone_outlined,
                size: 28.sp,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    product.specs,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '★ ${product.rating}',
                    style: AppTextStyles.caption(color: const Color(0xFFD98C1A)).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        'BHD ${product.price}',
                        style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        SizedBox(width: 6.w),
                        Text(
                          'BHD ${product.originalPrice}',
                          style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                            fontSize: 11.sp,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onAdd ?? onTap,
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 1,
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

class ElectronicsOptionChip extends StatelessWidget {
  const ElectronicsOptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: selected ? AppColors.white : AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.5.sp),
        ),
      ),
    );
  }
}

class ElectronicsColorSwatches extends StatelessWidget {
  const ElectronicsColorSwatches({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ElectronicsColorOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: 10.w),
          GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: options[i].color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedIndex == i ? AppColors.primary : AppColors.border,
                  width: selectedIndex == i ? 2 : 1,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ElectronicsHighlightsCard extends StatelessWidget {
  const ElectronicsHighlightsCard({
    super.key,
    required this.highlights,
  });

  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Highlights',
            style: AppTextStyles.labelMedium().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 10.h),
          for (final highlight in highlights)
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                '• $highlight',
                style: AppTextStyles.bodySmall().copyWith(fontSize: 13.sp),
              ),
            ),
        ],
      ),
    );
  }
}
