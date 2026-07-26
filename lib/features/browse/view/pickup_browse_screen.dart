import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/pickup_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/pickup_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class PickupBrowseScreen extends ConsumerStatefulWidget {
  const PickupBrowseScreen({
    super.key,
    this.bottomNavIndex = 0,
    this.categorySlug,
  });

  final int bottomNavIndex;
  final String? categorySlug;

  @override
  ConsumerState<PickupBrowseScreen> createState() => _PickupBrowseScreenState();
}

class _PickupBrowseScreenState extends ConsumerState<PickupBrowseScreen> {
  List<PickupCategory> _categories = const [];
  List<PickupSpot> _spots = const [];
  bool _loading = true;
  String _query = '';
  String? _categorySlug;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _categorySlug = widget.categorySlug;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant PickupBrowseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categorySlug != widget.categorySlug) {
      _categorySlug = widget.categorySlug;
      _load();
    }
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
      final categories = await repo.fetchFeaturedCategories();
      final spots = await repo.fetchNearbySpots(
        query: _query,
        categorySlug: _categorySlug,
      );
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _spots = spots;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = const [];
        _spots = const [];
        _loading = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  void _onCategoryTap(PickupCategory category) {
    final slug = category.id;
    setState(() {
      // Tap same chip again → clear filter.
      _categorySlug = _categorySlug == slug ? null : slug;
    });
    _load();
  }

  void _openVendor(PickupSpot spot) {
    if (spot.id.isEmpty) return;
    context.push(BrowseRoutes.vendorMenu(vendorId: spot.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrowseTopBar(
                  title: PickupData.homeTitle,
                  onCart: () => context.goHome(tab: 2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: BrowseSearchBar(
                    hint: PickupData.searchHint,
                    value: _query,
                    autofocus: false,
                    onChanged: _onQueryChanged,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: PickupSectionHeader(
                    title: PickupData.browseByCategory,
                    onViewAll: () =>
                        context.push(BrowseRoutes.pickupCategories()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: PickupCategoryRow(
                    categories: _categories,
                    onCategoryTap: _onCategoryTap,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                  child: const PickupSectionHeader(
                    title: PickupData.readyNearYou,
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_spots.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No pickup spots found',
                  style: AppTextStyles.bodyMedium(
                    color: const Color(0xFF737873),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              sliver: SliverList.separated(
                itemCount: _spots.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final spot = _spots[index];
                  return PickupSpotCard(
                    spot: spot,
                    onTap: () => _openVendor(spot),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
