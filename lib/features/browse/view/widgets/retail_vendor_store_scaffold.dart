import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/fashion_vendor_store_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Shared vendor/store page chrome (Fashion · Electronics · Flowers · Vape · Services).
///
/// One layout: top bar · brand band · optional meta/banner · chips · list/grid accordion.
class RetailVendorStoreScaffold extends StatelessWidget {
  const RetailVendorStoreScaffold({
    super.key,
    required this.store,
    required this.chipGroups,
    required this.selectedChip,
    required this.expandedAccordion,
    required this.isGridView,
    required this.searchOpen,
    required this.loading,
    required this.query,
    required this.onBack,
    required this.onSearchToggle,
    required this.onQueryChanged,
    required this.onCancelSearch,
    required this.onRefresh,
    required this.onChipSelected,
    required this.onAccordionTap,
    required this.onGridChanged,
    required this.onOpenItem,
    required this.onAddItem,
    this.orderMeta,
    this.banner,
    this.bottomBar,
    this.addingItemId,
    this.searchHint = 'Search products…',
    this.emptyMessage = 'No items available right now',
    this.emptySearchMessage = 'No items found',
    this.bottomNavIndex = 0,
  });

  final ElectronicsStore store;
  final List<VendorMenuChipGroup> chipGroups;
  final String selectedChip;
  final String expandedAccordion;
  final bool isGridView;
  final bool searchOpen;
  final bool loading;
  final String query;
  final VoidCallback onBack;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onCancelSearch;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onChipSelected;
  final ValueChanged<String> onAccordionTap;
  final ValueChanged<bool> onGridChanged;
  final void Function(BrowseMenuItem item) onOpenItem;
  final void Function(BrowseMenuItem item) onAddItem;
  final Widget? orderMeta;
  final Widget? banner;
  final Widget? bottomBar;
  final String? addingItemId;
  final String searchHint;
  final String emptyMessage;
  final String emptySearchMessage;
  final int bottomNavIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: _RetailVendorStoreBody(scaffold: this),
          ),
          if (bottomBar != null) bottomBar!,
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
    );
  }
}

class _RetailVendorStoreBody extends StatefulWidget {
  const _RetailVendorStoreBody({required this.scaffold});

  final RetailVendorStoreScaffold scaffold;

  @override
  State<_RetailVendorStoreBody> createState() => _RetailVendorStoreBodyState();
}

class _RetailVendorStoreBodyState extends State<_RetailVendorStoreBody> {
  final ScrollController _scroll = ScrollController();
  double? _expandedHeaderHeight;

  RetailVendorStoreScaffold get s => widget.scaffold;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onExpandedHeaderSize(Size size) {
    if (size.height < 1) return;
    final current = _expandedHeaderHeight;
    if (current != null && (current - size.height).abs() < 0.5) return;
    setState(() => _expandedHeaderHeight = size.height);
  }

  double _filtersHeight() {
    if (s.chipGroups.isEmpty) return 0;
    final row = math.max(36.h, 28.w + 4.w);
    return 8.h + row + 4.h;
  }

  Future<void> _openMap() async {
    final lat = s.store.latitude;
    final lng = s.store.longitude;
    final uri = lat != null && lng != null
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(s.store.name)}',
          );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _expandedHeader() {
    return _MeasureSize(
      onChange: _onExpandedHeaderSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FashionVendorTopBar(
            searchOpen: s.searchOpen,
            onBack: s.onBack,
            onSearch: s.onSearchToggle,
          ),
          FashionVendorBrandBand(store: s.store),
          if (s.banner != null) s.banner!,
          if (s.orderMeta != null) s.orderMeta!,
          if (s.searchOpen)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
              child: BrowseSearchBar(
                hint: s.searchHint,
                value: s.query,
                autofocus: true,
                onChanged: s.onQueryChanged,
                showCancel: true,
                onCancel: s.onCancelSearch,
              ),
            ),
        ],
      ),
    );
  }

  Widget _pinnedFilters() {
    final labels = s.chipGroups.map((g) => g.label).toList(growable: false);
    return ColoredBox(
      color: AppColors.white,
      child: SizedBox(
        height: _filtersHeight(),
        child: Padding(
          padding: EdgeInsets.only(top: 8.h, right: 12.w, bottom: 4.h),
          child: Row(
            children: [
              Expanded(
                child: FashionVendorCategoryChips(
                  categories: labels,
                  selected: s.selectedChip,
                  onSelected: s.onChipSelected,
                ),
              ),
              FashionVendorViewToggle(
                isGridView: s.isGridView,
                docked: true,
                onChanged: s.onGridChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expanded = _expandedHeader();
    final collapsedHeight = RetailVendorCollapsedBar.contentHeight(context);
    final footerHeight = _filtersHeight();
    final expandedHeight = math.max(
      _expandedHeaderHeight ?? (collapsedHeight + 120.h),
      collapsedHeight,
    );
    final showFilters = s.chipGroups.isNotEmpty;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: s.onRefresh,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (_expandedHeaderHeight == null)
            SliverToBoxAdapter(child: expanded)
          else
            SliverPersistentHeader(
              pinned: true,
              delegate: _RetailCollapseDelegate(
                expanded: expanded,
                collapsed: RetailVendorCollapsedBar(
                  store: s.store,
                  onBack: s.onBack,
                  onPinTap: _openMap,
                ),
                pinnedFooter:
                    showFilters ? _pinnedFilters() : const SizedBox.shrink(),
                expandedBodyHeight: expandedHeight,
                collapsedBodyHeight: collapsedHeight,
                footerHeight: footerHeight,
              ),
            ),
          if (_expandedHeaderHeight == null && showFilters)
            SliverToBoxAdapter(child: _pinnedFilters()),
          if (s.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (s.chipGroups.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  s.query.trim().isEmpty ? s.emptyMessage : s.emptySearchMessage,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate(
                buildRetailVendorAccordionChildren(
                  chipGroups: s.chipGroups,
                  expandedAccordion: s.expandedAccordion,
                  isGridView: s.isGridView,
                  addingItemId: s.addingItemId,
                  onAccordionTap: s.onAccordionTap,
                  onOpenItem: s.onOpenItem,
                  onAddItem: s.onAddItem,
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}

class _RetailCollapseDelegate extends SliverPersistentHeaderDelegate {
  _RetailCollapseDelegate({
    required this.expanded,
    required this.collapsed,
    required this.pinnedFooter,
    required this.expandedBodyHeight,
    required this.collapsedBodyHeight,
    required this.footerHeight,
  });

  final Widget expanded;
  final Widget collapsed;
  final Widget pinnedFooter;
  final double expandedBodyHeight;
  final double collapsedBodyHeight;
  final double footerHeight;

  @override
  double get maxExtent => expandedBodyHeight + footerHeight;

  @override
  double get minExtent => collapsedBodyHeight + footerHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final bodyHeight = expandedBodyHeight - shrinkOffset;
    final visibleBody =
        bodyHeight < collapsedBodyHeight ? collapsedBodyHeight : bodyHeight;
    final showCollapsed = t >= 0.92;

    return ColoredBox(
      color: AppColors.white,
      child: Column(
        children: [
          SizedBox(
            height: visibleBody,
            child: ClipRect(
              child: showCollapsed
                  ? collapsed
                  : OverflowBox(
                      alignment: Alignment.bottomCenter,
                      minHeight: expandedBodyHeight,
                      maxHeight: expandedBodyHeight,
                      child: expanded,
                    ),
            ),
          ),
          if (footerHeight > 0) SizedBox(height: footerHeight, child: pinnedFooter),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _RetailCollapseDelegate oldDelegate) {
    return expandedBodyHeight != oldDelegate.expandedBodyHeight ||
        collapsedBodyHeight != oldDelegate.collapsedBodyHeight ||
        footerHeight != oldDelegate.footerHeight ||
        expanded != oldDelegate.expanded ||
        collapsed != oldDelegate.collapsed ||
        pinnedFooter != oldDelegate.pinnedFooter;
  }
}

class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  Size? _old;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final size = box.size;
      if (_old == size) return;
      _old = size;
      widget.onChange(size);
    });
    return widget.child;
  }
}

/// Accordion children shared by all retail/service vendor pages.
List<Widget> buildRetailVendorAccordionChildren({
  required List<VendorMenuChipGroup> chipGroups,
  required String expandedAccordion,
  required bool isGridView,
  required ValueChanged<String> onAccordionTap,
  required void Function(BrowseMenuItem item) onOpenItem,
  required void Function(BrowseMenuItem item) onAddItem,
  String? addingItemId,
}) {
  final children = <Widget>[];

  for (final chip in chipGroups) {
    final accordion =
        chip.accordions.isNotEmpty ? chip.accordions.first : null;
    if (accordion == null) continue;

    final expanded = accordion.title == expandedAccordion;
    children.add(
      FashionVendorAccordionHeader(
        title: accordion.title,
        expanded: expanded,
        onTap: () => onAccordionTap(accordion.title),
      ),
    );
    if (!expanded) continue;

    if (accordion.allItems.isEmpty) {
      children.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: Text(
            'No items in this category',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
        ),
      );
      continue;
    }

    for (final group in accordion.groups) {
      final label = group.label?.trim();
      if (label != null && label.isNotEmpty) {
        children.add(FashionVendorSubgroupLabel(label: label));
      }

      if (isGridView) {
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final item = group.items[index];
                return FashionVendorProductGridTile(
                  item: item,
                  isAdding: addingItemId == item.id,
                  onTap: () => onOpenItem(item),
                  onAdd: () => onAddItem(item),
                );
              },
            ),
          ),
        );
      } else {
        for (final item in group.items) {
          children.add(
            FashionVendorProductListTile(
              item: item,
              isAdding: addingItemId == item.id,
              onTap: () => onOpenItem(item),
              onAdd: () => onAddItem(item),
            ),
          );
        }
      }
    }
  }

  return children;
}

/// Shared back + title header for category landing screens.
class BrowseBackTitleHeader extends StatelessWidget {
  const BrowseBackTitleHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.all(8.w),
              constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.w),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium(
                  color: AppColors.textPrimary,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
