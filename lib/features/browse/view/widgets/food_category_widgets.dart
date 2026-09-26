import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/browse_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/model/pickup_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';

enum FoodOrderType { delivery, dineIn, pickup }

const _borderColor = Color(0xFFDEDEDE);
const _textDark = Color(0xFF1A1A1A);
const _imagePlaceholder = Color(0xFFE8F5E9);

class FoodOrderTypeTabs extends StatelessWidget {
  const FoodOrderTypeTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabledTypes,
  });

  final FoodOrderType selected;
  final ValueChanged<FoodOrderType> onChanged;
  /// When null, all three tabs are shown. Otherwise only enabled modes.
  final Set<FoodOrderType>? enabledTypes;

  @override
  Widget build(BuildContext context) {
    final enabled = enabledTypes ??
        const {
          FoodOrderType.delivery,
          FoodOrderType.dineIn,
          FoodOrderType.pickup,
        };
    final tabs = <(String, FoodOrderType)>[
      if (enabled.contains(FoodOrderType.delivery))
        ('Delivery', FoodOrderType.delivery),
      if (enabled.contains(FoodOrderType.dineIn))
        ('Dine-in', FoodOrderType.dineIn),
      if (enabled.contains(FoodOrderType.pickup))
        ('Pickup', FoodOrderType.pickup),
    ];
    if (tabs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            Expanded(child: _tab(tabs[i].$1, tabs[i].$2)),
          ],
        ],
      ),
    );
  }

  Widget _tab(String label, FoodOrderType type) {
    final active = selected == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: active ? null : Border.all(color: _borderColor),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: active ? AppColors.white : _textDark,
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
        ),
      ),
    );
  }
}

class FoodQuickFilterChip extends StatelessWidget {
  const FoodQuickFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.showDropdownIcon = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool showDropdownIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F5E9) : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primary : _borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall(
                color: selected ? AppColors.primary : _textDark,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
            ),
            if (showDropdownIcon) ...[
              SizedBox(width: 2.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16.sp,
                color: selected ? AppColors.primary : _textDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FoodQuickFilterRow extends StatelessWidget {
  const FoodQuickFilterRow({
    super.key,
    required this.orderType,
    required this.freeDelivery,
    required this.openNow,
    required this.availableOnly,
    required this.readyIn15,
    required this.cuisineLabel,
    required this.sortLabel,
    required this.onCuisineTap,
    required this.onFreeDeliveryTap,
    required this.onOpenNowTap,
    required this.onAvailableTap,
    required this.onReadyIn15Tap,
    required this.onSortSelected,
    this.onFiltersTap,
    this.filtersActive = false,
    this.sortOptions = const [],
  });

  final FoodOrderType orderType;
  final bool freeDelivery;
  final bool openNow;
  final bool availableOnly;
  final bool readyIn15;
  final String cuisineLabel;
  final String sortLabel;
  final VoidCallback onCuisineTap;
  final VoidCallback onFreeDeliveryTap;
  final VoidCallback onOpenNowTap;
  final VoidCallback onAvailableTap;
  final VoidCallback onReadyIn15Tap;
  final ValueChanged<String> onSortSelected;
  final VoidCallback? onFiltersTap;
  final bool filtersActive;
  final List<(String value, String label)> sortOptions;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      FoodQuickFilterChip(label: cuisineLabel, onTap: onCuisineTap),
    ];

    switch (orderType) {
      case FoodOrderType.delivery:
        chips.addAll([
          FoodQuickFilterChip(
            label: 'Open now',
            selected: openNow,
            onTap: onOpenNowTap,
          ),
          FoodQuickFilterChip(
            label: BrowseStrings.freeDelivery,
            selected: freeDelivery,
            onTap: onFreeDeliveryTap,
          ),
          _sortChip(context),
          if (onFiltersTap != null)
            FoodQuickFilterChip(
              label: 'Filters',
              selected: filtersActive,
              onTap: onFiltersTap,
              showDropdownIcon: true,
            ),
        ]);
      case FoodOrderType.dineIn:
        chips.addAll([
          _sortChip(context),
          FoodQuickFilterChip(
            label: 'Available',
            selected: availableOnly,
            onTap: onAvailableTap,
          ),
          FoodQuickFilterChip(
            label: 'Open now',
            selected: openNow,
            onTap: onOpenNowTap,
          ),
        ]);
      case FoodOrderType.pickup:
        chips.addAll([
          FoodQuickFilterChip(
            label: 'Ready in 15 min',
            selected: readyIn15,
            onTap: onReadyIn15Tap,
          ),
          _sortChip(context),
          FoodQuickFilterChip(
            label: 'Open now',
            selected: openNow,
            onTap: onOpenNowTap,
          ),
        ]);
    }

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: chips.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }

  Widget _sortChip(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSortSelected,
      offset: Offset(0, 36.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      itemBuilder: (context) => [
        for (final option in sortOptions)
          PopupMenuItem<String>(
            value: option.$1,
            child: Text(
              option.$2,
              style: AppTextStyles.labelSmall(color: AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
            ),
          ),
      ],
      child: FoodQuickFilterChip(
        label: BrowseStrings.sortWith(sortLabel),
        showDropdownIcon: true,
      ),
    );
  }
}

/// All Filters sheet: min rating, delivery time, has offers (server-backed).
class FoodAllFiltersSheet extends StatefulWidget {
  const FoodAllFiltersSheet({
    super.key,
    required this.minRating,
    required this.maxDeliveryTime,
    required this.hasOffers,
  });

  final double? minRating;
  final int? maxDeliveryTime;
  final bool hasOffers;

  @override
  State<FoodAllFiltersSheet> createState() => _FoodAllFiltersSheetState();
}

class _FoodAllFiltersSheetState extends State<FoodAllFiltersSheet> {
  static const _ratingOptions = <(double?, String)>[
    (null, 'Any'),
    (3.5, '3.5+'),
    (4.0, '4.0+'),
    (4.5, '4.5+'),
  ];

  static const _deliveryOptions = <(int?, String)>[
    (null, 'Any'),
    (30, 'Under 30 min'),
    (45, 'Under 45 min'),
    (60, 'Under 60 min'),
  ];

  late double? _minRating;
  late int? _maxDeliveryTime;
  late bool _hasOffers;

  @override
  void initState() {
    super.initState();
    _minRating = widget.minRating;
    _maxDeliveryTime = widget.maxDeliveryTime;
    _hasOffers = widget.hasOffers;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'All filters',
                    style: AppTextStyles.titleSmall(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _minRating = null;
                      _maxDeliveryTime = null;
                      _hasOffers = false;
                    });
                  },
                  child: Text(
                    'Clear',
                    style: AppTextStyles.labelSmall(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Minimum rating',
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final option in _ratingOptions)
                  FoodQuickFilterChip(
                    label: option.$2,
                    selected: _minRating == option.$1,
                    onTap: () => setState(() => _minRating = option.$1),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Delivery time',
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final option in _deliveryOptions)
                  FoodQuickFilterChip(
                    label: option.$2,
                    selected: _maxDeliveryTime == option.$1,
                    onTap: () => setState(() => _maxDeliveryTime = option.$1),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            FoodQuickFilterChip(
              label: 'Has offers & discounts',
              selected: _hasOffers,
              onTap: () => setState(() => _hasOffers = !_hasOffers),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context, (
                    minRating: _minRating,
                    maxDeliveryTime: _maxDeliveryTime,
                    hasOffers: _hasOffers,
                  ));
                },
                child: Text(
                  'Apply',
                  style: AppTextStyles.labelMedium(color: AppColors.white)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodViewToggleRow extends StatelessWidget {
  const FoodViewToggleRow({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Row(
        children: [
          const Spacer(),
          CategoriesViewToggle(isGrid: isGridView, onChanged: onViewChanged),
        ],
      ),
    );
  }
}

class FoodDeliveryListCard extends StatelessWidget {
  const FoodDeliveryListCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final BrowseRestaurant restaurant;
  final VoidCallback? onTap;

  String get _etaRange {
    final min = restaurant.deliveryMin;
    return '$min–${min + 10} min';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VendorThumb(
              imageUrl: restaurant.imageUrl,
              gradientStart: restaurant.gradientStart,
              gradientEnd: restaurant.gradientEnd,
            ),
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
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium(color: _textDark)
                              .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _ratingBadge(
                        restaurant.rating,
                        hasRating: restaurant.hasRating,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    restaurant.area ?? restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 13.sp),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Flexible(
                        child: _DeliveryFeeBadge(
                          freeDelivery: restaurant.freeDelivery,
                          deliveryFee: restaurant.deliveryFee,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.schedule_outlined,
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _etaRange,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 12.sp),
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

class _VendorThumb extends StatelessWidget {
  const _VendorThumb({
    required this.imageUrl,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String? imageUrl;
  final Color gradientStart;
  final Color gradientEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          begin: const Alignment(-0.8, -0.6),
          end: const Alignment(0.8, 0.8),
          colors: [gradientStart, gradientEnd],
        ),
        color: _imagePlaceholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? AppNetworkImage(url: imageUrl!, fit: BoxFit.cover)
          : ColoredBox(color: _imagePlaceholder),
    );
  }
}

/// Figma badge: paid `#ECECEC` / `#555555`, free `#E8F5E9` / `#4CAF50`.
class _DeliveryFeeBadge extends StatelessWidget {
  const _DeliveryFeeBadge({
    required this.freeDelivery,
    required this.deliveryFee,
  });

  final bool freeDelivery;
  final String deliveryFee;

  String get _paidLabel {
    final parsed = double.tryParse(deliveryFee);
    final fee = parsed != null ? parsed.toStringAsFixed(3) : deliveryFee;
    return 'BHD $fee delivery';
  }

  @override
  Widget build(BuildContext context) {
    final isFree = freeDelivery;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isFree ? const Color(0xFFE8F5E9) : const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        isFree ? 'Free Delivery' : _paidLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelSmall(
          color: isFree ? AppColors.primary : const Color(0xFF555555),
        ).copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 11.sp,
          height: 1.2,
        ),
      ),
    );
  }
}

class FoodDeliveryGridCard extends StatelessWidget {
  const FoodDeliveryGridCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final BrowseRestaurant restaurant;
  final VoidCallback? onTap;

  String get _etaRange {
    final min = restaurant.deliveryMin;
    return '$min–${min + 10} min';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: _imagePlaceholder),
                  if (restaurant.imageUrl != null &&
                      restaurant.imageUrl!.isNotEmpty)
                    AppNetworkImage(
                      url: restaurant.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            restaurant.gradientStart.withValues(alpha: 0.35),
                            restaurant.gradientEnd.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall(color: _textDark).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      _ratingBadge(
                        restaurant.rating,
                        compact: true,
                        hasRating: restaurant.hasRating,
                      ),
                      const Spacer(),
                      Text(
                        _etaRange,
                        style: AppTextStyles.caption(
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 11.sp, height: 1.1),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  _DeliveryFeeBadge(
                    freeDelivery: restaurant.freeDelivery,
                    deliveryFee: restaurant.deliveryFee,
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

class FoodDineInListCard extends StatelessWidget {
  const FoodDineInListCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final DineInRestaurant restaurant;
  final VoidCallback? onTap;

  String get _areaLine {
    final area = restaurant.subtitle ?? restaurant.cuisine;
    return '$area · ${restaurant.distance}';
  }

  String get _statusText => dineInDisplayStatus(restaurant);

  Color get _statusColor {
    if (restaurant.status == DineInVenueStatus.closed) {
      return AppColors.error;
    }
    if (_statusText == 'Busy') return const Color(0xFFE65100);
    return AppColors.primary;
  }

  String get _prepTime => 'Prep time ~${12 + restaurant.tableMin * 4} min';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VendorThumb(
              imageUrl: restaurant.imageUrl,
              gradientStart: restaurant.gradientStart,
              gradientEnd: restaurant.gradientEnd,
            ),
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
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium(color: _textDark)
                              .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _ratingBadge(
                        restaurant.rating,
                        hasRating: restaurant.rating > 0,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _areaLine,
                    style: AppTextStyles.bodySmall(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 13.sp),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        _statusText,
                        style: AppTextStyles.labelSmall(color: _statusColor)
                            .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _prepTime,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 12.sp),
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

class FoodPickupListCard extends StatelessWidget {
  const FoodPickupListCard({
    super.key,
    required this.spot,
    this.onTap,
  });

  final PickupSpot spot;
  final VoidCallback? onTap;

  String get _areaLine => '${spot.categoryLabel} · ${spot.distance}';

  String get _readyLabel {
    final digits = RegExp(r'\d+').stringMatch(spot.pickupEta) ?? '15';
    return 'Ready in $digits min';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VendorThumb(
              imageUrl: null,
              gradientStart: spot.imageColor,
              gradientEnd: Color.lerp(spot.imageColor, Colors.white, 0.35) ??
                  spot.imageColor,
            ),
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
                          spot.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium(color: _textDark)
                              .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _ratingBadge(spot.rating),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _areaLine,
                    style: AppTextStyles.bodySmall(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 13.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _readyLabel,
                    style: AppTextStyles.labelSmall(
                      color: AppColors.primary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
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

Widget _ratingBadge(double rating, {bool compact = false, bool? hasRating}) {
  final show = hasRating ?? rating > 0;
  if (!show) return const SizedBox.shrink();
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
        style: AppTextStyles.labelSmall(color: _textDark).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: compact ? 11.sp : 13.sp,
        ),
      ),
    ],
  );
}

int pickupEtaMinutes(PickupSpot spot) {
  return int.tryParse(RegExp(r'\d+').stringMatch(spot.pickupEta) ?? '') ?? 99;
}

String dineInDisplayStatus(DineInRestaurant restaurant) {
  if (restaurant.status == DineInVenueStatus.closed) return 'Closed';
  final label = restaurant.statusLabel.toLowerCase();
  if (label.contains('busy')) return 'Busy';
  if (restaurant.badge == 'Bookable' ||
      restaurant.entryLabel.toLowerCase() == 'bookable') {
    return 'Busy';
  }
  if (label.contains('available') || label.contains('open')) {
    return 'Available now';
  }
  return restaurant.statusLabel;
}

bool dineInIsAvailableNow(DineInRestaurant restaurant) {
  if (restaurant.status == DineInVenueStatus.closed) return false;
  final status = dineInDisplayStatus(restaurant);
  return status == 'Available now';
}
