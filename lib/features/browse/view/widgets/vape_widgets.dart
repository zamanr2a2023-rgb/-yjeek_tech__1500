import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
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
        (detailed ? VapeData.ageBannerDetailed : VapeData.ageBannerShort);
    // Figma: full-width peach banner · 12px radius · #C74D00 copy.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8D6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 18.sp, color: const Color(0xFFC74D00)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSmall(color: const Color(0xFFC74D00))
                  .copyWith(
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
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8D6),
        borderRadius: BorderRadius.circular(5.r),
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

/// Horizontal "Order again" row for vape vendors (hidden when empty).
class VapeOrderAgainRow extends StatelessWidget {
  const VapeOrderAgainRow({
    super.key,
    required this.stores,
    this.onSeeAll,
    this.onStoreTap,
  });

  final List<VapeStore> stores;
  final VoidCallback? onSeeAll;
  final ValueChanged<VapeStore>? onStoreTap;

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Order again',
              style: AppTextStyles.titleSmall(color: AppColors.textPrimary)
                  .copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            const Spacer(),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: AppTextStyles.labelSmall(color: AppColors.primary)
                      .copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 56.w + 4.h + 11.sp * 1.2 + 2,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stores.length.clamp(0, 8),
            separatorBuilder: (_, _) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final store = stores[index];
              return GestureDetector(
                onTap: () => onStoreTap?.call(store),
                child: SizedBox(
                  width: 56.w,
                  child: Column(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: store.imageUrl != null &&
                                store.imageUrl!.isNotEmpty
                            ? AppNetworkImage(
                                url: store.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: const ColoredBox(
                                  color: Color(0xFFE8F5E9),
                                ),
                              )
                            : Center(
                                child: Text(
                                  store.shortName.isNotEmpty
                                      ? store.shortName[0].toUpperCase()
                                      : '?',
                                  style: AppTextStyles.titleSmall(
                                    color: AppColors.primary,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        store.shortName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(
                          color: AppColors.textPrimary,
                        ).copyWith(fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Clothes-style list vendor card + 18+ badge.
class VapeVendorListCard extends StatelessWidget {
  const VapeVendorListCard({
    super.key,
    required this.store,
    this.onTap,
  });

  final VapeStore store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final offer = store.offerBadge;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8DD)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SquareLogo(imageUrl: store.imageUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium(
                            color: const Color(0xFF1A1A1A),
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _RatingMark(
                        rating: store.rating,
                        visible: store.hasRating && store.rating > 0,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    store.areaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 13.sp),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        const VapeAgeBadge(),
                        if (offer != null && offer.isNotEmpty)
                          _OfferBadge(label: offer),
                      ],
                    ),
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

/// Clothes-style grid vendor card + 18+ badge.
class VapeVendorGridCard extends StatelessWidget {
  const VapeVendorGridCard({
    super.key,
    required this.store,
    this.onTap,
  });

  final VapeStore store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final offer = store.offerBadge;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8DD)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ColoredBox(
                color: const Color(0xFFE8F5E9),
                child: store.imageUrl != null && store.imageUrl!.isNotEmpty
                    ? AppNetworkImage(
                        url: store.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: const ColoredBox(
                          color: Color(0xFFE8F5E9),
                        ),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _RatingMark(
                    rating: store.rating,
                    visible: store.hasRating && store.rating > 0,
                    compact: true,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    store.areaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 11.sp, height: 1.1),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      const VapeAgeBadge(),
                      if (offer != null && offer.isNotEmpty)
                        _OfferBadge(label: offer),
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

class _SquareLogo extends StatelessWidget {
  const _SquareLogo({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: 72.w,
        height: 72.w,
        child: ColoredBox(
          color: const Color(0xFFE8F5E9),
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? AppNetworkImage(
                  url: imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: const ColoredBox(color: Color(0xFFE8F5E9)),
                )
              : null,
        ),
      ),
    );
  }
}

class _RatingMark extends StatelessWidget {
  const _RatingMark({
    required this.rating,
    required this.visible,
    this.compact = false,
  });

  final double rating;
  final bool visible;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '★',
          style: TextStyle(
            color: const Color(0xFFC9A84C),
            fontSize: compact ? 10.sp : 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.labelSmall(color: const Color(0xFF1A1A1A))
              .copyWith(
            fontWeight: FontWeight.w700,
            fontSize: compact ? 11.sp : 13.sp,
          ),
        ),
      ],
    );
  }
}

class _OfferBadge extends StatelessWidget {
  const _OfferBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.offerBadgeGreenBg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
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
    return VapeVendorListCard(store: store, onTap: onTap);
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
