import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';

import 'browse_widgets.dart';
import 'food_category_widgets.dart';

/// Same header as Food: circular back, title, search, cart.
class FashionVendorsHeader extends StatelessWidget {
  const FashionVendorsHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onSearch,
    this.onCart,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onCart;

  @override
  Widget build(BuildContext context) {
    return BrowseTopBar(
      title: title,
      onBack: onBack,
      onSearch: onSearch,
      onCart: onCart,
    );
  }
}

class FashionScheduledBar extends StatelessWidget {
  const FashionScheduledBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      alignment: Alignment.center,
      child: Text(
        'Scheduled',
        style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

class FashionOrderAgainRow extends StatelessWidget {
  const FashionOrderAgainRow({
    super.key,
    required this.stores,
    this.onSeeAll,
    this.onStoreTap,
  });

  final List<ElectronicsStore> stores;
  final VoidCallback? onSeeAll;
  final ValueChanged<ElectronicsStore>? onStoreTap;

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
                                  store.name.isNotEmpty
                                      ? store.name[0].toUpperCase()
                                      : '?',
                                  style: AppTextStyles.titleSmall(
                                    color: AppColors.primary,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        store.name,
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

class FashionFilterRow extends StatelessWidget {
  const FashionFilterRow({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
    required this.offersOnly,
    required this.onOffersTap,
    required this.topRated,
    required this.onTopRatedTap,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final bool offersOnly;
  final VoidCallback onOffersTap;
  final bool topRated;
  final VoidCallback onTopRatedTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              FoodQuickFilterChip(
                label: 'Offers',
                selected: offersOnly,
                onTap: onOffersTap,
              ),
              SizedBox(width: 8.w),
              FoodQuickFilterChip(
                label: 'Top rated',
                selected: topRated,
                onTap: onTopRatedTap,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Align(
            alignment: Alignment.centerRight,
            child: CategoriesViewToggle(
              isGrid: isGridView,
              onChanged: onViewChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// List vendor card — thumb + name/area + rating + offer badge.
class FashionVendorListCard extends StatelessWidget {
  const FashionVendorListCard({
    super.key,
    required this.store,
    this.onTap,
  });

  final ElectronicsStore store;
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
                  if (store.areaLabel.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      store.areaLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall(
                        color: AppColors.textSecondary,
                      ).copyWith(fontSize: 13.sp),
                    ),
                  ],
                  if (offer != null && offer.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: _OfferBadge(label: offer),
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

/// Grid vendor card.
class FashionVendorGridCard extends StatelessWidget {
  const FashionVendorGridCard({
    super.key,
    required this.store,
    this.onTap,
  });

  final ElectronicsStore store;
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
                  if (store.areaLabel.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      store.areaLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                        color: AppColors.textSecondary,
                      ).copyWith(fontSize: 11.sp, height: 1.1),
                    ),
                  ],
                  if (offer != null && offer.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    _OfferBadge(label: offer),
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
