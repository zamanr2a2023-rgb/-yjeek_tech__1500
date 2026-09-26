import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';

/// Fashion Clothes header: ‹ Title · search · cart
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
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: Text(
                '‹',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                    .copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 1.2,
                ),
              ),
            ),
            if (onSearch != null) ...[
              _RoundIconBtn(
                icon: Icons.search_rounded,
                onTap: onSearch!,
              ),
              SizedBox(width: 8.w),
            ],
            if (onCart != null)
              _RoundIconBtn(
                icon: Icons.shopping_cart_outlined,
                onTap: onCart!,
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconBtn extends StatelessWidget {
  const _RoundIconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
      ),
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
          height: 75.h,
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
    return Row(
      children: [
        _Pill(
          label: 'Offers',
          selected: offersOnly,
          onTap: onOffersTap,
        ),
        SizedBox(width: 8.w),
        _Pill(
          label: 'Top rated',
          selected: topRated,
          onTap: onTopRatedTap,
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Toggle(
                icon: Icons.grid_view_rounded,
                active: isGridView,
                onTap: () => onViewChanged(true),
              ),
              _Toggle(
                icon: Icons.view_list_rounded,
                active: !isGridView,
                onTap: () => onViewChanged(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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
          color: selected ? const Color(0xFFE8F5E9) : AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFDEDEDE),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 29.h,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 14.sp,
          color: active ? AppColors.white : AppColors.primary,
        ),
      ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 88.w,
              height: 65.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
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
                  if (store.offerBadge != null &&
                      store.offerBadge!.isNotEmpty)
                    Positioned(
                      left: 8.w,
                      top: 8.h,
                      child: _OfferBadge(label: store.offerBadge!),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (store.areaLabel.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      store.areaLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                        color: const Color(0xFF6B6B6B),
                      ).copyWith(fontSize: 12.sp),
                    ),
                  ],
                ],
              ),
            ),
            if (store.hasRating && store.rating > 0)
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded,
                        size: 14.sp, color: const Color(0xFFD98C1A)),
                    SizedBox(width: 2.w),
                    Text(
                      store.rating.toStringAsFixed(1),
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(width: 12.w),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
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
                  if (store.offerBadge != null &&
                      store.offerBadge!.isNotEmpty)
                    Positioned(
                      left: 8.w,
                      top: 8.h,
                      child: _OfferBadge(label: store.offerBadge!),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMedium(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        if (store.hasRating && store.rating > 0) ...[
                          Icon(Icons.star_rounded,
                              size: 12.sp, color: const Color(0xFFD98C1A)),
                          SizedBox(width: 2.w),
                          Text(
                            store.rating.toStringAsFixed(1),
                            style: AppTextStyles.caption(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (store.areaLabel.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        store.areaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(
                          color: const Color(0xFF6B6B6B),
                        ).copyWith(fontSize: 11.sp),
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

class _OfferBadge extends StatelessWidget {
  const _OfferBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: AppColors.white).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 9.sp,
        ),
      ),
    );
  }
}
