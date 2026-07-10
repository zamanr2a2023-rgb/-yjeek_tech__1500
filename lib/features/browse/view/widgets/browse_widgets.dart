import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
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
              child: Text(
                title,
                style: AppTextStyles.titleMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
            ),
            if (onCart != null)
              GestureDetector(
                onTap: onCart,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.shopping_cart_outlined, size: 20.sp),
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
  });

  final String hint;
  final VoidCallback? onTap;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool showCancel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20.sp, color: AppColors.textSecondary),
          SizedBox(width: 10.w),
          Expanded(
            child: onChanged != null
                ? TextField(
                    autofocus: true,
                    controller: value != null ? TextEditingController(text: value) : null,
                    onChanged: onChanged,
                    style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
                      fontSize: 14.sp,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    hint,
                    style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
          ),
          if (value != null && value!.isNotEmpty)
            GestureDetector(
              onTap: () => onChanged?.call(''),
              child: Icon(Icons.close, size: 18.sp, color: AppColors.textSecondary),
            ),
        ],
      ),
    );

    return Row(
      children: [
        Expanded(
          child: onTap != null ? GestureDetector(onTap: onTap, child: child) : child,
        ),
        if (showCancel) ...[
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onCancel,
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
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
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                option,
                style: AppTextStyles.labelSmall(
                  color: active ? AppColors.white : AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),
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
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final bool freeDeliveryOnly;
  final ValueChanged<bool>? onFreeDeliveryChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Text(
                'Sort: Top rated',
                style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => onFreeDeliveryChanged?.call(!freeDeliveryOnly),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: freeDeliveryOnly ? const Color(0xFFE8F5E9) : AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: freeDeliveryOnly ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              'Free delivery',
              style: AppTextStyles.labelSmall(
                color: freeDeliveryOnly ? AppColors.primary : AppColors.textPrimary,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 68.h,
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
                  top: 6.h,
                  right: 6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${restaurant.rating}',
                      style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),
                if (restaurant.badge != null)
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0D9),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        restaurant.badge!,
                        style: AppTextStyles.labelSmall(color: const Color(0xFF7A5E12))
                            .copyWith(fontWeight: FontWeight.w700, fontSize: 9.sp),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  if (restaurant.freeDelivery)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F0DC),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        'Free delivery',
                        style: AppTextStyles.labelSmall(color: const Color(0xFF7A5E12))
                            .copyWith(fontWeight: FontWeight.w700, fontSize: 9.sp),
                      ),
                    )
                  else
                    Text(
                      restaurant.cuisine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                        fontSize: 10.sp,
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
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [restaurant.gradientStart, restaurant.gradientEnd],
                    ),
                  ),
                ),
                if (restaurant.badge != null)
                  Positioned(
                    top: 4.h,
                    left: 4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0D9),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        restaurant.badge!,
                        style: AppTextStyles.labelSmall(color: const Color(0xFF7A5E12))
                            .copyWith(fontWeight: FontWeight.w700, fontSize: 8.sp),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    restaurant.cuisine,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      if (restaurant.freeDelivery)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F0DC),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            'Free delivery',
                            style: AppTextStyles.labelSmall(color: const Color(0xFF7A5E12))
                                .copyWith(fontWeight: FontWeight.w700, fontSize: 9.sp),
                          ),
                        ),
                      if (restaurant.freeDelivery) SizedBox(width: 8.w),
                      Text(
                        '${restaurant.deliveryMin} min',
                        style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${restaurant.rating}',
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowseOrderAgainRow extends StatelessWidget {
  const BrowseOrderAgainRow({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
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
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 72.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: BrowseData.orderAgainBrands.length,
            separatorBuilder: (_, _) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final (name, color) = BrowseData.orderAgainBrands[index];
              return Column(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name[0],
                      style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: 56.w,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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
                Row(
                  children: [
                    Text(
                      '★ ${restaurant.rating}',
                      style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      restaurant.cuisine,
                      style: AppTextStyles.labelSmall(color: const Color(0xFFDCE7D4)).copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      restaurant.distance,
                      style: AppTextStyles.labelSmall(color: const Color(0xFFDCE7D4)).copyWith(
                        fontSize: 12.sp,
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
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.description,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'BHD ${item.price}',
                    style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
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
  const BrowseCartBar({super.key, this.onTap});

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
          borderRadius: BorderRadius.circular(14.r),
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
                '${BrowseData.cartItemCount}',
                style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'View cart',
              style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
            const Spacer(),
            Text(
              'BHD ${BrowseData.cartTotal}',
              style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
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
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFC7CCC7),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                option.label,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Text(
              option.subtitle,
              style: AppTextStyles.labelSmall(
                color: option.extraPrice != null ? AppColors.textPrimary : AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),
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
  });

  final BrowseAddonOption addon;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: checked ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: checked ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: checked
                  ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                addon.label,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontSize: 13.sp,
                ),
              ),
            ),
            Text(
              '+ BHD ${addon.price}',
              style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
