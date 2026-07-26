import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/live_cart_body.dart';
import 'package:yjeek_app/features/dine_in_cart/dine_in_cart_routes.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/pickup_cart/pickup_cart_routes.dart';
import 'package:yjeek_app/features/scheduled_cart/scheduled_cart_routes.dart';

class CartScreen extends ConsumerStatefulWidget {
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
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late final PageController _pageController;
  int _tabIndex = 0;
  bool _loading = true;
  bool _fetching = false;
  bool _reloadQueued = false;
  int _loadedRevision = -1;

  CartSnapshot _delivery = CartSnapshot.empty(CartOrderType.delivery);
  CartSnapshot _dineIn = CartSnapshot.empty(CartOrderType.dineIn);
  CartSnapshot _pickup = CartSnapshot.empty(CartOrderType.pickup);
  CartSnapshot _service = CartSnapshot.empty(CartOrderType.service);
  CartSnapshot? _scheduled;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.index;
    _pageController = PageController(initialPage: _tabIndex);
    // First fetch is driven by the cartRevision watch in build().
  }

  @override
  void didUpdateWidget(CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab &&
        _tabIndex != widget.initialTab.index) {
      _tabIndex = widget.initialTab.index;
      _pageController.jumpToPage(_tabIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAll({bool showSpinner = true}) async {
    if (_fetching) {
      _reloadQueued = true;
      return;
    }
    _fetching = true;
    if (showSpinner) setState(() => _loading = true);
    final repo = ref.read(cartRepositoryProvider);
    try {
      final results = await Future.wait<Object?>([
        repo.fetchCart(CartOrderType.delivery),
        repo.fetchCart(CartOrderType.dineIn),
        repo.fetchCart(CartOrderType.pickup),
        repo.fetchCart(CartOrderType.service),
        repo.fetchScheduledCart(),
      ]);
      if (!mounted) return;
      setState(() {
        _delivery = results[0]! as CartSnapshot;
        _dineIn = results[1]! as CartSnapshot;
        _pickup = results[2]! as CartSnapshot;
        _service = results[3]! as CartSnapshot;
        _scheduled = results[4] as CartSnapshot?;
        _loading = false;
      });
      _syncShellFlags();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    } finally {
      _fetching = false;
      if (_reloadQueued && mounted) {
        _reloadQueued = false;
        await _loadAll(showSpinner: false);
      }
    }
  }

  Future<void> _onRefresh() => _loadAll(showSpinner: false);

  void _syncShellFlags() {
    ref.read(shellProvider.notifier).syncCartFlags(
          delivery: _delivery.hasItems,
          dineIn: _dineIn.hasItems,
          pickup: _pickup.hasItems,
          scheduled: _scheduled?.hasItems == true,
          service: _service.hasItems,
          vape: _delivery.hasItems && _delivery.isVape,
        );
  }

  void _onTabChanged(int index) {
    if (index == _tabIndex) return;
    FocusManager.instance.primaryFocus?.unfocus();
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
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _tabIndex = index);
      widget.onCartTabChanged?.call(CartTab.values[index]);
    }
  }

  CartSnapshot _snapshotForTab(CartTab tab) {
    switch (tab) {
      case CartTab.orders:
        // Vape/Food/Electronics-on-demand share DELIVERY; scheduled electronics
        // prefers scheduled basket when present.
        if (_scheduled?.hasItems == true && !_delivery.hasItems) {
          return _scheduled!;
        }
        return _delivery;
      case CartTab.dineIn:
        return _dineIn;
      case CartTab.pickup:
        if (_pickup.hasItems) return _pickup;
        if (_scheduled?.hasItems == true) return _scheduled!;
        return _pickup;
      case CartTab.services:
        // Real services booking cart. (Vape uses DELIVERY → Orders tab.)
        return _service;
    }
  }

  CartOrderType _typeForTab(CartTab tab) {
    switch (tab) {
      case CartTab.orders:
        return CartOrderType.delivery;
      case CartTab.dineIn:
        return CartOrderType.dineIn;
      case CartTab.pickup:
        return _pickup.hasItems
            ? CartOrderType.pickup
            : CartOrderType.delivery;
      case CartTab.services:
        return CartOrderType.service;
    }
  }

  bool _tabHasItems(CartTab tab) => _snapshotForTab(tab).hasItems;

  String _vendorTitle(CartTab tab) {
    final snap = _snapshotForTab(tab);
    if (snap.vendorName.isNotEmpty) return snap.vendorName;
    return switch (tab) {
      CartTab.orders => NavigationData.cartVendor,
      CartTab.dineIn => 'Dine-in',
      CartTab.pickup => 'Pickup',
      CartTab.services => 'Services',
    };
  }

  String _headerTitle(CartTab tab) {
    return switch (tab) {
      CartTab.dineIn => 'Dine-in basket',
      CartTab.services => 'Booking',
      _ => NavigationStrings.cart,
    };
  }

  Future<void> _setCart(CartOrderType type, CartSnapshot snap) async {
    setState(() {
      switch (type) {
        case CartOrderType.delivery:
          _delivery = snap;
        case CartOrderType.dineIn:
          _dineIn = snap;
        case CartOrderType.pickup:
          _pickup = snap;
        case CartOrderType.service:
          _service = snap;
      }
    });
    _syncShellFlags();
  }

  void _setScheduled(CartSnapshot? snap) {
    setState(() => _scheduled = snap);
    _syncShellFlags();
  }

  Widget _buildLiveBody(CartTab tab) {
    final snap = _snapshotForTab(tab);
    final type = _typeForTab(tab);
    final repo = ref.read(cartRepositoryProvider);
    final isScheduledOnly =
        _scheduled != null && identical(snap, _scheduled);

    return LiveCartBody(
      cart: snap,
      showCutlery: tab == CartTab.orders &&
          !snap.isVape &&
          !snap.isElectronics &&
          !isScheduledOnly,
      showVapeCart: tab == CartTab.orders && snap.isVape,
      showDineInPreferences: tab == CartTab.dineIn,
      showPickupHeader: tab == CartTab.pickup && snap.pickup != null,
      showElectronicsCart: isScheduledOnly,
      checkoutLabel: tab == CartTab.pickup && !isScheduledOnly
          ? 'Go to checkout'
          : null,
      onQuantityChanged: (itemId, qty) async {
        if (isScheduledOnly) {
          _setScheduled(
            await repo.updateScheduledItemQuantity(
              itemId: itemId,
              quantity: qty,
            ),
          );
          return;
        }
        final next = await repo.updateItemQuantity(
          type: type,
          itemId: itemId,
          quantity: qty,
        );
        await _setCart(type, next);
      },
      onRemoveItem: (itemId) async {
        if (isScheduledOnly) {
          _setScheduled(await repo.removeScheduledItem(itemId));
          return;
        }
        final next = await repo.removeItem(type: type, itemId: itemId);
        await _setCart(type, next);
      },
      onUpsellAdd: (productId) async {
        if (isScheduledOnly) {
          _setScheduled(
            await repo.addScheduledProduct(productId: productId),
          );
          return;
        }
        final next = await repo.addProduct(type: type, productId: productId);
        await _setCart(type, next);
      },
      onApplyPromo: (code) async {
        if (isScheduledOnly) {
          try {
            _setScheduled(await repo.applyScheduledPromo(code));
          } catch (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid promo code')),
            );
          }
          return;
        }
        final next = await repo.applyPromo(type: type, code: code);
        await _setCart(type, next);
      },
      onCutleryChanged: (value) async {
        if (isScheduledOnly) return;
        final next = await repo.updatePreferences(
          type: type,
          includeCutlery: value,
        );
        await _setCart(type, next);
      },
      onKitchenNote: (note) async {
        if (isScheduledOnly) return;
        final next = await repo.updatePreferences(
          type: type,
          kitchenNote: note,
        );
        await _setCart(type, next);
      },
      onPartySizeChanged: (partySize) async {
        final next = await repo.updatePreferences(
          type: type,
          partySize: partySize,
        );
        await _setCart(type, next);
      },
      onSeatingChanged: (seating) async {
        final next = await repo.updatePreferences(
          type: type,
          seatingPreference: seating,
        );
        await _setCart(type, next);
      },
      onSpecialOccasionChanged: (enabled) async {
        final next = await repo.updatePreferences(
          type: type,
          specialOccasionEnabled: enabled,
        );
        await _setCart(type, next);
      },
      onEditItem: (item) {
        final vendorId = snap.vendorId;
        if (vendorId == null || vendorId.isEmpty || item.productId.isEmpty) {
          return;
        }
        if (tab == CartTab.dineIn) {
          context.push(
            BrowseRoutes.dineInItemDetail(
              restaurantId: vendorId,
              itemId: item.productId,
            ),
          );
          return;
        }
        if (widget.hasVapeItems && tab == CartTab.orders) {
          context.push(
            BrowseRoutes.vapeProductDetail(
              storeId: vendorId,
              productId: item.productId,
            ),
          );
          return;
        }
        context.push(
          BrowseRoutes.itemDetail(
            vendorId: vendorId,
            itemId: item.productId,
          ),
        );
      },
      onAddMore: () {
        final vendorId = snap.vendorId;
        if (vendorId != null && vendorId.isNotEmpty) {
          context.push(BrowseRoutes.vendorMenu(vendorId: vendorId));
          return;
        }
        widget.onBrowseVendors();
      },
      onCheckout: () {
        FocusManager.instance.primaryFocus?.unfocus();
        switch (tab) {
          case CartTab.dineIn:
            context.push(DineInCartRoutes.checkout);
          case CartTab.pickup:
            if (_pickup.hasItems) {
              context.push(PickupCartRoutes.checkout);
            } else {
              context.push(ScheduledCartRoutes.checkout);
            }
          case CartTab.services:
            context.push(CartRoutes.checkout);
          case CartTab.orders:
            if (isScheduledOnly) {
              context.push(ScheduledCartRoutes.checkout);
            } else {
              context.push(CartRoutes.checkout);
            }
        }
      },
    );
  }

  Widget _buildTabBody(CartTab tab) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      child: !_tabHasItems(tab)
          ? LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: EmptyCartBody(
                      onBrowse: widget.onBrowseVendors,
                      tab: tab,
                    ),
                  ),
                );
              },
            )
          : _buildLiveBody(tab),
    );
  }

  bool get _showPopulatedHeader => _tabHasItems(CartTab.values[_tabIndex]);

  @override
  Widget build(BuildContext context) {
    // The cart tab stays alive inside an IndexedStack, so refetch whenever the
    // shell signals the cart changed (item added elsewhere, tab reopened).
    final revision = ref.watch(shellProvider.select((s) => s.cartRevision));
    if (revision != _loadedRevision) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final latest = ref.read(shellProvider).cartRevision;
        if (latest == _loadedRevision) return;
        _loadedRevision = latest;
        // `_loading` already starts true, so the first fetch shows the spinner
        // and later refreshes keep the current content visible.
        _loadAll(showSpinner: false);
      });
    }

    final isDineIn = _tabIndex == CartTab.dineIn.index;
    const dineInBg = Color(0xFF8BAE9A);
    final tab = CartTab.values[_tabIndex];

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
                          onTap: widget.onBack ?? widget.onBrowseVendors,
                          iconColor: AppColors.primary,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _headerTitle(tab),
                              style: AppTextStyles.titleSmall(
                                color: AppColors.textPrimary,
                              ).copyWith(fontSize: 18.sp),
                            ),
                            Text(
                              _vendorTitle(tab),
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
          CartCategoryTabs(selectedIndex: _tabIndex, onChanged: _onTabChanged),
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
