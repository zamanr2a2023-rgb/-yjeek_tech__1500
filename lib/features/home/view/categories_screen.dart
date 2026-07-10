import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isGridView = true;

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                HomeStrings.deliverToLabel,
                                style: AppTextStyles.caption(
                                  color: AppColors.textSecondary,
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  Text(
                                    HomeData.deliveryLocation,
                                    style: AppTextStyles.bodyLarge(
                                      color: AppColors.textPrimary,
                                    ).copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    HomeStrings.categories,
                    style: AppTextStyles.displayMedium(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: const HomeSearchBar(
                    hint: HomeStrings.searchCategories,
                    height: 44,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        HomeStrings.allCategories,
                        style: AppTextStyles.titleSmall().copyWith(fontSize: 13),
                      ),
                      CategoriesViewToggle(
                        isGrid: _isGridView,
                        onChanged: (value) => setState(() => _isGridView = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: _isGridView
                ? SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: 87.5 / 83,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => GestureDetector(
                        onTap: () {
                          final category = HomeData.allCategories[index];
                          if (category.name == 'Food') {
                            context.push(BrowseRoutes.foodBrowse());
                          } else if (category.name == 'Dine In') {
                            context.push(BrowseRoutes.dineInBrowse());
                          } else if (category.name == 'Services') {
                            context.push(BrowseRoutes.servicesBrowse());
                          } else if (category.name == 'Electronics') {
                            context.push(BrowseRoutes.electronicsBrowse());
                          } else if (category.name == 'Vape') {
                            context.push(BrowseRoutes.vapeBrowse());
                          } else if (category.name == 'Pickup') {
                            context.push(BrowseRoutes.pickupBrowse());
                          }
                        },
                        child: CategoryIconTile(
                          category: HomeData.allCategories[index],
                          compact: true,
                        ),
                      ),
                      childCount: HomeData.allCategories.length,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = HomeData.allCategories[index];
                        return GestureDetector(
                          onTap: () {
                            if (category.name == 'Food') {
                              context.push(BrowseRoutes.foodBrowse());
                            } else if (category.name == 'Dine In') {
                              context.push(BrowseRoutes.dineInBrowse());
                            } else if (category.name == 'Services') {
                              context.push(BrowseRoutes.servicesBrowse());
                            } else if (category.name == 'Electronics') {
                              context.push(BrowseRoutes.electronicsBrowse());
                            } else if (category.name == 'Vape') {
                              context.push(BrowseRoutes.vapeBrowse());
                            } else if (category.name == 'Pickup') {
                              context.push(BrowseRoutes.pickupBrowse());
                            }
                          },
                          child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: category.backgroundColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  category.name,
                                  style: AppTextStyles.titleSmall().copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        );
                      },
                      childCount: HomeData.allCategories.length,
                    ),
                  ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
            sliver: SliverToBoxAdapter(child: WeeklySpotlightBanner()),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            context.pop();
            return;
          }
          context.goHome(tab: index);
        },
      ),
    );
  }
}
