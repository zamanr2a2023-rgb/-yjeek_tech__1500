import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/pickup_data.dart';
import 'package:yjeek_app/features/browse/model/pickup_vendors_repository.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/pickup_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class PickupCategoriesScreen extends ConsumerStatefulWidget {
  const PickupCategoriesScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<PickupCategoriesScreen> createState() =>
      _PickupCategoriesScreenState();
}

class _PickupCategoriesScreenState
    extends ConsumerState<PickupCategoriesScreen> {
  bool _isGridView = true;
  bool _loading = true;
  String _query = '';
  List<PickupCategory> _categories = const [];
  PickupSpotlight? _spotlight;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(pickupVendorsRepositoryProvider);
      final categories = await repo.fetchAllPickupCategories();
      final spotlight = await repo.fetchSpotlight();
      final filtered = _query.trim().isEmpty
          ? categories
          : categories
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_query.trim().toLowerCase()),
              )
              .toList();
      if (!mounted) return;
      setState(() {
        _categories = filtered;
        _spotlight = spotlight;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = const [];
        _spotlight = null;
        _loading = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _load);
  }

  void _openCategory(PickupCategory category) {
    context.push(BrowseRoutes.pickupBrowse(category: category.id));
  }

  void _openSpotlight() {
    final vendorId = _spotlight?.vendorId;
    if (vendorId != null && vendorId.isNotEmpty) {
      context.push(BrowseRoutes.vendorMenu(vendorId: vendorId));
      return;
    }
    context.push(BrowseRoutes.pickupBrowse());
  }

  @override
  Widget build(BuildContext context) {
    // Figma PK6: light bg · search 44 · grid/list toggle · 4-col tiles · spotlight.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrowseTopBar(
            title: PickupData.homeTitle,
            onCart: () => context.goHome(tab: 2),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 24.h),
                    children: [
                      BrowseSearchBar(
                        hint: PickupData.searchHint,
                        value: _query,
                        autofocus: false,
                        onChanged: _onQueryChanged,
                      ),
                      SizedBox(height: 14.h),
                      PickupCategoriesToolbar(
                        isGridView: _isGridView,
                        onViewChanged: (value) =>
                            setState(() => _isGridView = value),
                      ),
                      SizedBox(height: 14.h),
                      if (_isGridView)
                        PickupCategoryGrid(
                          categories: _categories,
                          onCategoryTap: _openCategory,
                        )
                      else
                        PickupCategoryList(
                          categories: _categories,
                          onCategoryTap: _openCategory,
                        ),
                      SizedBox(height: 16.h),
                      PickupSpotlightBanner(
                        vendorTitle: _spotlight?.title,
                        ctaLabel: _spotlight?.ctaLabel,
                        onOrderNow: _openSpotlight,
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
