import 'package:flutter/material.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';

class HomeGreenHeader extends StatelessWidget {
  const HomeGreenHeader({
    super.key,
    required this.child,
    this.showCart = false,
    this.onCartTap,
  });

  final Widget child;
  final bool showCart;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCart)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onCartTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HomeStrings.hello,
          style: AppTextStyles.labelMedium(
            color: const Color(0xFFCFE8D8),
          ).copyWith(fontSize: 13),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              HomeStrings.deliverTo,
              style: AppTextStyles.labelSmall(
                color: const Color(0xFFCFE8D8),
              ).copyWith(fontSize: 12),
            ),
            const SizedBox(width: 5),
            Text(
              HomeData.deliveryLocation,
              style: AppTextStyles.bodyLarge(color: AppColors.white).copyWith(
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              '▾',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.hint,
    this.height = 52,
  });

  final String hint;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hint,
              style: AppTextStyles.bodySmall(),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderStatusCard extends StatelessWidget {
  const OrderStatusCard({super.key, this.onTrack});

  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTrack,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E9E4D), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        HomeStrings.preparingOrder,
                        style: AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        HomeStrings.orderSubtitle,
                        style: AppTextStyles.labelSmall(
                          color: const Color(0xFF6B756E),
                        ).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E9E4D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    HomeStrings.track,
                    style: AppTextStyles.labelSmall(color: AppColors.white)
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.45,
                minHeight: 4,
                backgroundColor: Color(0xFFE3F2EB),
                color: Color(0xFF2E9E4D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall().copyWith(fontSize: 18),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              HomeStrings.seeAll,
              style: AppTextStyles.labelMedium(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

class HomeCategoriesGrid extends StatelessWidget {
  const HomeCategoriesGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<CategoryItem> categories;
  final ValueChanged<CategoryItem>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final firstRow = categories.take(4).toList();
    final secondRow = categories.skip(4).take(4).toList();

    return Column(
      children: [
        _CategoryRow(items: firstRow, onCategoryTap: onCategoryTap),
        if (secondRow.isNotEmpty) ...[
          const SizedBox(height: 12),
          _CategoryRow(items: secondRow, onCategoryTap: onCategoryTap),
        ],
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.items, this.onCategoryTap});

  final List<CategoryItem> items;
  final ValueChanged<CategoryItem>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items
          .map(
            (category) => SizedBox(
              width: 60,
              child: GestureDetector(
                onTap: onCategoryTap != null ? () => onCategoryTap!(category) : null,
                child: CategoryIconTile(category: category),
              ),
            ),
          )
          .toList(),
    );
  }
}

class CategoryIconTile extends StatelessWidget {
  const CategoryIconTile({
    super.key,
    required this.category,
    this.compact = false,
  });

  final CategoryItem category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 62.0 : 58.0;
    final iconSize = compact ? 28.0 : 26.0;

    return SizedBox(
      height: compact ? 83 : 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: category.backgroundColor,
              borderRadius: BorderRadius.circular(compact ? 18 : 17),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              category.icon,
              color: AppColors.textPrimary,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: compact ? 14 : 15,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(color: AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandAvatar extends StatelessWidget {
  const BrandAvatar({super.key, required this.brand});

  final BrandItem brand;

  @override
  Widget build(BuildContext context) {
    final label = brand.name.replaceAll('\n', ' ');
    final initial = label.isNotEmpty ? label[0] : '';

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: brand.color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(color: AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class OfferProductCard extends StatelessWidget {
  const OfferProductCard({super.key, required this.offer});

  final OfferItem offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: offer.imageColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  offer.price,
                  style: AppTextStyles.labelSmall(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklySpotlightBanner extends StatelessWidget {
  const WeeklySpotlightBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 124,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF0F4D27),
                    Color(0xFF1A6B3C),
                    Color(0xFF3F5C38),
                    Color(0xFF6B4A2A),
                  ],
                  stops: [0.0, 0.42, 0.68, 1.0],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 130,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6B4A2A).withValues(alpha: 0),
                      const Color(0xFF6B4A2A).withValues(alpha: 0.85),
                      const Color(0xFF15302B),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HomeStrings.weeklySpotlight,
                    style: AppTextStyles.caption(
                      color: const Color(0xFFEBC34A),
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    HomeStrings.spotlightTitle,
                    style: AppTextStyles.titleSmall(color: AppColors.white)
                        .copyWith(fontSize: 18),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      HomeStrings.orderNow,
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF0F4D27),
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
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

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(
      activeAsset: AppAssets.navHomeActive,
      inactiveAsset: AppAssets.navHomeInactive,
      label: HomeStrings.navHome,
    ),
    _NavItem(
      activeAsset: AppAssets.navOrdersActive,
      inactiveAsset: AppAssets.navOrdersInactive,
      label: HomeStrings.navOrders,
    ),
    _NavItem(
      activeAsset: AppAssets.navCartActive,
      inactiveAsset: AppAssets.navCartInactive,
      label: HomeStrings.navCart,
    ),
    _NavItem(
      activeAsset: AppAssets.navWalletActive,
      inactiveAsset: AppAssets.navWalletInactive,
      label: HomeStrings.navWallet,
      tintWhenActive: true,
    ),
    _NavItem(
      activeAsset: AppAssets.navAccountActive,
      inactiveAsset: AppAssets.navAccountInactive,
      label: HomeStrings.navAccount,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final active = index == currentIndex;
              final item = _items[index];
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavIcon(
                        activeAsset: item.activeAsset,
                        inactiveAsset: item.inactiveAsset,
                        active: active,
                        tintWhenActive: item.tintWhenActive,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: AppTextStyles.caption(
                          color: active ? AppColors.primary : AppColors.textSecondary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.activeAsset,
    required this.inactiveAsset,
    required this.label,
    this.tintWhenActive = false,
  });

  final String activeAsset;
  final String inactiveAsset;
  final String label;
  final bool tintWhenActive;
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.activeAsset,
    required this.inactiveAsset,
    required this.active,
    required this.tintWhenActive,
  });

  final String activeAsset;
  final String inactiveAsset;
  final bool active;
  final bool tintWhenActive;

  @override
  Widget build(BuildContext context) {
    if (active && !tintWhenActive) {
      return Image.asset(
        activeAsset,
        width: 24.w,
        height: 24.w,
        fit: BoxFit.contain,
      );
    }

    final asset = active ? activeAsset : inactiveAsset;
    final image = Image.asset(
      asset,
      width: 24.w,
      height: 24.w,
      fit: BoxFit.contain,
    );

    if (active && tintWhenActive) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(
          AppColors.primary,
          BlendMode.srcIn,
        ),
        child: image,
      );
    }

    return image;
  }
}

class CategoriesViewToggle extends StatelessWidget {
  const CategoriesViewToggle({
    super.key,
    required this.isGrid,
    required this.onChanged,
  });

  final bool isGrid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // Figma: track #DCE7D4 · active segment #4CAF50 · radius 11 / 8.
    return Container(
      width: 74,
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE7D4),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          _ToggleSegment(
            icon: Icons.grid_view_rounded,
            active: isGrid,
            onTap: () => onChanged(true),
          ),
          _ToggleSegment(
            icon: Icons.view_list_rounded,
            active: !isGrid,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 28,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF4CAF50) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: active ? AppColors.white : const Color(0xFF6B7B6E),
          ),
        ),
      ),
    );
  }
}
