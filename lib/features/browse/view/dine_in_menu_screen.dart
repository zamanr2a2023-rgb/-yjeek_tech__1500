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
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/model/dine_in_vendors_repository.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/dine_in_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class DineInMenuScreen extends ConsumerStatefulWidget {
  const DineInMenuScreen({
    super.key,
    required this.restaurantId,
    this.bottomNavIndex = 0,
  });

  final String restaurantId;
  final int bottomNavIndex;

  @override
  ConsumerState<DineInMenuScreen> createState() => _DineInMenuScreenState();
}

class _DineInMenuScreenState extends ConsumerState<DineInMenuScreen> {
  DineInRestaurant _restaurant = DineInData.restaurants.first;
  List<String> _sections = DineInData.menuSections;
  List<BrowseMenuItem> _allItems = const [];
  String _selectedSection = DineInData.menuSections.first;
  String _menuQuery = '';
  DineInCartSummary _cart = DineInCartSummary.empty;
  bool _loading = true;
  Timer? _searchDebounce;

  /// Design: `rgba(44, 107, 71, 0.55)` over white → sage green.
  static const Color _screenBg = Color(0xFF8BAE9A);

  List<BrowseMenuItem> get _items => _allItems
      .where((item) => item.section == _selectedSection)
      .toList();

  @override
  void initState() {
    super.initState();
    _restaurant = DineInData.restaurantById(widget.restaurantId);
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
      final repo = ref.read(dineInVendorsRepositoryProvider);
      final menu = await repo.fetchVendorMenu(
        widget.restaurantId,
        query: query,
      );
      final cart = await repo.fetchDineInCart();
      if (!mounted) return;
      setState(() {
        _restaurant = menu.restaurant;
        _sections = menu.sections.isNotEmpty
            ? menu.sections
            : DineInData.menuSections;
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
        cartVendorId != widget.restaurantId &&
        _cart.itemCount > 0;

    void goDetail() {
      context
          .push(
            BrowseRoutes.dineInItemDetail(
              restaurantId: widget.restaurantId,
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
      backgroundColor: _screenBg,
      body: Column(
        children: [
          DineInVendorHero(restaurant: _restaurant),
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
                      DineInStatusCard(
                        leftTitle: _restaurant.statusLabel,
                        leftSubtitle: _restaurant.modeLabel,
                        rightTitle: 'Table ${_restaurant.tableMin}+',
                        rightSubtitle: _restaurant.entryLabel,
                      ),
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
                        style: AppTextStyles.labelSmall(color: AppColors.white)
                            .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (_items.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Text(
                            _menuQuery.trim().isEmpty
                                ? '___'
                                : 'No items found',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.white,
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < _items.length; i++) ...[
                          DineInMenuItemRow(
                            item: _items[i],
                            gradientStart: _restaurant.gradientStart,
                            gradientEnd: _restaurant.gradientEnd,
                            onTap: () => _openItem(_items[i]),
                          ),
                          if (i < _items.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: const Color(0xFFE2E8DD)
                                  .withValues(alpha: 0.55),
                            ),
                        ],
                    ],
                  ),
          ),
          DineInOrderBar(
            itemCount: _cart.itemCount,
            totalLabel: _cart.totalLabel,
            onTap: () => context.goHome(tab: 2, dineInCart: true),
          ),
        ],
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
