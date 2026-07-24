import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/food_vendors_repository.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class VendorMenuScreen extends ConsumerStatefulWidget {
  const VendorMenuScreen({
    super.key,
    required this.vendorId,
    this.bottomNavIndex = 0,
  });

  final String vendorId;
  final int bottomNavIndex;

  @override
  ConsumerState<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends ConsumerState<VendorMenuScreen> {
  BrowseRestaurant _restaurant = BrowseData.restaurants.first;
  List<String> _sections = BrowseData.menuSections;
  List<BrowseMenuItem> _allItems = BrowseData.greenKitchenMenu;
  String _selectedSection = BrowseData.menuSections.first;
  String _menuQuery = '';
  FoodCartSummary _cart = FoodCartSummary.empty;
  bool _loading = true;
  Timer? _searchDebounce;

  List<BrowseMenuItem> get _items => _allItems
      .where((item) => item.section == _selectedSection)
      .toList();

  @override
  void initState() {
    super.initState();
    _restaurant = BrowseData.restaurantById(widget.vendorId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onMenuQueryChanged(String value) {
    _menuQuery = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _load(query: value);
    });
  }

  Future<void> _load({String? query}) async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(foodVendorsRepositoryProvider);
      final menu = await repo.fetchVendorMenu(
        widget.vendorId,
        query: query,
      );
      final cart = await repo.fetchDeliveryCart();
      if (!mounted) return;
      setState(() {
        _restaurant = menu.restaurant;
        _sections = menu.sections.isNotEmpty
            ? menu.sections
            : BrowseData.menuSections;
        _allItems = menu.items;
        if (!_sections.contains(_selectedSection) && _sections.isNotEmpty) {
          _selectedSection = _sections.first;
        }
        _cart = cart;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openItem(BrowseMenuItem item) async {
    final cartVendorId = _cart.vendorId;
    final needsReplace = cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.vendorId &&
        _cart.itemCount > 0;

    void goDetail() {
      context
          .push(
            BrowseRoutes.itemDetail(
              vendorId: widget.vendorId,
              itemId: item.id,
            ),
          )
          .then((_) {
        if (mounted) _load(query: _menuQuery);
      });
    }

    if (needsReplace) {
      showCartNewCartDialog(context, onConfirm: goDetail);
      return;
    }
    goDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrowseVendorHero(restaurant: _restaurant),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                    children: [
                      BrowseSearchBar(
                        hint: 'Search this menu…',
                        onChanged: _onMenuQueryChanged,
                      ),
                      SizedBox(height: 14.h),
                      _VendorStatsCard(restaurant: _restaurant),
                      SizedBox(height: 14.h),
                      if (_sections.isNotEmpty)
                        BrowseFilterChips(
                          options: _sections,
                          selected: _selectedSection,
                          onSelected: (v) =>
                              setState(() => _selectedSection = v),
                        ),
                      SizedBox(height: 14.h),
                      Text(
                        _selectedSection.toUpperCase(),
                        style: AppTextStyles.labelSmall(
                          color: const Color(0xFF6B7B6E),
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_items.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Text(
                            _menuQuery.trim().isEmpty
                                ? '___'
                                : 'No items found',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        ..._items.map(
                          (item) => BrowseMenuItemRow(
                            item: item,
                            gradientStart: _restaurant.gradientStart,
                            gradientEnd: _restaurant.gradientEnd,
                            onTap: () => _openItem(item),
                          ),
                        ),
                    ],
                  ),
          ),
          BrowseCartBar(
            itemCount: _cart.itemCount,
            totalLabel: _cart.totalLabel,
            onTap: () => context.goHome(tab: 2, cartHasItems: true),
          ),
        ],
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}

class _VendorStatsCard extends StatelessWidget {
  const _VendorStatsCard({required this.restaurant});

  final BrowseRestaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('${restaurant.deliveryMin} min', 'Delivery'),
      ('BHD ${restaurant.deliveryFee}', 'Fee'),
      ('BHD ${restaurant.minOrder}', 'Min order'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        children: [
          for (final (value, label) in stats)
            Expanded(
              child: Column(
                children: [
                  Text(
                    value,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                        .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    label,
                    style: AppTextStyles.caption(color: const Color(0xFF6B7B6E))
                        .copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
