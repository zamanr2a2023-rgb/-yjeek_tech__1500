import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';

const Color _kMintBg = Color(0xFFE8F5E9);
const Color _kTile = Color(0xFFE8F5E9);
const Color _kMuted = Color(0xFF6B6B6B);
const Color _kBorder = Color(0xFFDEDEDE);
const Color _kStar = Color(0xFFD98C1A);

/// Top bar: mint strip · back + search circles.
class FashionVendorTopBar extends StatelessWidget {
  const FashionVendorTopBar({
    super.key,
    this.onBack,
    this.onSearch,
    this.searchOpen = false,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final bool searchOpen;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kMintBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
          child: Row(
            children: [
              _CircleIcon(
                icon: Icons.chevron_left_rounded,
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              if (onSearch != null)
                _CircleIcon(
                  icon: searchOpen
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  onTap: onSearch!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 22.sp, color: AppColors.textPrimary),
      ),
    );
  }
}

/// Green brand band: logo · name · type·area · rating.
class FashionVendorBrandBand extends StatelessWidget {
  const FashionVendorBrandBand({super.key, required this.store});

  final ElectronicsStore store;

  @override
  Widget build(BuildContext context) {
    final logo = store.logoUrl ?? store.imageUrl;
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: logo != null && logo.isNotEmpty
                ? AppNetworkImage(
                    url: logo,
                    fit: BoxFit.cover,
                    errorWidget: const ColoredBox(color: Color(0x33FFFFFF)),
                  )
                : Center(
                    child: Text(
                      store.name.isNotEmpty
                          ? store.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.titleSmall(color: AppColors.white)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall(color: AppColors.white)
                      .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                if (store.typeAreaLabel.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    store.typeAreaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ).copyWith(fontSize: 12.sp),
                  ),
                ],
              ],
            ),
          ),
          if (store.hasRating && store.rating > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 14.sp, color: _kStar),
                SizedBox(width: 2.w),
                Text(
                  store.rating.toStringAsFixed(1),
                  style: AppTextStyles.labelSmall(color: AppColors.white)
                      .copyWith(
                    fontWeight: FontWeight.w600,
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

/// Scheduled pill + min order.
class FashionVendorOrderMeta extends StatelessWidget {
  const FashionVendorOrderMeta({super.key, required this.store});

  final ElectronicsStore store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'Scheduled',
                style: AppTextStyles.labelSmall(color: AppColors.white)
                    .copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          if (store.hasMinOrder) ...[
            Text(
              store.minOrderDisplay,
              style: AppTextStyles.titleSmall(color: AppColors.textPrimary)
                  .copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Min order',
              style: AppTextStyles.caption(color: _kMuted)
                  .copyWith(fontSize: 12.sp),
            ),
          ] else
            Text(
              'No minimum order',
              style: AppTextStyles.bodyMedium(color: _kMuted)
                  .copyWith(fontSize: 13.sp),
            ),
        ],
      ),
    );
  }
}

enum PharmacyDeliveryMode { deliverNow, scheduled }

/// Pharmacy.md — Deliver Now / Scheduled + stats + outside-radius banner.
class PharmacyVendorOrderMeta extends StatelessWidget {
  const PharmacyVendorOrderMeta({
    super.key,
    required this.store,
    required this.mode,
    required this.onModeChanged,
  });

  final ElectronicsStore store;
  final PharmacyDeliveryMode mode;
  final ValueChanged<PharmacyDeliveryMode> onModeChanged;

  static const _warnBg = Color(0xFFFFF8E7);
  static const _warnText = Color(0xFF8A5A12);

  @override
  Widget build(BuildContext context) {
    final onDemandOk = store.onDemandInRadius;
    final effective = (!onDemandOk && mode == PharmacyDeliveryMode.deliverNow)
        ? PharmacyDeliveryMode.scheduled
        : mode;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _ModePill(
                  label: 'Deliver Now',
                  selected: effective == PharmacyDeliveryMode.deliverNow,
                  enabled: onDemandOk,
                  onTap: onDemandOk
                      ? () => onModeChanged(PharmacyDeliveryMode.deliverNow)
                      : null,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ModePill(
                  label: 'Scheduled',
                  selected: effective == PharmacyDeliveryMode.scheduled,
                  enabled: true,
                  onTap: () => onModeChanged(PharmacyDeliveryMode.scheduled),
                ),
              ),
            ],
          ),
          if (!onDemandOk) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _warnBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "You are outside this pharmacy's instant delivery area, scheduled delivery only.",
                style: AppTextStyles.caption(color: _warnText).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  height: 1.3,
                ),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          _StatsRow(store: store, mode: effective),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = !enabled
        ? const Color(0xFFF0F0F0)
        : selected
            ? AppColors.primary
            : AppColors.white;
    final fg = !enabled
        ? const Color(0xFFB0B0B0)
        : selected
            ? AppColors.white
            : AppColors.textPrimary;
    final border = !enabled
        ? const Color(0xFFE8E8E8)
        : selected
            ? AppColors.primary
            : _kBorder;

    return Opacity(
      opacity: enabled ? 1 : 0.85,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 36.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: fg).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.store, required this.mode});

  final ElectronicsStore store;
  final PharmacyDeliveryMode mode;

  @override
  Widget build(BuildContext context) {
    late final String v1;
    late final String l1;
    late final String v2;
    late final String l2;
    late final String v3;
    late final String l3;

    if (mode == PharmacyDeliveryMode.deliverNow) {
      final eta = store.deliveryTimeMin ?? 25;
      final fee = store.deliveryFee ?? 0.5;
      final min = store.minOrderAmount ?? 3;
      v1 = '$eta min';
      l1 = 'Arrives in';
      v2 = 'BHD ${fee.toStringAsFixed(3)}';
      l2 = 'Delivery fee';
      v3 = min == min.roundToDouble()
          ? 'BHD ${min.toStringAsFixed(0)}'
          : 'BHD ${min.toStringAsFixed(3)}';
      l3 = 'Min order';
    } else {
      final fee = store.scheduledDeliveryFee ?? 1.0;
      final min = store.scheduledMinOrderAmount ?? 5;
      v1 = 'Tomorrow';
      l1 = 'Earliest slot';
      v2 = 'BHD ${fee.toStringAsFixed(3)}';
      l2 = 'Shipping';
      v3 = min == min.roundToDouble()
          ? 'BHD ${min.toStringAsFixed(0)}'
          : 'BHD ${min.toStringAsFixed(3)}';
      l3 = 'Min order';
    }

    Widget cell(String value, String label) {
      return Expanded(
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                  .copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: _kMuted)
                  .copyWith(fontSize: 11.sp),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        cell(v1, l1),
        Container(width: 1, height: 28.h, color: _kBorder),
        cell(v2, l2),
        Container(width: 1, height: 28.h, color: _kBorder),
        cell(v3, l3),
      ],
    );
  }
}

/// Main category chips (Men / Women / …).
class FashionVendorCategoryChips extends StatelessWidget {
  const FashionVendorCategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final label = categories[index];
          final active = label == selected;
          return GestureDetector(
            onTap: () => onSelected(label),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: active ? AppColors.primary : _kBorder,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.labelSmall(
                  color: active ? AppColors.white : AppColors.textPrimary,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Grid / list toggle (right-aligned).
class FashionVendorViewToggle extends StatelessWidget {
  const FashionVendorViewToggle({
    super.key,
    required this.isGridView,
    required this.onChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
        child: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: _kMintBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Seg(
                icon: Icons.grid_view_rounded,
                active: isGridView,
                onTap: () => onChanged(true),
              ),
              _Seg(
                icon: Icons.view_list_rounded,
                active: !isGridView,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
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
        height: 28.w,
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

/// Accordion header (Men ▾ / Women ›).
class FashionVendorAccordionHeader extends StatelessWidget {
  const FashionVendorAccordionHeader({
    super.key,
    required this.title,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleSmall(color: AppColors.textPrimary)
                    .copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class FashionVendorSubgroupLabel extends StatelessWidget {
  const FashionVendorSubgroupLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 6.h),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption(color: _kMuted).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// List product row (image + title + desc + price + add).
class FashionVendorProductListTile extends StatelessWidget {
  const FashionVendorProductListTile({
    super.key,
    required this.item,
    this.onTap,
    this.onAdd,
    this.isAdding = false,
  });

  final BrowseMenuItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final bool isAdding;

  @override
  Widget build(BuildContext context) {
    final desc = item.localizedDescription.trim();
    final showDesc = desc.isNotEmpty && desc != '___';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _kBorder)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72.w,
              height: 72.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: _kTile,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? AppNetworkImage(
                            url: item.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: const ColoredBox(color: _kTile),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -2.w,
                    bottom: -2.h,
                    child: _AddCircle(
                      hasModifiers: item.hasModifiers,
                      isAdding: isAdding,
                      onTap: onAdd ?? onTap,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.localizedName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (showDesc) ...[
                    SizedBox(height: 4.h),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(color: _kMuted)
                          .copyWith(fontSize: 12.sp, height: 1.35),
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        'BHD ${item.price == '—' || item.price == '-' ? '—' : item.price}',
                        style: AppTextStyles.labelMedium(color: AppColors.primary)
                            .copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                      if (item.isHighValue) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'High value',
                            style: AppTextStyles.caption(
                              color: const Color(0xFFE65100),
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
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

/// Grid product card (image + title + price, no description).
class FashionVendorProductGridTile extends StatelessWidget {
  const FashionVendorProductGridTile({
    super.key,
    required this.item,
    this.onTap,
    this.onAdd,
    this.isAdding = false,
  });

  final BrowseMenuItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final bool isAdding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _kTile,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? AppNetworkImage(
                          url: item.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: const ColoredBox(color: _kTile),
                        )
                      : null,
                ),
                Positioned(
                  right: 6.w,
                  bottom: 6.h,
                  child: _AddCircle(
                    hasModifiers: item.hasModifiers,
                    isAdding: isAdding,
                    onTap: onAdd ?? onTap,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.localizedName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                .copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'BHD ${item.price == '—' || item.price == '-' ? '—' : item.price}',
            style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
          if (item.isHighValue) ...[
            SizedBox(height: 4.h),
            Text(
              'High value',
              style: AppTextStyles.caption(color: const Color(0xFFE65100))
                  .copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddCircle extends StatelessWidget {
  const _AddCircle({
    required this.hasModifiers,
    required this.isAdding,
    this.onTap,
  });

  final bool hasModifiers;
  final bool isAdding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAdding ? null : onTap,
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: isAdding
            ? SizedBox(
                width: 12.w,
                height: 12.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Icon(
                hasModifiers
                    ? Icons.arrow_forward_rounded
                    : Icons.add_rounded,
                size: 14.sp,
                color: AppColors.white,
              ),
      ),
    );
  }
}
