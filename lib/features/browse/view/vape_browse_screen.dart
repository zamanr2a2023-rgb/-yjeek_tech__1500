import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/fashion_vendors_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

/// Vape vendor list — age banner · Scheduled · Order again · Offers · list/grid.
class VapeBrowseScreen extends ConsumerStatefulWidget {
  const VapeBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<VapeBrowseScreen> createState() => _VapeBrowseScreenState();
}

class _VapeBrowseScreenState extends ConsumerState<VapeBrowseScreen> {
  late bool _isGridView;
  bool _offersOnly = false;
  bool _topRated = false;
  List<VapeStore> _stores = const [];
  bool _loading = true;

  /// Order-history vendors that appear in this list. Hidden when empty.
  List<VapeStore> get _orderAgainStores {
    final loggedIn = ref.watch(storageServiceProvider).hasSession;
    if (!loggedIn) return const [];
    final vendors = ref.watch(homeFeedProvider).valueOrNull?.reorderVendors;
    if (vendors == null || vendors.isEmpty || _stores.isEmpty) {
      return const [];
    }
    final byId = {for (final s in _stores) s.id: s};
    final out = <VapeStore>[];
    final seen = <String>{};
    for (final brand in vendors) {
      final id = brand.id;
      if (id == null || id.isEmpty || seen.contains(id)) continue;
      final store = byId[id];
      if (store == null) continue;
      seen.add(id);
      out.add(store);
      if (out.length >= 8) break;
    }
    return out;
  }

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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stores = await ref.read(vapeVendorsRepositoryProvider).fetchStores(
            sort: _topRated ? 'rating' : 'popular',
            hasOffers: _offersOnly,
          );
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stores = const [];
        _loading = false;
      });
    }
  }

  void _openStore(VapeStore store) {
    context.push(BrowseRoutes.vapeStore(storeId: store.id));
  }

  @override
  Widget build(BuildContext context) {
    final orderAgain = _orderAgainStores;

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
                  FashionVendorsHeader(title: VapeData.homeTitle),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 2.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const VapeAgeBanner(),
                        SizedBox(height: 12.h),
                        const FashionScheduledBar(),
                        SizedBox(height: 14.h),
                        VapeOrderAgainRow(
                          stores: orderAgain,
                          onSeeAll: () => context.goHome(tab: 1),
                          onStoreTap: _openStore,
                        ),
                        if (orderAgain.isNotEmpty) SizedBox(height: 12.h),
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
            else if (_stores.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No vape stores found',
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
                      final store = _stores[index];
                      return VapeVendorGridCard(
                        store: store,
                        onTap: () => _openStore(store),
                      );
                    },
                    childCount: _stores.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                sliver: SliverList.separated(
                  itemCount: _stores.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final store = _stores[index];
                    return VapeVendorListCard(
                      store: store,
                      onTap: () => _openStore(store),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
