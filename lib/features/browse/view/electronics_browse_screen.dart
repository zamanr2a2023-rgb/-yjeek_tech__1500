import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/electronics_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class ElectronicsBrowseScreen extends StatefulWidget {
  const ElectronicsBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  State<ElectronicsBrowseScreen> createState() => _ElectronicsBrowseScreenState();
}

class _ElectronicsBrowseScreenState extends State<ElectronicsBrowseScreen> {
  bool _isGridView = false;
  bool _freeDeliveryOnly = false;

  List<ElectronicsStore> get _stores {
    if (!_freeDeliveryOnly) return ElectronicsData.stores;
    return ElectronicsData.stores.where((store) => store.freeDelivery).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F2),
      body: CustomScrollView(
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
                    onTap: () {},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  child: ElectronicsToolbar(
                    isGridView: _isGridView,
                    onViewChanged: (v) => setState(() => _isGridView = v),
                    freeDeliveryOnly: _freeDeliveryOnly,
                    onFreeDeliveryChanged: (v) =>
                        setState(() => _freeDeliveryOnly = v),
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
          if (_isGridView)
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
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
