import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/retail_vendor_store_scaffold.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Services landing — sub-categories only (services.md Figma).
/// Grid / list → tap opens provider list (booking mode, no cart/delivery).
class ServicesBrowseScreen extends ConsumerStatefulWidget {
  const ServicesBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<ServicesBrowseScreen> createState() =>
      _ServicesBrowseScreenState();
}

class _ServicesBrowseScreenState extends ConsumerState<ServicesBrowseScreen> {
  late bool _isGridView;
  bool _loading = true;
  String _query = '';
  List<ServiceCategoryItem> _all = const [];
  List<ServiceCategoryItem> _visible = const [];
  Timer? _debounce;

  bool get _isSearching => _query.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _isGridView = ref.read(storageServiceProvider).retailCategoryGridView;
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
      var categories =
          await ref.read(servicesVendorsRepositoryProvider).fetchServiceCategories();
      if (categories.isEmpty) {
        categories = ServicesData.categories;
      }
      if (!mounted) return;
      setState(() {
        _all = categories;
        _applyFilter();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _all = ServicesData.categories;
        _applyFilter();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      _visible = _all;
      return;
    }
    _visible = _all
        .where((c) => c.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _query = value;
      _applyFilter();
    });
  }

  void _openCategory(ServiceCategoryItem category) {
    context.push(BrowseRoutes.servicesCategory(categoryId: category.id));
  }

  @override
  Widget build(BuildContext context) {
    final empty = !_loading && _visible.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrowseBackTitleHeader(
            title: ServicesData.homeTitle,
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
                  child: ServicesSubcategorySearchField(
                    hint: ServicesData.searchHint,
                    onChanged: _onQueryChanged,
                  ),
                ),
                SizedBox(width: 5.w),
                ServicesSubcategoryViewToggle(
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
                    ? Center(
                        child: Text(
                          _isSearching
                              ? 'No matching services'
                              : 'No service categories yet',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _load,
                        child: _isGridView
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  20.w,
                                  12.h,
                                  20.w,
                                  24.h,
                                ),
                                children: [
                                  ServicesSubcategoryGrid(
                                    categories: _visible,
                                    onCategoryTap: _openCategory,
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  20.w,
                                  8.h,
                                  20.w,
                                  24.h,
                                ),
                                itemCount: _visible.length,
                                itemBuilder: (context, index) {
                                  final cat = _visible[index];
                                  return ServicesSubcategoryListRow(
                                    category: cat,
                                    showDivider: index < _visible.length - 1,
                                    onTap: () => _openCategory(cat),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }
}
