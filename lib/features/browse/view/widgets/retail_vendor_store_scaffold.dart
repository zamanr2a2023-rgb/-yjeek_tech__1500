import 'package:flutter/material.dart';
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
    final categoryLabels =
        chipGroups.map((g) => g.label).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          FashionVendorTopBar(
            searchOpen: searchOpen,
            onBack: onBack,
            onSearch: onSearchToggle,
          ),
          FashionVendorBrandBand(store: store),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: onRefresh,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (banner != null) banner!,
                              if (orderMeta != null) orderMeta!,
                              if (searchOpen)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    16.w,
                                    8.h,
                                    16.w,
                                    4.h,
                                  ),
                                  child: BrowseSearchBar(
                                    hint: searchHint,
                                    value: query,
                                    autofocus: true,
                                    onChanged: onQueryChanged,
                                    showCancel: true,
                                    onCancel: onCancelSearch,
                                  ),
                                ),
                              SizedBox(height: 8.h),
                              FashionVendorCategoryChips(
                                categories: categoryLabels,
                                selected: selectedChip,
                                onSelected: onChipSelected,
                              ),
                              FashionVendorViewToggle(
                                isGridView: isGridView,
                                onChanged: onGridChanged,
                              ),
                            ],
                          ),
                        ),
                        if (chipGroups.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                query.trim().isEmpty
                                    ? emptyMessage
                                    : emptySearchMessage,
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
                                chipGroups: chipGroups,
                                expandedAccordion: expandedAccordion,
                                isGridView: isGridView,
                                addingItemId: addingItemId,
                                onAccordionTap: onAccordionTap,
                                onOpenItem: onOpenItem,
                                onAddItem: onAddItem,
                              ),
                            ),
                          ),
                        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                      ],
                    ),
                  ),
          ),
          if (bottomBar != null) bottomBar!,
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
    );
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
