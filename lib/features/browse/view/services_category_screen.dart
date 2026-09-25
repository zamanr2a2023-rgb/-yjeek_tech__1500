import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/fashion_vendors_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

/// Services provider list for a sub-category (Cleaning / Beauty & Salon / …).
/// Book again · Offers · Top rated · list/grid · availability-first sort.
class ServicesCategoryScreen extends ConsumerStatefulWidget {
  const ServicesCategoryScreen({
    super.key,
    required this.categoryId,
    this.bottomNavIndex = 0,
  });

  final String categoryId;
  final int bottomNavIndex;

  @override
  ConsumerState<ServicesCategoryScreen> createState() =>
      _ServicesCategoryScreenState();
}

class _ServicesCategoryScreenState
    extends ConsumerState<ServicesCategoryScreen> {
  late bool _isGridView;
  bool _offersOnly = false;
  bool _topRated = false;
  ServiceCategoryItem? _category;
  List<ServiceProvider> _providers = const [];
  bool _loading = true;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    _isGridView = ref.read(storageServiceProvider).retailCategoryGridView;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _setGridView(bool isGrid) async {
    setState(() => _isGridView = isGrid);
    await ref.read(storageServiceProvider).setRetailCategoryGridView(isGrid);
  }

  /// Prior bookings in this subcategory (hidden when empty).
  List<ServiceProvider> get _bookAgain {
    final loggedIn = ref.watch(storageServiceProvider).hasSession;
    if (!loggedIn || _providers.isEmpty) return const [];
    final vendors = ref.watch(homeFeedProvider).valueOrNull?.reorderVendors;
    if (vendors == null || vendors.isEmpty) return const [];
    final byId = {for (final p in _providers) p.id: p};
    final out = <ServiceProvider>[];
    final seen = <String>{};
    for (final brand in vendors) {
      final id = brand.id;
      if (id == null || id.isEmpty || seen.contains(id)) continue;
      final p = byId[id];
      if (p == null) continue;
      seen.add(id);
      out.add(p);
      if (out.length >= 8) break;
    }
    return out;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(servicesVendorsRepositoryProvider);
      final category = await repo.fetchCategoryById(widget.categoryId);
      final providers = await repo.fetchProviders(
        subcategory: widget.categoryId,
        sort: _topRated ? 'rating' : 'popular',
        offersOnly: _offersOnly,
      );
      if (!mounted) return;
      setState(() {
        _category = category;
        _providers = providers;
        _loading = false;
        _loadedOnce = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _providers = const [];
        _loading = false;
        _loadedOnce = true;
      });
    }
  }

  void _openProvider(ServiceProvider provider) {
    context.push(BrowseRoutes.servicesProvider(providerId: provider.id));
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce && _loading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }

    final bookAgain = _bookAgain;
    final title = _category?.name ?? 'Services';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FashionVendorsHeader(title: title),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 2.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ServicesBookAgainRow(
                          providers: bookAgain,
                          onSeeAll: () => context.goHome(tab: 1),
                          onProviderTap: _openProvider,
                        ),
                        if (bookAgain.isNotEmpty) SizedBox(height: 12.h),
                        FashionFilterRow(
                          isGridView: _isGridView,
                          onViewChanged: _setGridView,
                          offersOnly: _offersOnly,
                          onOffersTap: () {
                            setState(() => _offersOnly = !_offersOnly);
                            _load();
                          },
                          topRated: _topRated,
                          onTopRatedTap: () {
                            setState(() => _topRated = !_topRated);
                            _load();
                          },
                        ),
                      ],
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
            else if (_providers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No providers available right now',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else if (_isGridView)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = _providers[index];
                      return ServicesListingGridCard(
                        provider: p,
                        onTap: () => _openProvider(p),
                      );
                    },
                    childCount: _providers.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                sliver: SliverList.separated(
                  itemCount: _providers.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final p = _providers[index];
                    return ServicesListingListCard(
                      provider: p,
                      onTap: () => _openProvider(p),
                    );
                  },
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
