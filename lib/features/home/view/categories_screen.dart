import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _isGridView = true;

  void _onCategoryTap(CategoryItem category) {
    final key = (category.slug ?? category.name).toLowerCase();
    if (key.contains('food')) {
      context.push(BrowseRoutes.foodBrowse());
    } else if (key.contains('dine')) {
      context.push(BrowseRoutes.dineInBrowse());
    } else if (key.contains('service')) {
      context.push(BrowseRoutes.servicesBrowse());
    } else if (key.contains('electronic')) {
      context.push(BrowseRoutes.electronicsBrowse());
    } else if (key.contains('vape')) {
      context.push(BrowseRoutes.vapeBrowse());
    } else if (key.contains('pickup')) {
      context.push(BrowseRoutes.pickupBrowse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories =
        categoriesAsync.valueOrNull ?? HomeData.allCategories;
    final home = ref.watch(homeFeedProvider).valueOrNull;
    final deliverTo =
        home?.deliverToLabel ?? HomeData.deliveryLocation;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          await ref.read(categoriesProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                                    Flexible(
                                      child: Text(
                                        deliverTo,
                                        style: AppTextStyles.bodyLarge(
                                          color: AppColors.textPrimary,
                                        ).copyWith(fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                          GestureDetector(
                            onTap: () => context.goHome(tab: 2),
                            child: Container(
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
                    child: HomeSearchBar(
                      hint: HomeStrings.searchCategories,
                      height: 44,
                      onTap: () => context.push(BrowseRoutes.foodSearch()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          HomeStrings.allCategories,
                          style: AppTextStyles.titleSmall()
                              .copyWith(fontSize: 13),
                        ),
                        CategoriesViewToggle(
                          isGrid: _isGridView,
                          onChanged: (value) =>
                              setState(() => _isGridView = value),
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
                  ? SliverGridCategories(
                      categories: categories,
                      onTap: _onCategoryTap,
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = categories[index];
                          return GestureDetector(
                            onTap: () => _onCategoryTap(category),
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
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        category.icon,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      category.name,
                                      style: AppTextStyles.titleSmall()
                                          .copyWith(fontSize: 15),
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
                        childCount: categories.length,
                      ),
                    ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
              sliver: SliverToBoxAdapter(child: WeeklySpotlightBanner()),
            ),
          ],
        ),
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

class SliverGridCategories extends StatelessWidget {
  const SliverGridCategories({
    super.key,
    required this.categories,
    required this.onTap,
  });

  final List<CategoryItem> categories;
  final ValueChanged<CategoryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 0,
        mainAxisExtent: 90,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => GestureDetector(
          onTap: () => onTap(categories[index]),
          child: CategoryIconTile(
            category: categories[index],
            compact: true,
          ),
        ),
        childCount: categories.length,
      ),
    );
  }
}
