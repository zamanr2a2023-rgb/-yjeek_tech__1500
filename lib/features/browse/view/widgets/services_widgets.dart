import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';

/// Design tokens from Figma `(2.3.1) Browse - ( SERVICES )`.
abstract final class _ServicesDesign {
  static const Color cardBorder = Color(0xFFE0E6E0);
  static const Color mint = Color(0xFFE3F2EB);
  static const Color thumb = Color(0xFFDBE8DE);
  static const Color rating = Color(0xFFD98C1A);
  static const Color greenDeep = Color(0xFF127036);
  static const Color greenActive = Color(0xFF2E9E4D);
  static const Color muted = Color(0xFF6B7A6E);
  static const Color mutedAlt = Color(0xFF6B756E);
}

/// Search field on Services sub-category landing (services.md).
class ServicesSubcategorySearchField extends StatelessWidget {
  const ServicesSubcategorySearchField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
            .copyWith(fontSize: 14.sp),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium(color: const Color(0xFF6B7A6E))
              .copyWith(fontSize: 14.sp),
        ),
      ),
    );
  }
}

/// Grid / list toggle for Services landing.
class ServicesSubcategoryViewToggle extends StatelessWidget {
  const ServicesSubcategoryViewToggle({
    super.key,
    required this.isGridView,
    required this.onChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onTap: () => onChanged(true),
          ),
          _Toggle(
            icon: Icons.view_list_rounded,
            active: !isGridView,
            onTap: () => onChanged(false),
          ),
        ],
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
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16.sp,
          color: active ? AppColors.white : const Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}

/// Figma grid cards: mint image area + white label.
class ServicesSubcategoryGrid extends StatelessWidget {
  const ServicesSubcategoryGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  final List<ServiceCategoryItem> categories;
  final ValueChanged<ServiceCategoryItem> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => onCategoryTap(category),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ColoredBox(
                    color: const Color(0xFFE8F5E9),
                    child: Icon(
                      _iconFor(category.name),
                      size: 36.sp,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Figma list row: mint thumb · name · chevron.
class ServicesSubcategoryListRow extends StatelessWidget {
  const ServicesSubcategoryListRow({
    super.key,
    required this.category,
    required this.onTap,
    this.showDivider = true,
  });

  final ServiceCategoryItem category;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _iconFor(category.name),
                    size: 22.sp,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22.sp,
                  color: const Color(0xFF6B6B6B),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E2E2)),
      ],
    );
  }
}

IconData _iconFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('clean')) return Icons.cleaning_services_outlined;
  if (n.contains('plumb') || n.contains('ac')) return Icons.plumbing_outlined;
  if (n.contains('beauty') || n.contains('salon')) {
    return Icons.content_cut_outlined;
  }
  if (n.contains('car') || n.contains('auto')) return Icons.directions_car_outlined;
  return Icons.handyman_outlined;
}

/// "Book again" row — prior providers in this subcategory.
class ServicesBookAgainRow extends StatelessWidget {
  const ServicesBookAgainRow({
    super.key,
    required this.providers,
    this.onSeeAll,
    this.onProviderTap,
  });

  final List<ServiceProvider> providers;
  final VoidCallback? onSeeAll;
  final ValueChanged<ServiceProvider>? onProviderTap;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Book again',
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
            itemCount: providers.length.clamp(0, 8),
            separatorBuilder: (_, _) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final p = providers[index];
              return GestureDetector(
                onTap: () => onProviderTap?.call(p),
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
                        alignment: Alignment.center,
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: AppTextStyles.titleSmall(
                            color: AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        p.name,
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

/// help 2.md list card: thumb · name · area · rating · offer badge.
class ServicesListingListCard extends StatelessWidget {
  const ServicesListingListCard({
    super.key,
    required this.provider,
    this.onTap,
  });

  final ServiceProvider provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72.h,
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
              height: 72.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFFE8F5E9)),
                  if (provider.offerBadge != null &&
                      provider.offerBadge!.isNotEmpty)
                    Positioned(
                      left: 6.w,
                      top: 6.h,
                      child: _OfferBadge(label: provider.offerBadge!),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      provider.locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                        color: const Color(0xFF6B6B6B),
                      ).copyWith(fontSize: 12.sp),
                    ),
                    if (provider.hasRating) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '★ ${provider.rating.toStringAsFixed(1)}',
                        style: AppTextStyles.caption(
                          color: const Color(0xFFD98C1A),
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
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

/// help 2.md grid card.
class ServicesListingGridCard extends StatelessWidget {
  const ServicesListingGridCard({
    super.key,
    required this.provider,
    this.onTap,
  });

  final ServiceProvider provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFDEDEDE)),
                  ),
                ),
                if (provider.offerBadge != null &&
                    provider.offerBadge!.isNotEmpty)
                  Positioned(
                    left: 8.w,
                    top: 8.h,
                    child: _OfferBadge(label: provider.offerBadge!),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            provider.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                .copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            provider.locationLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(color: const Color(0xFF6B6B6B))
                .copyWith(fontSize: 11.sp),
          ),
          if (provider.hasRating) ...[
            SizedBox(height: 2.h),
            Text(
              '★ ${provider.rating.toStringAsFixed(1)}',
              style: AppTextStyles.caption(color: const Color(0xFFD98C1A))
                  .copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
          ],
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: AppColors.white).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

class ServicesCategoryGrid extends StatelessWidget {
  const ServicesCategoryGrid({
    super.key,
    required this.onCategoryTap,
    this.categories,
  });

  final ValueChanged<ServiceCategoryItem> onCategoryTap;
  final List<ServiceCategoryItem>? categories;

  @override
  Widget build(BuildContext context) {
    final items = categories ?? const <ServiceCategoryItem>[];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
        // Design 169×97; +3px height absorbs border + font metrics (was overflowing ~2.4px).
        childAspectRatio: 169 / 100,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final category = items[index];
        return GestureDetector(
          onTap: () => onCategoryTap(category),
          child: Container(
            padding: EdgeInsets.fromLTRB(14.w, 12.w, 14.w, 12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: _ServicesDesign.cardBorder),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: category.iconBackground,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category.emoji,
                    style: TextStyle(
                      fontSize: 20.sp,
                      height: 1,
                      color: _ServicesDesign.greenDeep,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ServicesPopularSection extends StatelessWidget {
  const ServicesPopularSection({
    super.key,
    required this.providers,
    this.onSeeAll,
    this.onProviderTap,
  });

  final List<ServiceProvider> providers;
  final VoidCallback? onSeeAll;
  final ValueChanged<ServiceProvider>? onProviderTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                ServicesData.popularNearYou,
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  height: 19 / 16,
                ),
              ),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  ServicesData.seeAll,
                  style:
                      AppTextStyles.labelSmall(
                        color: _ServicesDesign.greenDeep,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        height: 16 / 13,
                      ),
                ),
              ),
          ],
        ),
        SizedBox(height: 14.w),
        for (var i = 0; i < providers.length; i++) ...[
          if (i > 0) SizedBox(height: 14.w),
          ServicesPopularCard(
            provider: providers[i],
            onTap: () => onProviderTap?.call(providers[i]),
          ),
        ],
      ],
    );
  }
}

class ServicesPopularCard extends StatelessWidget {
  const ServicesPopularCard({super.key, required this.provider, this.onTap});

  final ServiceProvider provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 88.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _ServicesDesign.cardBorder),
        ),
        child: Row(
          children: [
            // Design popular thumbs: plain mint #E3F2EB squares (no emoji).
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: _ServicesDesign.mint,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 17 / 14,
                    ),
                  ),
                  SizedBox(height: 3.w),
                  Text(
                    provider.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTextStyles.caption(
                          color: _ServicesDesign.mutedAlt,
                        ).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          height: 15 / 12,
                        ),
                  ),
                  SizedBox(height: 3.w),
                  Text(
                    '★ ${provider.rating} (${provider.reviewCount})',
                    style: AppTextStyles.caption(color: _ServicesDesign.rating)
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          height: 15 / 12,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'from BHD ${provider.priceFrom}',
              style: AppTextStyles.labelSmall(color: _ServicesDesign.greenDeep)
                  .copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    height: 15 / 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesCategoryHeader extends StatelessWidget {
  const ServicesCategoryHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
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
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  '‹',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 24 / 20,
                ),
              ),
            ),
            Icon(Icons.more_horiz, size: 22.sp, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }
}

class ServicesVenueFilterChips extends StatelessWidget {
  const ServicesVenueFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final option = options[index];
          final active = option == selected;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: active ? _ServicesDesign.greenActive : AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: active
                      ? _ServicesDesign.greenActive
                      : _ServicesDesign.cardBorder,
                ),
              ),
              child: Text(
                option,
                style: AppTextStyles.labelSmall(
                  color: active ? AppColors.white : AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.5.sp),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ServicesToolbar extends StatelessWidget {
  const ServicesToolbar({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
    this.sort = 'popular',
    this.onSortChanged,
    this.offersOnly = false,
    this.onOffersChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final String sort;
  final ValueChanged<String>? onSortChanged;
  final bool offersOnly;
  final ValueChanged<bool>? onOffersChanged;

  static const _sortOptions = <(String value, String label)>[
    ('popular', 'Most Popular'),
    ('rating', 'Top rated'),
    ('name', 'Name'),
  ];

  String get _sortLabel {
    for (final option in _sortOptions) {
      if (option.$1 == sort) return option.$2;
    }
    return 'Sort';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<String>(
          initialValue: sort,
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            for (final option in _sortOptions)
              PopupMenuItem(value: option.$1, child: Text(option.$2)),
          ],
          child: _chip(_sortLabel, Icons.swap_vert, active: false),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onOffersChanged == null
              ? null
              : () => onOffersChanged!(!offersOnly),
          child: _chip('Offers', Icons.local_offer_outlined, active: offersOnly),
        ),
        const Spacer(),
        // Design: bordered 72×34 split (not a filled pill track).
        Container(
          width: 72.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _ServicesDesign.cardBorder, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onViewChanged(false),
                  child: ColoredBox(
                    color: !isGridView
                        ? _ServicesDesign.greenActive
                        : AppColors.white,
                    child: Center(
                      child: Text(
                        '≡',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: !isGridView
                              ? AppColors.white
                              : _ServicesDesign.mutedAlt,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onViewChanged(true),
                  child: ColoredBox(
                    color: isGridView
                        ? _ServicesDesign.greenActive
                        : AppColors.white,
                    child: Center(
                      child: Text(
                        '▦',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: isGridView
                              ? AppColors.white
                              : _ServicesDesign.mutedAlt,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, IconData icon, {bool active = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: active ? _ServicesDesign.greenActive : AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: active ? _ServicesDesign.greenActive : _ServicesDesign.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: active ? AppColors.white : AppColors.textPrimary,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.labelSmall().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: active ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesProviderGridCard extends StatelessWidget {
  const ServicesProviderGridCard({
    super.key,
    required this.provider,
    this.onTap,
  });

  final ServiceProvider provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 10.w, 10.w, 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _ServicesDesign.cardBorder),
        ),
        // Design card 169×196: thumb ~96, body rest — flex avoids .h overflow.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 96,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _ServicesDesign.thumb,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Text(provider.emoji, style: TextStyle(fontSize: 30.sp)),
              ),
            ),
            SizedBox(height: 6.w),
            Expanded(
              flex: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 17 / 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    '★ ${provider.rating} · ${provider.distance}',
                    style: AppTextStyles.caption(color: _ServicesDesign.rating)
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          height: 15 / 12,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.w),
                  Flexible(
                    child: Text(
                      provider.tags,
                      style: AppTextStyles.caption(
                        color: _ServicesDesign.muted,
                      ).copyWith(fontSize: 11.sp, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

class ServicesProviderListCard extends StatelessWidget {
  const ServicesProviderListCard({
    super.key,
    required this.provider,
    this.onTap,
  });

  final ServiceProvider provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Design list card: padding 12 14 12 12, radius 16, height ~103
        padding: EdgeInsets.fromLTRB(12.w, 12.w, 14.w, 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _ServicesDesign.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: _ServicesDesign.thumb,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      height: 18 / 15,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  // Design: ★ 4.8  (142)  · 2.6 km — rating gold, count+distance muted, gap 6
                  Row(
                    children: [
                      Text(
                        '★ ${provider.rating}',
                        style:
                            AppTextStyles.caption(
                              color: _ServicesDesign.rating,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5.sp,
                              height: 15 / 12.5,
                            ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '(${provider.reviewCount})',
                        style:
                            AppTextStyles.caption(
                              color: _ServicesDesign.mutedAlt,
                            ).copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              height: 15 / 12,
                            ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '· ${provider.distance}',
                        style:
                            AppTextStyles.caption(
                              color: _ServicesDesign.mutedAlt,
                            ).copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              height: 15 / 12,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    provider.tags,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTextStyles.caption(
                          color: _ServicesDesign.mutedAlt,
                        ).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          height: 15 / 12,
                        ),
                  ),
                  SizedBox(height: 4.w),
                  // Design: mint pills, text only (no icons), gap 6
                  Row(
                    children: [
                      if (provider.atVenue) _venuePill('At venue'),
                      if (provider.atVenue && provider.atHome)
                        SizedBox(width: 6.w),
                      if (provider.atHome) _venuePill('At home'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.w),
              child: Text(
                '›',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  height: 24 / 20,
                  color: _ServicesDesign.mutedAlt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _venuePill(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
      decoration: BoxDecoration(
        color: _ServicesDesign.mint,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: _ServicesDesign.greenDeep).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
          height: 13 / 11,
        ),
      ),
    );
  }
}

class ServicesProviderHero extends StatelessWidget {
  const ServicesProviderHero({super.key, required this.provider});

  final ServiceProvider provider;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      // Design hero 240; keep room under status bar for back + title block.
      height: topInset + 196.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: _ServicesDesign.mint),
          Positioned(
            top: topInset + 16.w,
            left: 16.w,
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
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 18.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style:
                      AppTextStyles.displayMedium(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                        height: 36 / 30,
                      ),
                ),
                SizedBox(height: 8.w),
                Row(
                  children: [
                    Text(
                      '★',
                      style: TextStyle(
                        color: _ServicesDesign.rating,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        height: 16 / 13,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${provider.rating} (${provider.reviewCount})',
                      style:
                          AppTextStyles.labelSmall(
                            color: AppColors.textPrimary,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                            height: 16 / 13,
                          ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        '${provider.category}  ·  ${provider.distance} away',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.labelSmall(
                              color: _ServicesDesign.mutedAlt,
                            ).copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 13.sp,
                              height: 16 / 13,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesSectionChips extends StatelessWidget {
  const ServicesSectionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final option = options[index];
          final active = option == selected;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.w),
              decoration: BoxDecoration(
                color: active ? _ServicesDesign.greenActive : AppColors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: active
                      ? _ServicesDesign.greenActive
                      : _ServicesDesign.cardBorder,
                ),
              ),
              child: Text(
                option,
                style:
                    AppTextStyles.labelSmall(
                      color: active ? AppColors.white : AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      height: 17 / 14,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ServicesProviderInfoCard extends StatelessWidget {
  const ServicesProviderInfoCard({super.key, required this.provider});

  final ServiceProvider provider;

  @override
  Widget build(BuildContext context) {
    final venueLabel = provider.atVenue && provider.atHome
        ? 'At venue · home'
        : provider.atVenue
        ? 'At venue'
        : 'At home';

    return Container(
      height: 63.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _ServicesDesign.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.openHoursTitle,
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        height: 18 / 15,
                      ),
                ),
                SizedBox(height: 3.w),
                Text(
                  provider.openHoursSubtitle,
                  style: AppTextStyles.caption(
                    color: _ServicesDesign.mutedAlt,
                  ).copyWith(fontSize: 13.sp, height: 16 / 13),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venueLabel,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      height: 18 / 15,
                    ),
              ),
              SizedBox(height: 3.w),
              Text(
                provider.bookingModeLabel,
                style: AppTextStyles.caption(
                  color: _ServicesDesign.mutedAlt,
                ).copyWith(fontSize: 13.sp, height: 16 / 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServicesMenuItemRow extends StatelessWidget {
  const ServicesMenuItemRow({
    super.key,
    required this.item,
    required this.onAdd,
    this.onTap,
  });

  final ServiceMenuItem item;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 96.w,
        child: Row(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: _ServicesDesign.thumb,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style:
                        AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          height: 19 / 16,
                        ),
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(
                      color: _ServicesDesign.mutedAlt,
                    ).copyWith(fontSize: 13.sp, height: 16 / 13),
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    'BHD ${item.price}',
                    style:
                        AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          height: 18 / 15,
                        ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: _ServicesDesign.mint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: _ServicesDesign.greenDeep,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 19 / 16,
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

class ServicesBookingBar extends StatelessWidget {
  const ServicesBookingBar({
    super.key,
    this.itemCount = 1,
    this.total = '8.000',
    this.onTap,
  });

  final int itemCount;
  final String total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E6E0))),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Row(
            children: [
              Container(
                width: 25.w,
                height: 23.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '$itemCount',
                  style: AppTextStyles.labelSmall(
                    color: _ServicesDesign.greenActive,
                  ).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'View booking',
                style: AppTextStyles.labelMedium(
                  color: AppColors.white,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 16.sp),
              ),
              const Spacer(),
              Text(
                'BHD $total',
                style: AppTextStyles.labelMedium(
                  color: AppColors.white,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServicesOptionCard extends StatelessWidget {
  const ServicesOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ServiceOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _ServicesDesign.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style:
                        AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          height: 18 / 15,
                        ),
                  ),
                  Text(
                    option.subtitle,
                    style:
                        AppTextStyles.caption(
                          color: _ServicesDesign.mutedAlt,
                        ).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13.sp,
                          height: 16 / 13,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: selected ? _ServicesDesign.greenActive : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? _ServicesDesign.greenActive
                      : _ServicesDesign.cardBorder,
                  width: selected ? 0 : 1.5,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, color: AppColors.white, size: 12.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesSpecialistChips extends StatelessWidget {
  const ServicesSpecialistChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final option = options[index];
          final active = option == selected;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.w),
              decoration: BoxDecoration(
                color: active ? _ServicesDesign.greenActive : AppColors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: active
                      ? _ServicesDesign.greenActive
                      : _ServicesDesign.cardBorder,
                ),
              ),
              child: Text(
                option,
                style: AppTextStyles.labelSmall(
                  color: active ? AppColors.white : AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ServicesAddonRow extends StatelessWidget {
  const ServicesAddonRow({
    super.key,
    required this.addon,
    required this.checked,
    required this.onChanged,
  });

  final ServiceAddon addon;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: checked ? _ServicesDesign.greenActive : AppColors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: checked
                      ? _ServicesDesign.greenActive
                      : _ServicesDesign.cardBorder,
                  width: 1.5,
                ),
              ),
              child: checked
                  ? Icon(Icons.check, color: AppColors.white, size: 14.sp)
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                addon.name,
                style: AppTextStyles.labelMedium(
                  color: AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 15.sp),
              ),
            ),
            Text(
              '+ BHD ${addon.price}',
              style: AppTextStyles.labelSmall(
                color: _ServicesDesign.mutedAlt,
              ).copyWith(fontWeight: FontWeight.w500, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
