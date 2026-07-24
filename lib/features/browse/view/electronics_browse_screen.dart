import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/electronics_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class ElectronicsBrowseScreen extends ConsumerStatefulWidget {
  const ElectronicsBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<ElectronicsBrowseScreen> createState() =>
      _ElectronicsBrowseScreenState();
}

class _ElectronicsBrowseScreenState
    extends ConsumerState<ElectronicsBrowseScreen> {
  bool _isGridView = false;
  bool _freeDeliveryOnly = false;
  String _sort = 'rating';
  String _query = '';
  List<ElectronicsStore> _stores = const [];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stores = await ref.read(electronicsVendorsRepositoryProvider).fetchStores(
            sort: _sort,
            freeDelivery: _freeDeliveryOnly,
            query: _query,
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

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F2),
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
                  BrowseTopBar(
                    title: ElectronicsData.homeTitle,
                    onCart: () => context.goHome(tab: 2),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                    child: BrowseSearchBar(
                      hint: ElectronicsData.searchHint,
                      value: _query,
                      autofocus: false,
                      onChanged: _onQueryChanged,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: ElectronicsToolbar(
                      isGridView: _isGridView,
                      onViewChanged: (v) => setState(() => _isGridView = v),
                      freeDeliveryOnly: _freeDeliveryOnly,
                      onFreeDeliveryChanged: (v) {
                        setState(() => _freeDeliveryOnly = v);
                        _load();
                      },
                      sort: _sort,
                      onSortChanged: (v) {
                        setState(() => _sort = v);
                        _load();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: Text(
                      ElectronicsData.storesSectionTitle,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        height: 18 / 15,
                      ),
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
            else if (_isGridView)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final store = _stores[index];
                      return ElectronicsStoreGridCard(
                        store: store,
                        onTap: () => context.push(
                          BrowseRoutes.electronicsStore(storeId: store.id),
                        ),
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
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final store = _stores[index];
                    return ElectronicsStoreListCard(
                      store: store,
                      onTap: () => context.push(
                        BrowseRoutes.electronicsStore(storeId: store.id),
                      ),
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
