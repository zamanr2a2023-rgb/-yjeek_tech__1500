import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class ServicesCategoryScreen extends StatefulWidget {
  const ServicesCategoryScreen({
    super.key,
    required this.categoryId,
    this.bottomNavIndex = 0,
  });

  final String categoryId;
  final int bottomNavIndex;

  @override
  State<ServicesCategoryScreen> createState() => _ServicesCategoryScreenState();
}

class _ServicesCategoryScreenState extends State<ServicesCategoryScreen> {
  bool _isGridView = true;
  String _venueFilter = ServicesData.venueFilters.first;

  ServiceCategoryItem get _category => ServicesData.categoryById(widget.categoryId);

  List<ServiceProvider> get _providers =>
      ServicesData.providersForCategory(widget.categoryId, venueFilter: _venueFilter);

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
                ServicesCategoryHeader(
                  title: _category.name,
                  subtitle: _isGridView ? 'Grid view' : 'List view',
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: ServicesVenueFilterChips(
                    options: ServicesData.venueFilters,
                    selected: _venueFilter,
                    onSelected: (v) => setState(() => _venueFilter = v),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: ServicesToolbar(
                    isGridView: _isGridView,
                    onViewChanged: (v) => setState(() => _isGridView = v),
                  ),
                ),
              ],
            ),
          ),
          if (_isGridView)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 0.86,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ServicesProviderGridCard(
                    provider: _providers[index],
                    onTap: () => context.push(
                      BrowseRoutes.servicesProvider(providerId: _providers[index].id),
                    ),
                  ),
                  childCount: _providers.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              sliver: SliverList.separated(
                itemCount: _providers.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) => ServicesProviderListCard(
                  provider: _providers[index],
                  onTap: () => context.push(
                    BrowseRoutes.servicesProvider(providerId: _providers[index].id),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
