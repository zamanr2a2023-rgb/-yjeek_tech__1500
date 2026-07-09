import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeGreenHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeGreetingHeader(),
                  const SizedBox(height: 14),
                  const HomeSearchBar(hint: HomeStrings.searchHome),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const OrderStatusCard(),
                const SizedBox(height: 18),
                SectionHeader(
                  title: HomeStrings.categories,
                  onSeeAll: () => context.push(RouteNames.categories),
                ),
                const SizedBox(height: 14),
                HomeCategoriesGrid(categories: HomeData.homeCategories),
                const SizedBox(height: 18),
                const SectionHeader(title: HomeStrings.orderAgain),
                const SizedBox(height: 14),
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: HomeData.orderAgainBrands.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return BrandAvatar(
                        brand: HomeData.orderAgainBrands[index],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  title: HomeStrings.exclusiveOffers,
                  onSeeAll: () => context.push(RouteNames.exclusiveOffers),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 165,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: HomeData.exclusiveOffers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return OfferProductCard(
                        offer: HomeData.exclusiveOffers[index],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                const WeeklySpotlightBanner(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
