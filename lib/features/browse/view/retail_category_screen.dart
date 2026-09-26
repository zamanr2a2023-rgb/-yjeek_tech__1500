import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/retail_vendor_store_scaffold.dart';
import 'package:yjeek_app/features/home/model/categories_repository.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Fashion / Flowers: Admin sub-categories first, then vendors.
/// List/Grid share data; preferred view is remembered; search hits both.
class RetailCategoryScreen extends ConsumerStatefulWidget {
  const RetailCategoryScreen({
    super.key,
    required this.slug,
    this.bottomNavIndex = 0,
  });

  final String slug;
  final int bottomNavIndex;

  @override
  ConsumerState<RetailCategoryScreen> createState() =>
      _RetailCategoryScreenState();
}

class _RetailCategoryScreenState extends ConsumerState<RetailCategoryScreen> {
  late bool _isGridView;
  bool _loading = true;
  String _query = '';
  String _title = '';
  List<RetailCategoryTile> _allSubs = const [];
  List<RetailCategoryTile> _allVendors = const [];
  List<RetailCategoryTile> _visibleSubs = const [];
  List<RetailCategoryTile> _visibleVendors = const [];
  Timer? _debounce;

  bool get _isSearching => _query.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _title = ElectronicsData.titleForCategory(widget.slug);
    _isGridView =
        ref.read(storageServiceProvider).retailCategoryGridView;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _setGridView(bool isGrid) async {
    setState(() => _isGridView = isGrid);
    await ref.read(storageServiceProvider).setRetailCategoryGridView(isGrid);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final detail = await ref
          .read(categoriesRepositoryProvider)
          .fetchRetailCategory(widget.slug);

      final tiles = detail?.tiles ?? const <RetailCategoryTile>[];
      final subs = tiles
          .where((t) => t.kind == RetailTileKind.subcategory)
          .toList(growable: false);

      // Always also load vendors for search (and fallback when no subs).
      var vendors = tiles
          .where((t) => t.kind == RetailTileKind.vendor)
          .toList(growable: false);
      if (vendors.isEmpty) {
        final stores = await ref
            .read(electronicsVendorsRepositoryProvider)
            .fetchStores(category: widget.slug, query: null);
        vendors = [
          for (final s in stores)
            RetailCategoryTile(
              id: s.id,
              name: s.name,
              kind: RetailTileKind.vendor,
            ),
        ];
      }

      if (!mounted) return;
      setState(() {
        _title = detail?.name ?? ElectronicsData.titleForCategory(widget.slug);
        _allSubs = subs;
        _allVendors = vendors;
        _applyFilter();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allSubs = const [];
        _allVendors = const [];
        _visibleSubs = const [];
        _visibleVendors = const [];
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      // Landing: sub-categories first (admin-managed). Vendors only if no subs.
      _visibleSubs = _allSubs;
      _visibleVendors = _allSubs.isEmpty ? _allVendors : const [];
      return;
    }
    // Search hits both sub-categories and vendors.
    _visibleSubs = _allSubs
        .where((t) => t.name.toLowerCase().contains(q))
        .toList(growable: false);
    _visibleVendors = _allVendors
        .where((t) => t.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _applyFilter();
    });
    // Debounced remote vendor search while typing.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!_isSearching) return;
      try {
        final stores = await ref
            .read(electronicsVendorsRepositoryProvider)
            .fetchStores(category: widget.slug, query: _query);
        if (!mounted) return;
        setState(() {
          _allVendors = [
            for (final s in stores)
              RetailCategoryTile(
                id: s.id,
                name: s.name,
                kind: RetailTileKind.vendor,
              ),
          ];
          _applyFilter();
        });
      } catch (_) {}
    });
  }

  void _onTileTap(RetailCategoryTile tile) {
    if (tile.kind == RetailTileKind.vendor) {
      context.push(BrowseRoutes.electronicsStore(storeId: tile.id));
      return;
    }
    // Sub-category → vendor list for this store type + subcategory.
    context.push(
      BrowseRoutes.electronicsBrowse(
        category: widget.slug,
        subcategory: tile.slug ?? tile.id,
        title: tile.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empty = !_loading &&
        _visibleSubs.isEmpty &&
        _visibleVendors.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrowseBackTitleHeader(
            title: _title,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 8.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SearchField(
                    hint: 'Search categories & vendors…',
                    onChanged: _onQueryChanged,
                  ),
                ),
                SizedBox(width: 5.w),
                _ViewToggle(
                  isGridView: _isGridView,
                  onChanged: _setGridView,
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : empty
                    ? _EmptyState(
                        title: _title,
                        searching: _isSearching,
                      )
                    : _isGridView
                        ? _buildGrid()
                        : _buildList(),
          ),
        ],
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _buildGrid() {
    final sections = <Widget>[];
    if (_visibleSubs.isNotEmpty) {
      if (_isSearching || _visibleVendors.isNotEmpty) {
        sections.add(_SectionLabel(label: 'Categories'));
      }
      sections.add(
        _CategoryGrid(
          tiles: _visibleSubs,
          categorySlug: widget.slug,
          onTap: _onTileTap,
        ),
      );
    }
    if (_visibleVendors.isNotEmpty) {
      if (_visibleSubs.isNotEmpty) {
        sections.add(_SectionLabel(label: 'Vendors'));
      }
      sections.add(
        _CategoryGrid(
          tiles: _visibleVendors,
          categorySlug: widget.slug,
          onTap: _onTileTap,
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      children: sections,
    );
  }

  Widget _buildList() {
    final rows = <Widget>[];
    if (_visibleSubs.isNotEmpty) {
      if (_isSearching || _visibleVendors.isNotEmpty) {
        rows.add(_SectionLabel(label: 'Categories'));
      }
      for (var i = 0; i < _visibleSubs.length; i++) {
        rows.add(
          _CategoryListRow(
            tile: _visibleSubs[i],
            categorySlug: widget.slug,
            onTap: () => _onTileTap(_visibleSubs[i]),
            showDivider: i < _visibleSubs.length - 1,
          ),
        );
      }
    }
    if (_visibleVendors.isNotEmpty) {
      if (_visibleSubs.isNotEmpty) {
        rows.add(_SectionLabel(label: 'Vendors'));
      }
      for (var i = 0; i < _visibleVendors.length; i++) {
        rows.add(
          _CategoryListRow(
            tile: _visibleVendors[i],
            categorySlug: widget.slug,
            onTap: () => _onTileTap(_visibleVendors[i]),
            showDivider: i < _visibleVendors.length - 1,
          ),
        );
      }
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      children: rows,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 10.h),
      child: Text(
        label,
        style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.searching});

  final String title;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.category_outlined,
                size: 34.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              searching ? 'No results found' : 'No categories yet',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall(color: AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 16.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              searching
                  ? 'Try a different search for $title.'
                  : 'Sub-categories are managed in Admin → Store Type.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)
                  .copyWith(fontSize: 13.sp, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
            .copyWith(fontSize: 14.sp),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium(color: const Color(0xFF6B6B6B))
              .copyWith(fontSize: 14.sp),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.isGridView,
    required this.onChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.h, right: 12.w),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.grid_view_rounded,
            active: isGridView,
            onTap: () => onChanged(true),
          ),
          _ToggleBtn(
            icon: Icons.view_list_rounded,
            active: !isGridView,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
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

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.tiles,
    required this.onTap,
    required this.categorySlug,
  });

  final List<RetailCategoryTile> tiles;
  final ValueChanged<RetailCategoryTile> onTap;
  final String categorySlug;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return GestureDetector(
          onTap: () => onTap(tile),
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
                    child: _CategoryThumb(
                      tile: tile,
                      categorySlug: categorySlug,
                      iconSize: 40.sp,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  child: Text(
                    tile.name,
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

class _CategoryListRow extends StatelessWidget {
  const _CategoryListRow({
    required this.tile,
    required this.onTap,
    required this.categorySlug,
    this.showDivider = true,
  });

  final RetailCategoryTile tile;
  final VoidCallback onTap;
  final String categorySlug;
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
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: _CategoryThumb(
                    tile: tile,
                    categorySlug: categorySlug,
                    iconSize: 26.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    tile.name,
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

/// Thumbnail: API image → category placeholder photo → distinct icon.
class _CategoryThumb extends StatelessWidget {
  const _CategoryThumb({
    required this.tile,
    required this.categorySlug,
    required this.iconSize,
  });

  final RetailCategoryTile tile;
  final String categorySlug;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final apiUrl = tile.imageUrl?.trim();
    final placeholder = tile.kind == RetailTileKind.subcategory
        ? retailSubcategoryPlaceholderImage(categorySlug, tile.name)
        : null;
    final url = (apiUrl != null && apiUrl.isNotEmpty) ? apiUrl : placeholder;

    if (url != null && url.isNotEmpty) {
      return AppNetworkImage(
        url: url,
        fit: BoxFit.cover,
        errorWidget: _iconFallback(),
      );
    }
    return _iconFallback();
  }

  Widget _iconFallback() {
    final visual = _retailSubcategoryVisual(categorySlug, tile.name);
    return ColoredBox(
      color: visual.background,
      child: Center(
        child: Icon(
          tile.kind == RetailTileKind.vendor
              ? Icons.storefront_outlined
              : visual.icon,
          size: iconSize,
          color: visual.foreground,
        ),
      ),
    );
  }
}

class _SubcatVisual {
  const _SubcatVisual({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

/// Distinct icon + tint per subcategory (Fashion ≠ Flowers).
_SubcatVisual _retailSubcategoryVisual(String categorySlug, String tileName) {
  final slug = categorySlug.toLowerCase();
  final name = tileName.toLowerCase();

  if (slug == 'fashion' || slug.contains('cloth')) {
    // Check women BEFORE men — "women's".contains("men") is true.
    if (name.contains('women') || name.contains('lady') || name.contains('girl')) {
      return const _SubcatVisual(
        icon: Icons.woman_rounded,
        background: Color(0xFFFCE4EC),
        foreground: Color(0xFFC2185B),
      );
    }
    if (name.contains('men') || name.contains('boy')) {
      return const _SubcatVisual(
        icon: Icons.man_rounded,
        background: Color(0xFFE3F2FD),
        foreground: Color(0xFF1565C0),
      );
    }
    if (name.contains('kid') || name.contains('child') || name.contains('baby')) {
      return const _SubcatVisual(
        icon: Icons.child_care_rounded,
        background: Color(0xFFFFF3E0),
        foreground: Color(0xFFEF6C00),
      );
    }
    if (name.contains('shoe') || name.contains('sneaker') || name.contains('boot')) {
      return const _SubcatVisual(
        icon: Icons.shopping_bag_rounded,
        background: Color(0xFFEFEBE9),
        foreground: Color(0xFF5D4037),
      );
    }
    if (name.contains('accessor') ||
        name.contains('watch') ||
        name.contains('bag')) {
      return const _SubcatVisual(
        icon: Icons.watch_rounded,
        background: Color(0xFFF3E5F5),
        foreground: Color(0xFF7B1FA2),
      );
    }
    return const _SubcatVisual(
      icon: Icons.checkroom_rounded,
      background: Color(0xFFE8F5E9),
      foreground: Color(0xFF2E7D32),
    );
  }

  if (slug == 'flowers' || slug.contains('florist')) {
    return const _SubcatVisual(
      icon: Icons.local_florist_rounded,
      background: Color(0xFFFCE4EC),
      foreground: Color(0xFFC2185B),
    );
  }

  if (slug == 'pharmacy') {
    return const _SubcatVisual(
      icon: Icons.local_pharmacy_rounded,
      background: Color(0xFFE3F2FD),
      foreground: Color(0xFF1565C0),
    );
  }

  if (slug == 'gifts' || slug.contains('gift')) {
    return const _SubcatVisual(
      icon: Icons.card_giftcard_rounded,
      background: Color(0xFFFFF3E0),
      foreground: Color(0xFFEF6C00),
    );
  }

  return const _SubcatVisual(
    icon: Icons.category_rounded,
    background: Color(0xFFE8F5E9),
    foreground: Color(0xFF2E7D32),
  );
}

/// Stable demo photos when Admin has not set subcategory images.
String? retailSubcategoryPlaceholderImage(String categorySlug, String tileName) {
  final slug = categorySlug.toLowerCase();
  final name = tileName.toLowerCase();

  if (slug == 'fashion' || slug.contains('cloth')) {
    if (name.contains('women') || name.contains('lady') || name.contains('girl')) {
      return 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=600&q=80';
    }
    if (name.contains('men') || name.contains('boy')) {
      return 'https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?auto=format&fit=crop&w=600&q=80';
    }
    if (name.contains('kid') || name.contains('child') || name.contains('baby')) {
      return 'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=600&q=80';
    }
    if (name.contains('shoe') || name.contains('sneaker') || name.contains('boot')) {
      return 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=600&q=80';
    }
    if (name.contains('accessor') ||
        name.contains('watch') ||
        name.contains('bag')) {
      return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80';
    }
  }

  if (slug == 'flowers' || slug.contains('florist')) {
    if (name.contains('bouquet')) {
      return 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=600&q=80';
    }
    if (name.contains('rose')) {
      return 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80';
    }
    if (name.contains('plant')) {
      return 'https://images.unsplash.com/photo-1463320726281-696a485928c7?auto=format&fit=crop&w=600&q=80';
    }
    return 'https://images.unsplash.com/photo-1487530811176-3780de880c2d?auto=format&fit=crop&w=600&q=80';
  }

  if (slug == 'pharmacy') {
    return 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=600&q=80';
  }

  return null;
}

/// Icon for retail subcategory tiles (Fashion ≠ Flowers).
IconData retailSubcategoryIcon(String categorySlug, String tileName) {
  return _retailSubcategoryVisual(categorySlug, tileName).icon;
}
