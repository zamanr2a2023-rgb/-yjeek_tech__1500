import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/home/model/top_picks_models.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

/// Home section backed by GET /home/top-picks (hidden when empty / no location).
class HomeTopPicksSection extends ConsumerWidget {
  const HomeTopPicksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(topPicksProvider);
    return async.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: HomeStrings.topPicksNearYou),
            SizedBox(height: 14.h),
            SizedBox(
              height: 172.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _TopPickCard(
                    item: item,
                    onTap: () => context.push(
                      BrowseRoutes.itemDetail(
                        vendorId: item.vendorId,
                        itemId: item.productId,
                      ),
                    ),
                    onAdd: () => _addTopPick(context, ref, item),
                  );
                },
              ),
            ),
            SizedBox(height: 18.h),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Future<void> _addTopPick(
    BuildContext context,
    WidgetRef ref,
    HomeTopPickItem item,
  ) async {
    try {
      final detail = await ref
          .read(foodVendorsRepositoryProvider)
          .fetchProductDetail(
            vendorId: item.vendorId,
            itemId: item.productId,
          );
      if (!context.mounted) return;
      if (detail.item.hasModifiers) {
        await context.push(
          BrowseRoutes.itemDetail(
            vendorId: item.vendorId,
            itemId: item.productId,
          ),
        );
        return;
      }

      final repo = ref.read(cartRepositoryProvider);
      await repo.addProduct(
        type: CartOrderType.delivery,
        productId: item.productId,
        vendorId: item.vendorId,
      );
      if (!context.mounted) return;
      ref.read(shellProvider.notifier).openCartWithItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
      context.goHome(tab: 2, cartHasItems: true);
    } catch (e) {
      if (!context.mounted) return;
      if (e is OutOfDeliveryRangeException) {
        rememberPendingAddToCart(
          ref,
          PendingAddToCart(
            productId: item.productId,
            vendorId: item.vendorId,
          ),
        );
        await pushOutOfDelivery(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}

class _TopPickCard extends StatelessWidget {
  const _TopPickCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  final HomeTopPickItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final price = item.price;
    final priceLabel = price != null ? 'BHD ${price.toStringAsFixed(3)}' : '';
    final imageUrl = item.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? AppNetworkImage(url: imageUrl, fit: BoxFit.cover)
                  : ColoredBox(
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall(color: AppColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.vendorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      if (priceLabel.isNotEmpty)
                        Expanded(
                          child: Text(
                            priceLabel,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      InkWell(
                        onTap: onAdd,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
