import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/browse_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/location_service.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/ui_content/view/ui_banner_widgets.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({
    super.key,
    this.initialQuery = '',
    this.bottomNavIndex = 0,
  });

  final String initialQuery;
  final int bottomNavIndex;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  late String _query;
  List<BrowseRestaurant> _results = const [];
  List<String> _recent = const [];
  Timer? _debounce;
  bool _loading = false;
  ({double lat, double lng})? _position;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _position = await const LocationService().currentPosition();
      await _loadRecent();
      await _search(_query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final recent =
        await ref.read(foodVendorsRepositoryProvider).fetchRecentSearches();
    if (!mounted) return;
    setState(() => _recent = recent);
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(value);
    });
  }

  Future<void> _search(String value) async {
    setState(() => _loading = true);
    final pos = _position;
    final repo = ref.read(foodVendorsRepositoryProvider);
    var results = await repo.fetchVendors(
      query: value,
      sort: pos != null ? 'distance' : 'rating',
      latitude: pos?.lat,
      longitude: pos?.lng,
      withinDeliveryRadius: pos != null,
    );
    if (pos != null && results.isEmpty) {
      results = await repo.fetchVendors(
        query: value,
        sort: 'rating',
        latitude: pos.lat,
        longitude: pos.lng,
        withinDeliveryRadius: false,
      );
    }
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: BrowseSearchBar(
                hint: BrowseStrings.searchInFood,
                value: _query,
                autofocus: true,
                showCancel: true,
                onChanged: _onQueryChanged,
                onCancel: () => context.pop(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: const UiPlacementBanner(placementKey: 'search_top'),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                BrowseStrings.recentSearches,
                style: AppTextStyles.labelSmall(
                  color: AppColors.textSecondary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _recent.map((term) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _query = term);
                      _search(term);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        term,
                        style:
                            AppTextStyles.labelSmall(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 10.h),
              child: Text(
                'RESULTS',
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary)
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            '___',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                          itemCount: _results.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) =>
                              BrowseRestaurantListCard(
                            restaurant: _results[index],
                            onTap: () => context.push(
                              BrowseRoutes.vendorMenu(
                                vendorId: _results[index].id,
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }
}
