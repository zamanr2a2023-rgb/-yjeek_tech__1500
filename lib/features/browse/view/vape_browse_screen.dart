import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class VapeBrowseScreen extends StatelessWidget {
  const VapeBrowseScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

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
                  title: VapeData.homeTitle,
                  onCart: () => context.goHome(tab: 2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                  child: const VapeAgeBanner(),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: BrowseSearchBar(
                    hint: VapeData.searchHint,
                    onTap: () {},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                  child: Text(
                    VapeData.storesSectionTitle,
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
              itemCount: VapeData.stores.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final store = VapeData.stores[index];
                return VapeStoreListCard(
                  store: store,
                  onTap: () => context.push(
                    BrowseRoutes.vapeStore(storeId: store.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
    );
  }
}
