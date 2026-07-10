import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
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
  bool _includeCutlery = true;

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
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        NavCircleBackButton(onTap: widget.onBack),
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
    required this.onCheckout,
  });

  final int quantity;
  final bool includeCutlery;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onCutleryChanged;
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
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            NavigationData.cartItemName,
                            style: AppTextStyles.titleSmall().copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            NavigationData.cartItemSubtitle,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.textSecondary,
                            ).copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 5),
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
                    Column(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2EB),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.coffee_outlined,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _QuantitySelector(
                          quantity: quantity,
                          onChanged: onQuantityChanged,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          NavigationData.cartItemPrice,
                          style: AppTextStyles.labelMedium(
                            color: AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
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
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: NavigationData.comboItems.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = NavigationData.comboItems[index];
                    return Container(
                      width: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: item.imageColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fastfood_outlined, size: 24),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(
                              color: AppColors.textPrimary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.price,
                                style: AppTextStyles.caption(
                                  color: AppColors.primary,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              _PreferenceRow(
                title: NavigationStrings.includeCutlery,
                trailing: Switch.adaptive(
                  value: includeCutlery,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                  activeThumbColor: AppColors.primary,
                  onChanged: onCutleryChanged,
                ),
              ),
              _PreferenceRow(
                title: NavigationStrings.noteForKitchen,
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              const BillSummaryCard(
                lines: NavigationData.cartBillLines,
                showPromo: true,
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
                    onPressed: () {},
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            label: '−',
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _QtyButton(label: '+', onTap: () => onChanged(quantity + 1)),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: onTap != null ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium().copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
