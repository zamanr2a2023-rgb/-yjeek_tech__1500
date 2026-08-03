import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class ServicesBrowseScreen extends ConsumerStatefulWidget {
  const ServicesBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<ServicesBrowseScreen> createState() =>
      _ServicesBrowseScreenState();
}

class _ServicesBrowseScreenState extends ConsumerState<ServicesBrowseScreen> {
  List<ServiceCategoryItem> _categories = ServicesData.categories;
  List<ServiceProvider> _popular = ServicesData.popularProviders;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(servicesVendorsRepositoryProvider);
    setState(() => _loading = true);
    try {
      final categories = await repo.fetchServiceCategories();
      final popular = await repo.fetchPopularProviders();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _popular = popular;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = ServicesData.categories;
        _popular = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrowseTopBar(
            title: ServicesData.homeTitle,
            onCart: () => context.goHome(tab: 2),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                // Design body: padding 8 20 24, gap 14 — top 14 keeps header→search breathing room.
                padding: EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 24.w),
                children: [
                  BrowseSearchBar(
                    hint: ServicesData.searchHint,
                    onTap: () => context.push(BrowseRoutes.servicesSearch()),
                  ),
                  SizedBox(height: 2.w),
                  if (_loading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else ...[
                    ServicesCategoryGrid(
                      categories: _categories,
                      onCategoryTap: (category) => context.push(
                        BrowseRoutes.servicesCategory(categoryId: category.id),
                      ),
                    ),
                    SizedBox(height: 14.w),
                    ServicesPopularSection(
                      providers: _popular,
                      onSeeAll: () => context.push(
                        BrowseRoutes.servicesCategory(
                          categoryId: _categories.isNotEmpty
                              ? _categories.first.id
                              : 'salon-beauty',
                        ),
                      ),
                      onProviderTap: (provider) => context.push(
                        BrowseRoutes.servicesProvider(
                          providerId: provider.id,
                        ),
                      ),
                    ),
                  ],
                ],
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
