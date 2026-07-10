import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
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
      backgroundColor: AppColors.background,
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
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: BrowseSearchBar(
                    hint: ElectronicsData.searchHint,
                    onTap: () {},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: BrowseSortBar(
                    isGridView: _isGridView,
                    onViewChanged: (v) => setState(() => _isGridView = v),
                    freeDeliveryOnly: _freeDeliveryOnly,
                    onFreeDeliveryChanged: (v) => setState(() => _freeDeliveryOnly = v),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                  child: Text(
                    ElectronicsData.storesSectionTitle,
                    style: AppTextStyles.titleSmall().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
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
