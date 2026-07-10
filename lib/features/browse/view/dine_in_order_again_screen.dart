import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/dine_in_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class DineInOrderAgainScreen extends StatefulWidget {
  const DineInOrderAgainScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  State<DineInOrderAgainScreen> createState() => _DineInOrderAgainScreenState();
}

class _DineInOrderAgainScreenState extends State<DineInOrderAgainScreen> {
  String _selectedFilter = DineInData.orderAgainFilters.first;

  List<DineInVisit> get _visits => DineInData.visitsForFilter(_selectedFilter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrowseTopBar(title: 'Order again'),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
            child: Text(
              'Your recent dine-in visits',
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: BrowseFilterChips(
              options: DineInData.orderAgainFilters,
              selected: _selectedFilter,
              onSelected: (v) => setState(() => _selectedFilter = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              itemCount: _visits.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final visit = _visits[index];
                return DineInVisitCard(
                  visit: visit,
                  onBookAgain: () => context.push(
                    BrowseRoutes.dineInMenu(restaurantId: visit.restaurantId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
