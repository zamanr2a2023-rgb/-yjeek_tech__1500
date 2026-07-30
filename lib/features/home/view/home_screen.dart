import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/home/model/category_navigation.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';
import 'package:yjeek_app/features/home/model/home_feed.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/routes/app_router.dart';
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

  bool _isScheduledOffer(OfferItem offer) {
    final slug = (offer.categorySlug ?? '').toLowerCase();
    if (slug.contains('food') || slug.contains('restaurant')) return false;
    if (slug.contains('grocery') ||
        slug.contains('fashion') ||
        slug.contains('electronic') ||
        slug.contains('cosmetic') ||
        slug.contains('gift') ||
        slug.contains('pharmacy') ||
        slug.contains('vape') ||
        slug.contains('jewelry') ||
        slug.contains('sport') ||
        slug.contains('station') ||
        slug.contains('baby') ||
        slug.contains('prosthetic')) {
      return true;
    }
    // Name heuristics for mock fallback offers without category.
    final name = offer.name.toLowerCase();
    return name.contains('dress') ||
        name.contains('grocery') ||
        name.contains('basket');
  }

  Future<void> _addHomeOffer(
    BuildContext context,
    WidgetRef ref,
    OfferItem offer,
  ) async {
    final productId = offer.productId;
    if (productId == null || productId.isEmpty) {
      context.push(RouteNames.exclusiveOffers);
      return;
    }

    try {
      final repo = ref.read(cartRepositoryProvider);
      if (_isScheduledOffer(offer)) {
        Future<void> addScheduled({bool replaceCart = false}) async {
          final snap = await repo.addScheduledProduct(
            productId: productId,
            replaceCart: replaceCart,
          );
          if (!context.mounted) return;
          if (snap == null || !snap.hasItems) {
            throw Exception('Could not add to cart');
          }
          ref.read(shellProvider.notifier).openScheduledCartWithItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${offer.name} added to cart'),
              duration: const Duration(seconds: 1),
            ),
          );
          context.goHome(tab: 2, scheduledCart: true);
        }

        try {
          await addScheduled();
        } on ScheduledVendorLimitException {
          if (!context.mounted) return;
          showCartNewCartDialog(
            context,
            onConfirm: () => addScheduled(replaceCart: true),
          );
        }
        return;
      }

      await repo.addProduct(
        type: CartOrderType.delivery,
        productId: productId,
      );
      if (!context.mounted) return;
      ref.read(shellProvider.notifier).openCartWithItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${offer.name} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
      context.goHome(tab: 2, cartHasItems: true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
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
                        openHomeCategory(context, category),
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
                        final offer = feed.exclusiveOffers[index];
                        return OfferProductCard(
                          offer: offer,
                          onTap: () => _addHomeOffer(context, ref, offer),
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
