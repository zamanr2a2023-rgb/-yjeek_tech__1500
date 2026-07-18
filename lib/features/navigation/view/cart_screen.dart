import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/dine_in_cart/dine_in_cart_routes.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/features/dine_in_cart/view/widgets/dine_in_cart_widgets.dart';
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';
import 'package:yjeek_app/features/scheduled_cart/scheduled_cart_routes.dart';
import 'package:yjeek_app/features/scheduled_cart/view/widgets/scheduled_cart_widgets.dart';
import 'package:yjeek_app/features/pickup_cart/model/pickup_cart_data.dart';
import 'package:yjeek_app/features/pickup_cart/pickup_cart_routes.dart';
import 'package:yjeek_app/features/pickup_cart/view/widgets/pickup_cart_widgets.dart';
import 'package:yjeek_app/features/vape_cart/model/vape_cart_data.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';
import 'package:yjeek_app/features/vape_cart/view/widgets/vape_cart_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.hasItems,
    required this.onBrowseVendors,
    this.hasDineInItems = false,
    this.hasScheduledItems = false,
    this.hasPickupItems = false,
    this.hasVapeItems = false,
    this.initialTab = CartTab.orders,
    this.onBack,
    this.onCartTabChanged,
  });

  final bool hasItems;
  final bool hasDineInItems;
  final bool hasScheduledItems;
  final bool hasPickupItems;
  final bool hasVapeItems;
  final CartTab initialTab;
  final VoidCallback onBrowseVendors;
  final VoidCallback? onBack;
  final ValueChanged<CartTab>? onCartTabChanged;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final PageController _pageController;
  int _tabIndex = 0;
  int _quantity = 1;
  bool _includeCutlery = false;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.index;
    _pageController = PageController(initialPage: _tabIndex);
  }

  @override
  void didUpdateWidget(CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab && _tabIndex != widget.initialTab.index) {
      _tabIndex = widget.initialTab.index;
      _pageController.jumpToPage(_tabIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
    widget.onCartTabChanged?.call(CartTab.values[index]);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    if (index != _tabIndex) {
      setState(() => _tabIndex = index);
      widget.onCartTabChanged?.call(CartTab.values[index]);
    }
  }

  bool get _showPopulatedHeader =>
      (widget.hasItems && _tabIndex == CartTab.orders.index) ||
      (widget.hasDineInItems && _tabIndex == CartTab.dineIn.index) ||
      ((widget.hasPickupItems || widget.hasScheduledItems) &&
          _tabIndex == CartTab.pickup.index) ||
      (widget.hasVapeItems && _tabIndex == CartTab.services.index);

  Widget _buildTabBody(CartTab tab) {
    if (widget.hasItems && tab == CartTab.orders) {
      return _PopulatedCartBody(
        quantity: _quantity,
        includeCutlery: _includeCutlery,
        onQuantityChanged: (value) => setState(() => _quantity = value),
        onCutleryChanged: (value) => setState(() => _includeCutlery = value),
        onAddMore: () => context.push(
          BrowseRoutes.vendorMenu(vendorId: BrowseRoutes.defaultVendorId),
        ),
        onCheckout: () => context.push(CartRoutes.checkout),
      );
    }
    if (widget.hasDineInItems && tab == CartTab.dineIn) {
      return DineInBasketBody(
        onCheckout: () => context.push(DineInCartRoutes.checkout),
      );
    }
    if (widget.hasPickupItems && tab == CartTab.pickup) {
      return PickupCartBody(
        onCheckout: () => context.push(PickupCartRoutes.checkout),
      );
    }
    if (widget.hasScheduledItems && tab == CartTab.pickup) {
      return ScheduledCartBody(
        onCheckout: () => context.push(ScheduledCartRoutes.checkout),
      );
    }
    if (widget.hasVapeItems && tab == CartTab.services) {
      return VapeCartBody(
        onCheckout: () {
          if (VapeCartData.isAgeVerified) {
            context.push(VapeCartRoutes.checkout);
          } else {
            context.push(VapeCartRoutes.ageVerify);
          }
        },
      );
    }
    return EmptyCartBody(onBrowse: widget.onBrowseVendors, tab: tab);
  }

  @override
  Widget build(BuildContext context) {
    final isDineIn = _tabIndex == CartTab.dineIn.index;
    /// Design: `rgba(44, 107, 71, 0.55)` over white → sage green.
    const dineInBg = Color(0xFF8BAE9A);

    return Scaffold(
      backgroundColor: isDineIn ? dineInBg : AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 8.h),
            child: SafeArea(
              bottom: false,
              child: _showPopulatedHeader
                  ? Row(
                      children: [
                        NavCircleBackButton(
                          onTap: widget.onBack,
                          // Figma vape cart: #1A1A1A chevron (not brand green).
                          iconColor: _tabIndex == CartTab.services.index
                              ? const Color(0xFF1A1A1A)
                              : AppColors.primary,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tabIndex == CartTab.dineIn.index
                                  ? DineInCartStrings.basket
                                  : _tabIndex == CartTab.pickup.index
                                      ? (widget.hasPickupItems
                                          ? PickupCartStrings.cart
                                          : ScheduledCartStrings.cart)
                                      : _tabIndex == CartTab.services.index
                                          ? VapeCartStrings.cart
                                          : NavigationStrings.cart,
                              style: AppTextStyles.titleSmall(
                                color: AppColors.textPrimary,
                              ).copyWith(fontSize: 18.sp),
                            ),
                            Text(
                              _tabIndex == CartTab.dineIn.index
                                  ? DineInCartData.vendorSubtitle
                                  : _tabIndex == CartTab.pickup.index
                                      ? (widget.hasPickupItems
                                          ? PickupCartData.vendor
                                          : ScheduledCartData.vendor)
                                      : _tabIndex == CartTab.services.index
                                          ? VapeCartData.vendor
                                          : NavigationData.cartVendor,
                              style: AppTextStyles.labelSmall(
                                color: AppColors.textSecondary,
                              ).copyWith(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        NavCircleBackButton(onTap: widget.onBrowseVendors),
                        SizedBox(width: 12.w),
                        Text(
                          NavigationStrings.yourCart,
                          style: AppTextStyles.titleSmall(
                            color: AppColors.primary,
                          ).copyWith(fontSize: 18.sp),
                        ),
                      ],
                    ),
            ),
          ),
          CartCategoryTabs(
            selectedIndex: _tabIndex,
            onChanged: _onTabChanged,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: CartTab.values.map(_buildTabBody).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopulatedCartBody extends StatelessWidget {
  const _PopulatedCartBody({
    required this.quantity,
    required this.includeCutlery,
    required this.onQuantityChanged,
    required this.onCutleryChanged,
    required this.onAddMore,
    required this.onCheckout,
  });

  final int quantity;
  final bool includeCutlery;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onCutleryChanged;
  final VoidCallback onAddMore;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              Text(
                NavigationStrings.yourItems,
                style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8DD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                NavigationData.cartItemName,
                                style: AppTextStyles.titleSmall().copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  height: 1.28,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                NavigationData.cartItemSubtitle,
                                style: AppTextStyles.labelSmall(
                                  color: AppColors.textSecondary,
                                ).copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.28,
                                ),
                              ),
                              const SizedBox(height: 7),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      NavigationStrings.edit,
                                      style: AppTextStyles.labelSmall(
                                        color: AppColors.primary,
                                      ).copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  begin: Alignment(-0.8, -0.6),
                                  end: Alignment(0.8, 0.8),
                                  colors: [
                                    Color(0xFF7A4A22),
                                    Color(0xFF15302B),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _QuantitySelector(
                              quantity: quantity,
                              onChanged: onQuantityChanged,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          NavigationData.cartItemPrice,
                          style: AppTextStyles.labelMedium(
                            color: AppColors.primary,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          NavigationData.cartItemOriginalPrice,
                          style: AppTextStyles.labelSmall(
                            color: AppColors.textSecondary,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                NavigationStrings.makeItCombo,
                style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 133,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: NavigationData.comboItems.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = NavigationData.comboItems[index];
                    return SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: item.imageColor,
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    begin: const Alignment(-0.8, -0.6),
                                    end: const Alignment(0.8, 0.8),
                                    colors: [
                                      item.imageColor,
                                      const Color(0xFF15302B),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE2E8DD),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.price,
                            style: AppTextStyles.caption(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8DD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      NavigationStrings.orderPreferences,
                      style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant_outlined,
                          size: 22,
                          color: Color(0xFF0F4D27),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                NavigationStrings.includeCutlery,
                                style: AppTextStyles.labelMedium().copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                NavigationStrings.includeCutlerySubtitle,
                                style: AppTextStyles.caption(
                                  color: AppColors.textSecondary,
                                ).copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: includeCutlery,
                          activeTrackColor: AppColors.primary,
                          activeThumbColor: AppColors.white,
                          inactiveThumbColor: AppColors.white,
                          inactiveTrackColor: const Color(0xFFD8DCD6),
                          trackOutlineColor: const WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: onCutleryChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 22,
                          color: Color(0xFF0F4D27),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                NavigationStrings.noteForKitchen,
                                style: AppTextStyles.labelMedium().copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                NavigationStrings.noteForKitchenSubtitle,
                                style: AppTextStyles.caption(
                                  color: AppColors.textSecondary,
                                ).copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Figma cart: Bill summary → promo → bill lines.
              Text(
                NavigationStrings.billSummary,
                style: AppTextStyles.titleSmall().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                NavigationStrings.haveAPromoCode,
                style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const PromoCodeField(),
              const SizedBox(height: 10),
              const BillSummaryCard(
                lines: NavigationData.cartBillLines,
                showCashback: true,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAddMore,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      NavigationStrings.addMore,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.primary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      NavigationStrings.checkout,
                      style: AppTextStyles.labelLarge(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE2E8DD)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : () {},
            child: Icon(
              quantity > 1 ? Icons.remove : Icons.delete_outline,
              size: 15,
              color: quantity > 1 ? AppColors.textPrimary : const Color(0xFFC0392B),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(quantity + 1),
            child: const Icon(Icons.add, size: 15, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
