import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class ServicesBrowseScreen extends StatelessWidget {
  const ServicesBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          BrowseTopBar(
            title: ServicesData.homeTitle,
            onCart: () => context.goHome(tab: 2),
          ),
          SizedBox(height: 12.h),
          BrowseSearchBar(
            hint: ServicesData.searchHint,
            onTap: () => context.push(
              BrowseRoutes.servicesCategory(categoryId: 'salon-beauty'),
            ),
          ),
          SizedBox(height: 16.h),
          ServicesCategoryGrid(
            onCategoryTap: (category) => context.push(
              BrowseRoutes.servicesCategory(categoryId: category.id),
            ),
          ),
          SizedBox(height: 20.h),
          ServicesPopularSection(
            providers: ServicesData.popularProviders,
            onSeeAll: () => context.push(
              BrowseRoutes.servicesCategory(categoryId: 'salon-beauty'),
            ),
            onProviderTap: (provider) => context.push(
              BrowseRoutes.servicesProvider(providerId: provider.id),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
    );
  }
}
