import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';

class ServicesCategoryGrid extends StatelessWidget {
  const ServicesCategoryGrid({super.key, required this.onCategoryTap});

  final ValueChanged<ServiceCategoryItem> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1.75,
      ),
      itemCount: ServicesData.categories.length,
      itemBuilder: (context, index) {
        final category = ServicesData.categories[index];
        return GestureDetector(
          onTap: () => onCategoryTap(category),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
            ),
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
                  child: Text(category.emoji, style: TextStyle(fontSize: 20.sp)),
                ),
                const Spacer(),
                Text(
                  category.name,
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
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
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                ServicesData.popularNearYou,
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                ServicesData.seeAll,
                style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...providers.map(
          (provider) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: ServicesPopularCard(
              provider: provider,
              onTap: () => onProviderTap?.call(provider),
            ),
          ),
        ),
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
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: provider.gradientStart,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(provider.emoji, style: TextStyle(fontSize: 26.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    provider.category,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '★ ${provider.rating} (${provider.reviewCount})',
                    style: AppTextStyles.caption(color: const Color(0xFFD98C1A)).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'from BHD ${provider.priceFrom}',
              style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
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

class ServicesCategoryHeader extends StatelessWidget {
  const ServicesCategoryHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 12.sp,
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
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: active ? AppColors.primary : AppColors.border),
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
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('Sort', Icons.swap_vert),
        SizedBox(width: 8.w),
        _chip('Offers', Icons.local_offer_outlined),
        const Spacer(),
        CategoriesViewToggle(isGrid: isGridView, onChanged: onViewChanged),
      ],
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textPrimary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.labelSmall().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesProviderGridCard extends StatelessWidget {
  const ServicesProviderGridCard({super.key, required this.provider, this.onTap});

  final ServiceProvider provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: provider.gradientStart,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Text(provider.emoji, style: TextStyle(fontSize: 30.sp)),
            ),
            SizedBox(height: 6.h),
            Text(
              provider.name,
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              '★ ${provider.rating} · ${provider.distance}',
              style: AppTextStyles.caption(color: const Color(0xFFD98C1A)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              provider.tags,
              style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                fontSize: 11.sp,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesProviderListCard extends StatelessWidget {
  const ServicesProviderListCard({super.key, required this.provider, this.onTap});

  final ServiceProvider provider;
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
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: provider.gradientStart,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(provider.emoji, style: TextStyle(fontSize: 26.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '★ ${provider.rating} · ${provider.distance}',
                    style: AppTextStyles.caption(color: const Color(0xFFD98C1A)).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    provider.tags,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    children: [
                      if (provider.atVenue) const _VenueTag(label: 'At venue'),
                      if (provider.atHome) const _VenueTag(label: 'At home'),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

class _VenueTag extends StatelessWidget {
  const _VenueTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.accountIconBackground,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: AppColors.primary).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
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
                colors: [provider.gradientStart, provider.gradientEnd],
              ),
            ),
          ),
          Positioned(
            top: 16.h,
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
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, height: 1),
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
                  provider.name,
                  style: AppTextStyles.displayMedium().copyWith(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      '★ ${provider.rating} (${provider.reviewCount})',
                      style: AppTextStyles.labelSmall().copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      provider.category,
                      style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '· ${provider.distance} away',
                      style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                        fontSize: 13.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Open · 9–9',
                  style: AppTextStyles.labelMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                Text(
                  'Today',
                  style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venueLabel,
                style: AppTextStyles.labelMedium().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              Text(
                'Walk-in / book',
                style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                  fontSize: 13.sp,
                ),
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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFFDBE8DE),
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'BHD ${item.price}',
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
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
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2EB),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
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
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '$itemCount',
                style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'View booking',
              style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            const Spacer(),
            Text(
              'BHD $total',
              style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ],
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
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
      height: 35.h,
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
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: active ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                option,
                style: AppTextStyles.labelSmall(
                  color: active ? AppColors.white : AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
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
        padding: EdgeInsets.symmetric(vertical: 8.h),
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
              child: checked
                  ? Icon(Icons.check, color: AppColors.white, size: 14.sp)
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                addon.name,
                style: AppTextStyles.labelMedium().copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                ),
              ),
            ),
            Text(
              '+ BHD ${addon.price}',
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
