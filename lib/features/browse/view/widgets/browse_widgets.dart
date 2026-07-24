import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';

class BrowseTopBar extends StatelessWidget {
  const BrowseTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.onCart,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
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
                child: Text(
                  '‹',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.26,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                      height: 1.26,
                    ),
              ),
            ),
            if (onCart != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
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
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BrowseSearchBar extends StatelessWidget {
  const BrowseSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.value,
    this.onChanged,
    this.showCancel = false,
    this.onCancel,
    this.autofocus,
  });

  final String hint;
  final VoidCallback? onTap;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool showCancel;
  final VoidCallback? onCancel;
  final bool? autofocus;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0E6E0)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16.sp, color: const Color(0xFF6B756E)),
          SizedBox(width: 8.w),
          Expanded(
            child: onChanged != null
                ? TextField(
                    autofocus: autofocus ?? true,
                    controller: value != null
                        ? TextEditingController(text: value)
                        : null,
                    onChanged: onChanged,
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(fontSize: 13.sp),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    hint,
                    style: AppTextStyles.bodySmall(
                      color: const Color(0xFF6B756E),
                    ).copyWith(fontSize: 13.sp, height: 16 / 13),
                  ),
          ),
          if (value != null && value!.isNotEmpty)
            GestureDetector(
              onTap: () => onChanged?.call(''),
              child: Icon(
                Icons.close,
                size: 18.sp,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );

    return Row(
      children: [
        Expanded(
          child: onTap != null
              ? GestureDetector(onTap: onTap, child: child)
              : child,
        ),
        if (showCancel) ...[
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onCancel,
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium(
                color: AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
          ),
        ],
      ],
    );
  }
}

class BrowseFilterChips extends StatelessWidget {
  const BrowseFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.activeColor,
    this.inactiveBorderColor,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final Color? activeColor;
  final Color? inactiveBorderColor;

  @override
  Widget build(BuildContext context) {
    final selectedColor = activeColor ?? AppColors.primary;
    final idleBorder = inactiveBorderColor ?? const Color(0xFFE2E8DD);

    return SizedBox(
      height: 36.h,
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
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: active ? selectedColor : AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: active ? selectedColor : idleBorder),
              ),
              child: Text(
                option,
                style: AppTextStyles.labelSmall(
                  color: active ? AppColors.white : AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BrowseSortBar extends StatelessWidget {
  const BrowseSortBar({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
    this.freeDeliveryOnly = false,
    this.onFreeDeliveryChanged,
    this.sort = 'rating',
    this.onSortChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final bool freeDeliveryOnly;
  final ValueChanged<bool>? onFreeDeliveryChanged;
  final String sort;
  final ValueChanged<String>? onSortChanged;

  static const _options = <(String value, String label)>[
    ('rating', 'Top rated'),
    ('popular', 'Most Popular'),
    ('fastest', 'Fastest Delivery'),
  ];

  String get _sortLabel {
    for (final option in _options) {
      if (option.$1 == sort) return option.$2;
    }
    return 'Top rated';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<String>(
          initialValue: sort,
          onSelected: onSortChanged,
          offset: Offset(0, 36.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          itemBuilder: (context) => [
            for (final option in _options)
              PopupMenuItem<String>(
                value: option.$1,
                child: Text(
                  option.$2,
                  style: AppTextStyles.labelSmall(
                    color: option.$1 == sort
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(
                  'Sort: $_sortLabel',
                  style: AppTextStyles.labelSmall(
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => onFreeDeliveryChanged?.call(!freeDeliveryOnly),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: freeDeliveryOnly
                  ? const Color(0xFFE8F5E9)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: freeDeliveryOnly ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              'Free delivery',
              style: AppTextStyles.labelSmall(
                color: freeDeliveryOnly
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
            ),
          ),
        ),
        const Spacer(),
        CategoriesViewToggle(isGrid: isGridView, onChanged: onViewChanged),
      ],
    );
  }
}

class BrowseRestaurantGridCard extends StatelessWidget {
  const BrowseRestaurantGridCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final BrowseRestaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final promoLabel =
        restaurant.badge ?? (restaurant.freeDelivery ? 'Free delivery' : null);

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
            Expanded(
              flex: 68,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-0.8, -0.6),
                        end: const Alignment(0.8, 0.8),
                        colors: [
                          restaurant.gradientStart,
                          restaurant.gradientEnd,
                        ],
                      ),
                    ),
                  ),
                  if (restaurant.imageUrl != null &&
                      restaurant.imageUrl!.isNotEmpty)
                    Positioned.fill(
                      child: AppNetworkImage(
                        url: restaurant.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Positioned(
                    top: 5.w,
                    left: 5.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.w,
                      ),
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
                            '${restaurant.rating}',
                            style:
                                AppTextStyles.labelSmall(
                                  color: AppColors.textPrimary,
                                ).copyWith(
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
            ),
            Expanded(
              flex: 62,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        restaurant.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.labelSmall(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5.sp,
                              height: 1.2,
                            ),
                      ),
                    ),
                    if (promoLabel != null) ...[
                      SizedBox(height: 3.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F0DC),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          promoLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTextStyles.labelSmall(
                                color: const Color(0xFF7A5E12),
                              ).copyWith(
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

class BrowseRestaurantListCard extends StatelessWidget {
  const BrowseRestaurantListCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final BrowseRestaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      begin: const Alignment(-0.8, -0.6),
                      end: const Alignment(0.8, 0.8),
                      colors: [
                        restaurant.gradientStart,
                        restaurant.gradientEnd,
                      ],
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: restaurant.imageUrl != null &&
                          restaurant.imageUrl!.isNotEmpty
                      ? AppNetworkImage(
                          url: restaurant.imageUrl!,
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(14.r),
                        )
                      : null,
                ),
                if (restaurant.badge != null)
                  Positioned(
                    top: 4.h,
                    left: 4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBC34A),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        restaurant.badge!,
                        style:
                            AppTextStyles.labelSmall(
                              color: const Color(0xFF5A4503),
                            ).copyWith(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTextStyles.labelMedium(
                                color: AppColors.textPrimary,
                              ).copyWith(
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
                        '${restaurant.rating}',
                        style:
                            AppTextStyles.labelSmall(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                              height: 1.26,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: const Color(0xFF6B7B6E))
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          height: 1.26,
                        ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (restaurant.freeDelivery) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9EFE0),
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Text(
                            'Free Delivery',
                            style:
                                AppTextStyles.labelSmall(
                                  color: AppColors.primary,
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.5.sp,
                                  height: 1.26,
                                ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Icon(
                        Icons.access_time_rounded,
                        size: 12.sp,
                        color: const Color(0xFF6B7B6E),
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          '${restaurant.deliveryMin} min',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTextStyles.caption(
                                color: const Color(0xFF6B7B6E),
                              ).copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 11.sp,
                                height: 1.26,
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
      ),
    );
  }
}

class BrowseOrderAgainRow extends StatelessWidget {
  const BrowseOrderAgainRow({
    super.key,
    this.onSeeAll,
    this.brands,
    this.onBrandTap,
  });

  final VoidCallback? onSeeAll;
  /// (name, color, vendorId?)
  final List<(String, Color, String?)>? brands;
  final void Function(String? vendorId, String name)? onBrandTap;

  @override
  Widget build(BuildContext context) {
    final items = brands ??
        BrowseData.orderAgainBrands
            .map<(String, Color, String?)>((e) => (e.$1, e.$2, null))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order again',
              style: AppTextStyles.titleSmall().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                height: 1.28,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See all',
                style: AppTextStyles.labelSmall(color: AppColors.primary)
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      height: 1.28,
                    ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Builder(
          builder: (context) {
            final circleSize = 62.w;
            final labelHeight = 14.h;
            final gap = 7.h;
            return SizedBox(
              height: circleSize + gap + labelHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(width: 16.w),
                itemBuilder: (context, index) {
                  final (name, color, vendorId) = items[index];
                  final initial = name.isNotEmpty ? name[0] : '';
                  return GestureDetector(
                    onTap: () => onBrandTap?.call(vendorId, name),
                    child: SizedBox(
                      width: circleSize,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2E8DD)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style:
                                  AppTextStyles.labelMedium(
                                    color: AppColors.white,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                  ),
                            ),
                          ),
                          SizedBox(height: gap),
                          SizedBox(
                            height: labelHeight,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTextStyles.caption(
                                    color: AppColors.textPrimary,
                                  ).copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11.sp,
                                    height: 1.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class BrowseVendorHero extends StatelessWidget {
  const BrowseVendorHero({super.key, required this.restaurant});

  final BrowseRestaurant restaurant;

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
                begin: const Alignment(-0.8, -0.6),
                end: const Alignment(0.8, 0.8),
                colors: [restaurant.gradientStart, restaurant.gradientEnd],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 18.w,
            right: 18.w,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
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
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
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
                  style: AppTextStyles.displayMedium(color: AppColors.white)
                      .copyWith(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      '★',
                      style: TextStyle(
                        color: const Color(0xFFC9A84C),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${restaurant.rating} (${restaurant.reviewCount})',
                      style: AppTextStyles.labelSmall(color: AppColors.white)
                          .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                            height: 1.3,
                          ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        '${restaurant.cuisine} · ${restaurant.distance}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.labelSmall(
                              color: const Color(0xFFE2EFE6),
                            ).copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                              height: 1.3,
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

class BrowseMenuItemRow extends StatelessWidget {
  const BrowseMenuItemRow({
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
                gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.description,
                    style: AppTextStyles.caption(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'BHD ${item.price}',
                    style: AppTextStyles.labelMedium(
                      color: AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
            Container(
              width: 32.w,
              height: 32.w,
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
          ],
        ),
      ),
    );
  }
}

class BrowseCartBar extends StatelessWidget {
  const BrowseCartBar({
    super.key,
    this.onTap,
    this.itemCount,
    this.totalLabel,
  });

  final VoidCallback? onTap;
  final int? itemCount;
  final String? totalLabel;

  @override
  Widget build(BuildContext context) {
    final count = itemCount ?? BrowseData.cartItemCount;
    final total = totalLabel ?? BrowseData.cartTotal;
    if (count <= 0) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                '$count',
                style: AppTextStyles.labelSmall(color: AppColors.white)
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      height: 1.3,
                    ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'View cart',
              style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Text(
              'BHD $total',
              style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowseSizeOptionCard extends StatelessWidget {
  const BrowseSizeOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final BrowseSizeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8DD),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style:
                        AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1.3,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    option.subtitle,
                    style: AppTextStyles.caption(color: const Color(0xFF6B7B6E))
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : AppColors.white,
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFFE2E8DD), width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowseAddonRow extends StatelessWidget {
  const BrowseAddonRow({
    super.key,
    required this.addon,
    required this.checked,
    required this.onChanged,
    this.splitPrice = false,
  });

  final BrowseAddonOption addon;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool splitPrice;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: checked ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(7.r),
                border: Border.all(
                  color: checked ? AppColors.primary : const Color(0xFFE2E8DD),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: checked
                  ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                addon.label,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                    .copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      height: 1.3,
                    ),
              ),
            ),
            Text(
              splitPrice ? '+ BHD ${addon.price}' : '(+ BHD ${addon.price})',
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                  .copyWith(
                    fontWeight: splitPrice ? FontWeight.w600 : FontWeight.w500,
                    fontSize: splitPrice ? 13.sp : 14.sp,
                    height: 1.3,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
