import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/browse_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/food_category_widgets.dart';
import 'package:yjeek_app/l10n/l10n.dart';

const _mintCover = Color(0xFFE8F5E9);
const _textDark = Color(0xFF1A1A1A);
const _textMuted = Color(0xFF6B6B6B);
const _divider = Color(0xFFE2E2E2);
const _starGold = Color(0xFFC9A84C);

/// Fixed sliver header heights — keep in sync with [VendorMenuCoverHeader] et al.
abstract final class VendorMenuLayout {
  static double expandedBodyHeight(
    BuildContext context, {
    required bool searchVisible,
  }) {
    final pillText = 12.sp * 1.35;
    final orderTabsRow = 10.h + 7.h + 7.h + pillText;
    final statBlock = 13.sp * 1.25 + 3.h + 10.sp * 1.25;
    final statsRow = 10.h + 10.h + math.max(28.h, statBlock);
    final nameLine = 15.sp * 1.25;
    final subtitleLine = 11.sp * 1.25;
    final identityRow = math.max(48.w, nameLine + 2.h + subtitleLine);
    var height = 116.h + (12.h + identityRow) + orderTabsRow + statsRow + 1;
    if (searchVisible) {
      height += 8.h + 10.h + 10.h + 22.sp + 8.h;
    }
    return height + 6.h;
  }

  static double pinnedFiltersHeight(BuildContext context) {
    final toggleRow = 10.h + 27.h + 6.w;
    return 4.h + 40.h + toggleRow + 6.h + 4.h;
  }
}

/// Soft mint cover with back/search controls (MENU OPTION E).
class VendorMenuCoverHeader extends StatelessWidget {
  const VendorMenuCoverHeader({
    super.key,
    required this.restaurant,
    required this.onBack,
    required this.onSearchTap,
    this.showSearchField = false,
    this.searchController,
    this.onSearchChanged,
    this.onSearchClose,
    this.searchHint,
  });

  final BrowseRestaurant restaurant;
  final VoidCallback onBack;
  final VoidCallback onSearchTap;
  final bool showSearchField;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClose;
  final String? searchHint;

  @override
  Widget build(BuildContext context) {
    final coverUrl = restaurant.displayCoverUrl?.trim();
    final hasCover = coverUrl != null && coverUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 116.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasCover)
                AppNetworkImage(
                  url: coverUrl,
                  fit: BoxFit.cover,
                  errorWidget: const ColoredBox(color: _mintCover),
                )
              else
                const ColoredBox(color: _mintCover),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleIconButton(
                          onTap: onBack,
                          background: _mintCover,
                          borderColor: AppColors.white,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16.sp,
                            color: _textDark,
                          ),
                        ),
                        _CircleIconButton(
                          onTap: onSearchTap,
                          background: AppColors.white,
                          borderColor: const Color(0xFFE2E2E2),
                          child: Icon(
                            Icons.search_rounded,
                            size: 18.sp,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showSearchField)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: searchHint ?? BrowseStrings.searchThisMenu,
                      hintStyle: AppTextStyles.bodySmall(color: _textMuted),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: _divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: _divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: AppTextStyles.bodyMedium(color: _textDark),
                  ),
                ),
                if (onSearchClose != null) ...[
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: onSearchClose,
                    icon: Icon(Icons.close_rounded, size: 22.sp),
                    color: _textMuted,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.onTap,
    required this.background,
    required this.borderColor,
    required this.child,
  });

  final VoidCallback onTap;
  final Color background;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final visual = 30.w;
    final hit = math.max(visual, 44.w);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: hit,
          height: hit,
          child: Center(
            child: Container(
              width: visual,
              height: visual,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Green identity band: logo, name, cuisine · area, rating (only if real reviews).
class VendorMenuIdentityBar extends StatelessWidget {
  const VendorMenuIdentityBar({super.key, required this.restaurant});

  final BrowseRestaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final area = restaurant.area?.trim();
    final cuisine = restaurant.cuisine.trim();
    final cuisineLooksLikeArea = area != null &&
        cuisine.isNotEmpty &&
        cuisine.toLowerCase() == area.toLowerCase();
    final subtitleParts = <String>[
      if (cuisine.isNotEmpty && !cuisineLooksLikeArea) cuisine,
      if (area != null && area.isNotEmpty) area,
    ];
    final subtitle =
        subtitleParts.isEmpty ? 'Food' : subtitleParts.join(' - ');
    final logoUrl = restaurant.displayLogoUrl?.trim();

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: _mintCover,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.primary),
            ),
            clipBehavior: Clip.antiAlias,
            child: logoUrl != null && logoUrl.isNotEmpty
                ? AppNetworkImage(
                    url: logoUrl,
                    width: 48.w,
                    height: 48.w,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10.r),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium(color: AppColors.white)
                      .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: AppColors.white)
                      .copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          if (restaurant.hasRating)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '★',
                  style: TextStyle(
                    color: _starGold,
                    fontSize: 13.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  restaurant.rating.toStringAsFixed(1),
                  style: AppTextStyles.labelSmall(color: AppColors.white)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Compact green bar shown once the vendor header has scrolled away.
class VendorMenuCollapsedBar extends StatelessWidget {
  const VendorMenuCollapsedBar({
    super.key,
    required this.restaurant,
    required this.onBack,
    this.onPinTap,
  });

  final BrowseRestaurant restaurant;
  final VoidCallback onBack;
  final VoidCallback? onPinTap;

  static double contentHeight(BuildContext context) {
    return MediaQuery.paddingOf(context).top + 6.h + 30.w + 8.h;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: SizedBox(
          height: 6.h + 30.w + 8.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 8.h),
            child: Row(
              children: [
                _CircleIconButton(
                  onTap: onBack,
                  background: AppColors.white,
                  borderColor: AppColors.white,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16.sp,
                    color: _textDark,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium(color: AppColors.white)
                        .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                if (restaurant.hasRating) ...[
                  Text(
                    '★',
                    style: TextStyle(
                      color: _starGold,
                      fontSize: 13.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    restaurant.rating.toStringAsFixed(1),
                    style: AppTextStyles.labelSmall(color: AppColors.white)
                        .copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                _CircleIconButton(
                  onTap: onPinTap ?? () {},
                  background: AppColors.white,
                  borderColor: AppColors.white,
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 16.sp,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-style order type row (Figma MENU OPTION E).
class VendorMenuOrderTypeTabs extends StatelessWidget {
  const VendorMenuOrderTypeTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabledTypes,
  });

  final FoodOrderType selected;
  final ValueChanged<FoodOrderType> onChanged;
  final Set<FoodOrderType>? enabledTypes;

  @override
  Widget build(BuildContext context) {
    final enabled = enabledTypes ??
        const {
          FoodOrderType.delivery,
          FoodOrderType.dineIn,
          FoodOrderType.pickup,
        };
    final pills = <(String, FoodOrderType)>[
      if (enabled.contains(FoodOrderType.delivery))
        ('Delivery', FoodOrderType.delivery),
      if (enabled.contains(FoodOrderType.dineIn))
        ('Dine-in', FoodOrderType.dineIn),
      if (enabled.contains(FoodOrderType.pickup))
        ('Pickup', FoodOrderType.pickup),
    ];
    if (pills.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Row(
        children: [
          for (var i = 0; i < pills.length; i++) ...[
            if (i > 0) SizedBox(width: 4.w),
            _pill(pills[i].$1, pills[i].$2),
          ],
        ],
      ),
    );
  }

  Widget _pill(String label, FoodOrderType type) {
    final active = selected == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: active ? AppColors.white : _textMuted,
          ).copyWith(
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}

class VendorMenuStatsRow extends StatelessWidget {
  const VendorMenuStatsRow({
    super.key,
    required this.restaurant,
    required this.orderType,
  });

  final BrowseRestaurant restaurant;
  final FoodOrderType orderType;

  @override
  Widget build(BuildContext context) {
    final stats = _statsForOrderType();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) _verticalDivider(),
            Expanded(
              child: _stat(stats[i].$1, stats[i].$2),
            ),
          ],
        ],
      ),
    );
  }

  List<(String, String)> _statsForOrderType() {
    final minOrder = 'BHD ${restaurant.minOrder}';
    switch (orderType) {
      case FoodOrderType.delivery:
        final arrives = restaurant.arrivesInMin ?? restaurant.deliveryMin;
        return [
          ('$arrives min', 'Arrives in'),
          ('BHD ${restaurant.deliveryFee}', 'Delivery fee'),
          (minOrder, 'Min order'),
        ];
      case FoodOrderType.pickup:
        final ready = restaurant.readyInMin ??
            restaurant.prepTimeMin ??
            restaurant.deliveryMin;
        return [
          ('$ready min', 'Ready in'),
          (restaurant.distance, 'Distance'),
          (minOrder, 'Min order'),
        ];
      case FoodOrderType.dineIn:
        final available = restaurant.dineInAvailableLabel?.trim();
        final ready = restaurant.readyInMin ??
            restaurant.prepTimeMin ??
            restaurant.deliveryMin;
        return [
          (
            available != null && available.isNotEmpty
                ? (restaurant.dineInTablesAvailable != null
                    ? '${restaurant.dineInTablesAvailable} free'
                    : 'Available')
                : '$ready min',
            available != null && available.isNotEmpty
                ? 'Tables now'
                : 'Ready in',
          ),
          (restaurant.distance, 'Distance'),
          (minOrder, 'Min order'),
        ];
    }
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 28.h,
      color: _divider,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall(color: _textDark).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: _textMuted)
              .copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }
}

class VendorMenuCategoryChips extends StatefulWidget {
  const VendorMenuCategoryChips({
    super.key,
    required this.sections,
    required this.selected,
    required this.onSelected,
  });

  final List<String> sections;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<VendorMenuCategoryChips> createState() => _VendorMenuCategoryChipsState();
}

class _VendorMenuCategoryChipsState extends State<VendorMenuCategoryChips> {
  final _scroll = ScrollController();
  bool _showMoreHint = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncHint());
  }

  @override
  void didUpdateWidget(covariant VendorMenuCategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncHint());
  }

  void _syncHint() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final show = max > 4 && _scroll.offset < max - 4;
    if (show != _showMoreHint) setState(() => _showMoreHint = show);
  }

  @override
  void dispose() {
    _scroll.removeListener(_syncHint);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: widget.sections.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final section = widget.sections[index];
              final active = section == widget.selected;
              return GestureDetector(
                onTap: () => widget.onSelected(section),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: active ? AppColors.primary : _divider,
                    ),
                  ),
                  child: Text(
                    L10n.tr(section),
                    style: AppTextStyles.labelSmall(
                      color: active ? AppColors.white : _textDark,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                  ),
                ),
              );
            },
          ),
          if (_showMoreHint)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 40.w,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 0),
                        AppColors.white,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: _textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VendorMenuViewToggleRow extends StatelessWidget {
  const VendorMenuViewToggleRow({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
    this.docked = false,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;

  /// Sits on the category-chip row (MENU OPTION E) instead of its own line.
  final bool docked;

  @override
  Widget build(BuildContext context) {
    final toggle = Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewToggleBtn(
            icon: Icons.grid_view_rounded,
            active: isGridView,
            onTap: () => onViewChanged(true),
          ),
          _ViewToggleBtn(
            icon: Icons.view_list_rounded,
            active: !isGridView,
            onTap: () => onViewChanged(false),
          ),
        ],
      ),
    );
    if (docked) return toggle;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Row(
        children: [
          const Spacer(),
          toggle,
        ],
      ),
    );
  }
}

class _ViewToggleBtn extends StatelessWidget {
  const _ViewToggleBtn({
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
        height: 27.h,
        decoration: BoxDecoration(
          color: active ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 14.sp,
          color: active ? _textDark : _textMuted,
        ),
      ),
    );
  }
}

class VendorMenuSectionHeader extends StatelessWidget {
  const VendorMenuSectionHeader({
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, expanded ? 4.h : 10.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                L10n.tr(title),
                style: AppTextStyles.labelMedium(color: _textDark).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.chevron_right_rounded,
              size: 22.sp,
              color: _textDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// Subgroup label inside an expanded accordion (COMBOS / SINGLE).
class VendorMenuSubgroupLabel extends StatelessWidget {
  const VendorMenuSubgroupLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 6.h),
      child: Text(
        L10n.tr(label),
        style: AppTextStyles.caption(color: _textMuted).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class VendorMenuItemRow extends StatelessWidget {
  const VendorMenuItemRow({
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
    final imageSize = 68.w;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: _mintCover,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _itemImage(item, imageSize) ??
                        const SizedBox.shrink(),
                  ),
                  Positioned(
                    right: -2.w,
                    bottom: -2.h,
                    child: _AddButton(
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
                    style: AppTextStyles.labelMedium(color: _textDark)
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.localizedDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: _textMuted)
                        .copyWith(fontSize: 12.sp, height: 1.35),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        'BHD ${item.price}',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp),
                      ),
                      if (item.onPromotion &&
                          item.strikeThroughPrice != null) ...[
                        SizedBox(width: 6.w),
                        Text(
                          'BHD ${item.strikeThroughPrice}',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.textSecondary,
                          ).copyWith(decoration: TextDecoration.lineThrough),
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

  Widget? _itemImage(BrowseMenuItem item, double size) {
    final url = item.imageUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return AppNetworkImage(
      url: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12.r),
    );
  }
}

class VendorMenuGridItem extends StatelessWidget {
  const VendorMenuGridItem({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: _mintCover,
                    child: _gridImage(),
                  ),
                  Positioned(
                    right: 8.w,
                    bottom: 8.h,
                    child: _AddButton(
                      hasModifiers: item.hasModifiers,
                      isAdding: isAdding,
                      onTap: onAdd ?? onTap,
                      size: 28.w,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.localizedName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall(color: _textDark)
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'BHD ${item.price}',
                    style: AppTextStyles.labelSmall(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _gridImage() {
    final url = item.imageUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return AppNetworkImage(url: url, fit: BoxFit.cover);
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.hasModifiers,
    required this.isAdding,
    this.onTap,
    this.size,
  });

  final bool hasModifiers;
  final bool isAdding;
  final VoidCallback? onTap;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 26.w;
    return GestureDetector(
      onTap: isAdding ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: isAdding
            ? SizedBox(
                width: buttonSize * 0.55,
                height: buttonSize * 0.55,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Icon(
                hasModifiers
                    ? Icons.chevron_right_rounded
                    : Icons.add_rounded,
                size: buttonSize * 0.65,
                color: AppColors.white,
              ),
      ),
    );
  }
}
