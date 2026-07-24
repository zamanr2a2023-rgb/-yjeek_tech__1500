import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_feed.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/routes/route_names.dart';

class HomeScreen extends ConsumerWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  String _greetingFor(UserMe? user, String apiGreeting) {
    final first = user?.profile.firstName?.trim();
    if (first != null && first.isNotEmpty) {
      return 'Hello, $first 👋';
    }
    final display = user?.profile.displayName?.trim();
    if (display != null && display.isNotEmpty && display != 'Customer') {
      final firstWord = display.split(RegExp(r'\s+')).first;
      return 'Hello, $firstWord 👋';
    }
    if (apiGreeting.isNotEmpty) {
      return apiGreeting.contains('👋') ? apiGreeting : '$apiGreeting 👋';
    }
    return HomeStrings.hello;
  }

  void _onCategoryTap(BuildContext context, CategoryItem category) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeFeedProvider);
    final feed = homeAsync.valueOrNull ?? HomeFeed.fallback();
    final user = ref.watch(userMeProvider).valueOrNull;
    final greeting = _greetingFor(user, feed.greeting);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(homeFeedProvider);
          ref.invalidate(userMeProvider);
          await Future.wait([
            ref.read(homeFeedProvider.future),
            ref.read(userMeProvider.future),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HomeGreenHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeGreetingHeader(
                      greeting: greeting,
                      deliveryLocation: feed.deliverToLabel,
                    ),
                    const SizedBox(height: 14),
                    HomeSearchBar(
                      hint: HomeStrings.searchHome,
                      onTap: () => context.push(BrowseRoutes.foodSearch()),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (feed.activeOrder != null) ...[
                    OrderStatusCard(
                      title: feed.activeOrder!.title,
                      subtitle: feed.activeOrder!.subtitle,
                      onTrack: () => context.push(
                        OrderFlowRoutes.statusFor(feed.activeOrder!.id),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  SectionHeader(
                    title: HomeStrings.categories,
                    onSeeAll: () => context.push(RouteNames.categories),
                  ),
                  const SizedBox(height: 14),
                  HomeCategoriesGrid(
                    categories: feed.categories.take(8).toList(),
                    onCategoryTap: (category) =>
                        _onCategoryTap(context, category),
                  ),
                  const SizedBox(height: 18),
                  SectionHeader(
                    title: HomeStrings.orderAgain,
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: feed.reorderVendors.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return BrandAvatar(
                          brand: feed.reorderVendors[index],
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
                      itemCount: feed.exclusiveOffers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return OfferProductCard(
                          offer: feed.exclusiveOffers[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  WeeklySpotlightBanner(
                    title: feed.spotlight?.title,
                    ctaLabel: feed.spotlight?.ctaLabel,
                    eyebrow: feed.spotlight?.subtitle,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
