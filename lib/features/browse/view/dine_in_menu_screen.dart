import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/browse_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart' show DineInRestaurant;
import 'package:yjeek_app/features/browse/model/dine_in_vendors_repository.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/dine_in_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
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
  DineInRestaurant? _restaurant;
  List<String> _sections = const [];
  List<BrowseMenuItem> _allItems = const [];
  String _selectedSection = '';
  String _menuQuery = '';
  DineInCartSummary _cart = DineInCartSummary.empty;
  bool _loading = true;
  bool _loadedOnce = false;
  String? _addingItemId;
  Timer? _searchDebounce;

  /// Design: `rgba(44, 107, 71, 0.55)` over white → sage green.
  static const Color _screenBg = AppColors.background;

  List<BrowseMenuItem> get _items => _allItems
      .where((item) => item.section == _selectedSection)
      .toList();

  @override
  void initState() {
    super.initState();
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
        _sections = menu.sections;
        _allItems = menu.items;
        if (!_sections.contains(_selectedSection) && _sections.isNotEmpty) {
          _selectedSection = _sections.first;
        }
        _cart = cart;
        _loading = false;
        _loadedOnce = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _restaurant = null;
        _sections = const [];
        _allItems = const [];
        _selectedSection = '';
        _loading = false;
        _loadedOnce = true;
      });
    }
  }

  Future<void> _onItemAction(BrowseMenuItem item) async {
    if (item.hasModifiers) {
      await _openItem(item);
      return;
    }
    await _addItemDirectly(item);
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

  Future<void> _addItemDirectly(BrowseMenuItem item) async {
    if (_addingItemId != null) return;
    if (!await requireLogin(context, ref)) return;

    final cartVendorId = _cart.vendorId;
    final needsReplace = cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.restaurantId &&
        _cart.itemCount > 0;

    Future<void> doAdd({bool replace = false}) async {
      setState(() => _addingItemId = item.id);
      final result = await ref.read(dineInVendorsRepositoryProvider).addToCart(
            productId: item.id,
            quantity: 1,
            replaceCart: replace,
          );
      if (!mounted) return;
      setState(() => _addingItemId = null);

      if (result.ok) {
        ref.read(shellProvider.notifier).markCartUpdated(dineIn: true);
        try {
          final cart =
              await ref.read(dineInVendorsRepositoryProvider).fetchDineInCart();
          if (mounted) setState(() => _cart = cart);
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.localizedName} added to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      }
      if (result.vendorConflict) {
        showCartNewCartDialog(
          context,
          onConfirm: () => doAdd(replace: true),
        );
        return;
      }
      if (await redirectToLoginIfAuthError(context, ref, result.message)) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Could not add to cart')),
      );
    }

    if (needsReplace) {
      showCartNewCartDialog(context, onConfirm: () => doAdd(replace: true));
      return;
    }
    await doAdd();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce && _loading) {
      return Scaffold(
        backgroundColor: _screenBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }
    final restaurant = _restaurant;
    if (restaurant == null) {
      return Scaffold(
        backgroundColor: _screenBg,
        body: Center(
          child: Text(
            'Could not load this menu',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
        ),
        bottomNavigationBar: ShellBottomNavBar(
          currentIndex: widget.bottomNavIndex,
        ),
      );
    }
    return Scaffold(
      backgroundColor: _screenBg,
      body: Column(
        children: [
          DineInVendorHero(restaurant: restaurant),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                    children: [
                      BrowseSearchBar(
                        hint: BrowseStrings.searchThisMenu,
                        onChanged: _onMenuQueryChanged,
                      ),
                      SizedBox(height: 14.h),
                      DineInStatusCard(
                        leftTitle: restaurant.statusLabel,
                        leftSubtitle: restaurant.modeLabel,
                        rightTitle: 'Table ${restaurant.tableMin}+',
                        rightSubtitle: restaurant.entryLabel,
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
                            gradientStart: restaurant.gradientStart,
                            gradientEnd: restaurant.gradientEnd,
                            onTap: () => _openItem(_items[i]),
                            onAdd: () => _onItemAction(_items[i]),
                            isAdding: _addingItemId == _items[i].id,
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
            onTap: () {
              ref.read(shellProvider.notifier).openDineInCartWithItems();
              context.goHome(tab: 2, dineInCart: true);
            },
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: widget.bottomNavIndex,
        onTap: (index) {
          if (index == 2) {
            ref.read(shellProvider.notifier).openDineInCartWithItems();
            context.goHome(tab: 2, dineInCart: true);
            return;
          }
          if (index == 0) {
            context.goHome(tab: 0);
            return;
          }
          if (index == widget.bottomNavIndex) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goHome(tab: index);
            }
            return;
          }
          context.goHome(tab: index);
        },
      ),
    );
  }
}
