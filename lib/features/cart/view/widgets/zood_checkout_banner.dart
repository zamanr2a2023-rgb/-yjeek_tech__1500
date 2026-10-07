import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/zood_promo.dart';
import 'package:yjeek_app/features/cart/provider/zood_promo_provider.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';

/// Renders the Zoood promo banner when admin placement matches [placement].
class ZoodCheckoutBannerSlot extends ConsumerWidget {
  const ZoodCheckoutBannerSlot({
    super.key,
    required this.placement,
    required this.joinScreen,
  });

  /// Backend `ZoodCheckoutPlacement` value, e.g. `BELOW_PAYMENT`.
  final String placement;
  final String joinScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promoAsync = ref.watch(zoodPromoProvider);
    return promoAsync.when(
      data: (promo) {
        if (promo == null) return const SizedBox.shrink();
        final banner = promo.banner;
        if (!banner.show || banner.placement != placement) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: CartZoodPromoBanner(
            badge: banner.badge,
            headline: banner.headline,
            hint: banner.hint,
            cta: banner.cta,
            chips: banner.chips,
            onTap: () async {
              final joined = await context.push<bool?>(
                CartRoutes.zoodWaitingList,
                extra: ZoodWaitingListRouteArgs(
                  promo: promo,
                  joinScreen: joinScreen,
                ),
              );
              if (joined == true) {
                ref.invalidate(zoodPromoProvider);
              }
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _stack) => const SizedBox.shrink(),
    );
  }
}
