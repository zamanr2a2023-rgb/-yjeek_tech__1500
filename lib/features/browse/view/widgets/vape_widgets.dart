import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';

class VapeAgeBanner extends StatelessWidget {
  const VapeAgeBanner({
    super.key,
    this.message,
    this.detailed = false,
  });

  final String? message;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final text = message ??
        (detailed ? VapeData.products.first.ageWarningDetail : VapeData.ageBannerShort);
    // Figma: full-width #FFF2DB · 12px radius · #C74D00 copy.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2DB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Text('🔞', style: TextStyle(fontSize: 15.sp, height: 1.2)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSmall(color: const Color(0xFFC74D00)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VapeAgeBadge extends StatelessWidget {
  const VapeAgeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2DB),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        '18+',
        style: AppTextStyles.caption(color: const Color(0xFFC74D00)).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

class VapeStoreListCard extends StatelessWidget {
  const VapeStoreListCard({
    super.key,
    required this.store,
    this.onTap,
  });

  final VapeStore store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final meta = store.subtitle != null
        ? '★ ${store.rating} · Vape · ${store.subtitle} · ${store.distance}'
        : '★ ${store.rating} · Vape · ${store.distance} · ${store.eta}';

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
                borderRadius: BorderRadius.circular(12.r),
                gradient: LinearGradient(
                  colors: [store.gradientStart, store.gradientEnd],
                ),
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
                          store.name,
                          style: AppTextStyles.labelMedium().copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      const VapeAgeBadge(),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    meta,
                    style: AppTextStyles.caption(color: const Color(0xFF737873)).copyWith(
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20.sp, color: const Color(0xFF737873)),
          ],
        ),
      ),
    );
  }
}

class VapeStoreTopBar extends StatelessWidget {
  const VapeStoreTopBar({
    super.key,
    required this.store,
    this.title,
    this.onBack,
    this.onCart,
  });

  final VapeStore store;
  /// Product detail uses product name; store screens keep [store.shortName].
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onCart;

  @override
  Widget build(BuildContext context) {
    final heading = title ?? store.shortName;
    final showCart = onCart != null;
    final centered = title != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8DD)),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 22.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                heading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: AppTextStyles.titleMedium().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: centered ? 16.sp : 18.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            if (showCart)
              GestureDetector(
                onTap: onCart,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8DD)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 18.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              )
            else
              SizedBox(width: 36.w),
          ],
        ),
      ),
    );
  }
}

class VapeProductRow extends StatelessWidget {
  const VapeProductRow({
    super.key,
    required this.product,
    required this.gradientStart,
    required this.gradientEnd,
    this.onTap,
    this.onAdd,
  });

  final VapeProduct product;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    // Figma prod: white card #E6E8E6 border · radius 14 · padding 12 · + #4DB04F.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE6E8E6)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFF1A1F1A),
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    product.specs,
                    style: AppTextStyles.caption(color: const Color(0xFF737873)).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 11.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'BHD ${product.price}',
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFF4DB04F),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB04F),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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

class VapeViewCartBar extends StatelessWidget {
  const VapeViewCartBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  final int itemCount;
  final String total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF4DB04F),
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'View cart · $itemCount ${itemCount == 1 ? 'item' : 'items'} · BHD $total',
          style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

class VapeNicotineChip extends StatelessWidget {
  const VapeNicotineChip({
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6F5E8) : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? const Color(0xFF4DB04F) : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: selected ? const Color(0xFF216B2E) : AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
        ),
      ),
    );
  }
}
