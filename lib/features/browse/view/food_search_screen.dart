import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({
    super.key,
    this.initialQuery = '',
    this.bottomNavIndex = 0,
  });

  final String initialQuery;
  final int bottomNavIndex;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  late String _query;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.isNotEmpty ? widget.initialQuery : 'mezze';
  }

  List<BrowseRestaurant> get _results => BrowseData.searchResults(_query);

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
                hint: 'Search in Food…',
                value: _query,
                showCancel: true,
                onChanged: (v) => setState(() => _query = v),
                onCancel: () => context.pop(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                'Recent searches',
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: BrowseData.recentSearches.map((term) {
                  return GestureDetector(
                    onTap: () => setState(() => _query = term.toLowerCase()),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        term,
                        style: AppTextStyles.labelSmall(color: AppColors.textPrimary).copyWith(
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
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                itemCount: _results.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) => BrowseRestaurantListCard(
                  restaurant: _results[index],
                  onTap: () => context.push(
                    BrowseRoutes.vendorMenu(vendorId: _results[index].id),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
