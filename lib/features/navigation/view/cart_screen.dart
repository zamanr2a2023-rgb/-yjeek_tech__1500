import 'dart:async';

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
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/view/widgets/live_cart_body.dart';
import 'package:yjeek_app/features/dine_in_cart/dine_in_cart_routes.dart';
import 'package:yjeek_app/features/geofence/model/active_geofence_order_context.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/pickup_cart/pickup_cart_routes.dart';
import 'package:yjeek_app/features/browse/model/pharmacy_order_modes.dart';
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';
import 'package:yjeek_app/features/scheduled_cart/scheduled_cart_routes.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

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
  bool _openingOutOfRange = false;

  CartSnapshot _delivery = CartSnapshot.empty(CartOrderType.delivery);
  CartSnapshot _dineIn = CartSnapshot.empty(CartOrderType.dineIn);
  CartSnapshot _pickup = CartSnapshot.empty(CartOrderType.pickup);
  CartSnapshot _service = CartSnapshot.empty(CartOrderType.service);
  CartSnapshot? _scheduled;
  List<Map<String, dynamic>> _scheduledRetailDeliveryOptions = const [];

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
    if (!ref.read(storageServiceProvider).hasSession) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
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
      _syncPharmacyDeliverNowSession(_delivery);
      await _refreshDeliveryTierOptions();
      _syncShellFlags();
      _scheduleOutOfRangeScreen(_delivery);
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

  void _syncPharmacyDeliverNowSession(CartSnapshot delivery) {
    if (!delivery.isPharmacyStore) return;
    final vendorId = delivery.vendorId;
    if (vendorId == null || vendorId.isEmpty) return;
    final current = ref.read(pharmacySessionProvider);
    if (current != null && current.matches(vendorId)) return;
    ref.read(pharmacySessionProvider.notifier).state = PharmacySession(
      vendorId: vendorId,
      mode: PharmacyDeliveryMode.deliverNow,
    );
  }

  bool _ordersTabShowsScheduledBasket() {
    if (_scheduled?.hasItems != true) return false;
    final focusScheduled = ref.read(shellProvider).focusScheduledCart;
    return focusScheduled || !_delivery.hasItems;
  }

  Future<void> _refreshDeliveryTierOptions() async {
    final repo = ref.read(cartRepositoryProvider);
    if (_ordersTabShowsScheduledBasket()) {
      final probe = await repo.fetchScheduledCartDetailed();
      if (!mounted) return;
      final synced = syncScheduledDeliveryUiSpeed(ref, probe.deliveryOptions);
      final speedId =
          synced ?? ref.read(scheduledDeliveryUiSpeedProvider) ?? 'next-day';
      final detailed = await repo.fetchScheduledCartDetailed(
        deliverySpeed: deliverySpeedApiValue(speedId),
      );
      if (!mounted) return;
      setState(() {
        _scheduled = detailed.cart;
        _scheduledRetailDeliveryOptions = detailed.deliveryOptions.isNotEmpty
            ? detailed.deliveryOptions
            : probe.deliveryOptions;
      });
      return;
    }

    final pharmacySession = ref.read(pharmacySessionProvider);
    if (!_delivery.showsScheduledDeliveryTierPicker(pharmacySession)) {
      if (!mounted) return;
      setState(() => _scheduledRetailDeliveryOptions = const []);
      return;
    }
    final probe = await repo.fetchCartDetailed(CartOrderType.delivery);
    if (!mounted) return;
    final synced = syncScheduledDeliveryUiSpeed(ref, probe.deliveryOptions);
    final speedId =
        synced ?? ref.read(scheduledDeliveryUiSpeedProvider) ?? 'next-day';
    final detailed = await repo.fetchCartDetailed(
      CartOrderType.delivery,
      deliverySpeed: deliverySpeedApiValue(speedId),
    );
    if (!mounted) return;
    setState(() {
      _delivery = detailed.cart;
      _scheduledRetailDeliveryOptions = detailed.deliveryOptions.isNotEmpty
          ? detailed.deliveryOptions
          : probe.deliveryOptions;
    });
  }

  Future<void> _onScheduledDeliveryTierChanged(String uiId) async {
    final methods = scheduledDeliveryMethodsFromApi(_scheduledRetailDeliveryOptions);
    ScheduledDeliveryMethod? method;
    for (final m in methods) {
      if (m.id == uiId) {
        method = m;
        break;
      }
    }
    if (method != null && !method.available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            method.unavailableNote ??
                'This delivery option is not available right now',
          ),
        ),
      );
      return;
    }
    ref.read(scheduledDeliveryUiSpeedProvider.notifier).state = uiId;
    final repo = ref.read(cartRepositoryProvider);
    if (_ordersTabShowsScheduledBasket()) {
      final detailed = await repo.fetchScheduledCartDetailed(
        deliverySpeed: deliverySpeedApiValue(uiId),
      );
      if (!mounted) return;
      setState(() {
        _scheduled = detailed.cart;
        if (detailed.deliveryOptions.isNotEmpty) {
          _scheduledRetailDeliveryOptions = detailed.deliveryOptions;
        }
      });
      return;
    }
    final detailed = await repo.fetchCartDetailed(
      CartOrderType.delivery,
      deliverySpeed: deliverySpeedApiValue(uiId),
    );
    if (!mounted) return;
    setState(() {
      _delivery = detailed.cart;
      if (detailed.deliveryOptions.isNotEmpty) {
        _scheduledRetailDeliveryOptions = detailed.deliveryOptions;
      }
    });
  }

  void _syncShellFlags() {
    ref
        .read(shellProvider.notifier)
        .syncCartFlags(
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
    final focusScheduled = ref.read(shellProvider).focusScheduledCart;
    switch (tab) {
      case CartTab.orders:
        // Scheduled grocery/fashion/electronics share the Orders tab with food
        // delivery. Prefer scheduled after a scheduled add, or when delivery
        // is empty.
        if (_scheduled?.hasItems == true &&
            (focusScheduled || !_delivery.hasItems)) {
          return _scheduled!;
        }
        return _delivery;
      case CartTab.dineIn:
        return _dineIn;
      case CartTab.pickup:
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
        return CartOrderType.pickup;
      case CartTab.services:
        return CartOrderType.service;
    }
  }

  bool _tabHasItems(CartTab tab) => _snapshotForTab(tab).hasItems;

  String _vendorTitle(CartTab tab) {
    final snap = _snapshotForTab(tab);
    if (snap.vendorName.isNotEmpty) return snap.vendorName;
    return switch (tab) {
      CartTab.orders => 'Your cart',
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

  /// Out of range belongs on the delivery address screen, not as a cart line.
  void _scheduleOutOfRangeScreen(CartSnapshot cart) {
    if (!cart.hasItems || cart.delivery?.outOfRange != true) return;
    if (_tabIndex != CartTab.orders.index) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openOutOfRangeScreen(cart);
    });
  }

  Future<void> _openOutOfRangeScreen(CartSnapshot cart) async {
    if (!mounted || _openingOutOfRange) return;
    if (!cart.hasItems || cart.delivery?.outOfRange != true) return;
    if (_tabIndex != CartTab.orders.index) return;
    _openingOutOfRange = true;
    try {
      final vendorId = cart.vendorId;
      if (vendorId != null && vendorId.isNotEmpty) {
        final range = await checkDeliveryRange(
          addresses: ref.read(addressesRepositoryProvider),
          vendorId: vendorId,
          failClosed: false,
        );
        if (!mounted) return;
        if (range.allowsDelivery) return;
        await pushOutOfDelivery(context, address: range.address);
        return;
      }
      await pushOutOfDelivery(context);
    } finally {
      if (mounted) _openingOutOfRange = false;
    }
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
    final isScheduledOnly = _scheduled != null && identical(snap, _scheduled);
    final pharmacySession = ref.watch(pharmacySessionProvider);
    final scheduledRetail =
        tab == CartTab.orders &&
        (isScheduledOnly ||
            snap.showsScheduledDeliveryTierPicker(pharmacySession));
    final deliverySpeedUi = ref.watch(scheduledDeliveryUiSpeedProvider);

    return LiveCartBody(
      cart: snap,
      initialPromoCode: null,
      showCutlery:
          tab == CartTab.orders &&
          !snap.isVape &&
          !snap.isElectronics &&
          !snap.isPharmacyStore &&
          !isScheduledOnly &&
          !scheduledRetail,
      showScheduledDeliveryMethods: scheduledRetail,
      scheduledDeliveryMethods: scheduledDeliveryMethodsFromApi(
        _scheduledRetailDeliveryOptions,
      ),
      selectedScheduledDeliveryId: deliverySpeedUi,
      onScheduledDeliveryChanged: scheduledRetail
          ? _onScheduledDeliveryTierChanged
          : null,
      showVapeCart: tab == CartTab.orders && snap.isVape,
      showDineInPreferences: tab == CartTab.dineIn,
      showPickupHeader: tab == CartTab.pickup && snap.pickup != null,
      showElectronicsCart: isScheduledOnly,
      checkoutLabel: tab == CartTab.pickup && !isScheduledOnly
          ? 'Go to checkout'
          : null,
      onLineQuantityDelta: (item, delta) async {
        if (isScheduledOnly) {
          _setScheduled(
            await repo.bumpScheduledCartLineQuantity(item: item, delta: delta),
          );
          return;
        }
        final next = await repo.bumpCartLineQuantity(
          type: type,
          item: item,
          delta: delta,
        );
        await _setCart(type, next);
        if (type == CartOrderType.delivery &&
            next.showsScheduledDeliveryTierPicker(
              ref.read(pharmacySessionProvider),
            )) {
          await _refreshDeliveryTierOptions();
        }
      },
      onRemoveItem: (itemId) async {
        if (isScheduledOnly) {
          _setScheduled(await repo.removeScheduledItem(itemId));
          return;
        }
        final next = await repo.removeItem(type: type, itemId: itemId);
        await _setCart(type, next);
        if (type == CartOrderType.delivery &&
            next.showsScheduledDeliveryTierPicker(
              ref.read(pharmacySessionProvider),
            )) {
          await _refreshDeliveryTierOptions();
        }
      },
      onUpsellAdd: (productId) async {
        if (isScheduledOnly) {
          _setScheduled(await repo.addScheduledProduct(productId: productId));
          return;
        }
        final next = await repo.addProduct(
          type: type,
          productId: productId,
          vendorId: snap.vendorId,
          geofenceTriggerId: resolveGeofenceTriggerId(
            ref,
            vendorId: snap.vendorId,
            orderType: type.apiValue,
          ),
        );
        await _setCart(type, next);
      },
      onApplyPromo: (code) async {
        if (isScheduledOnly) {
          try {
            _setScheduled(await repo.applyScheduledPromo(code));
          } catch (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Invalid promo code')));
          }
          return;
        }
        final next = await repo.applyPromo(type: type, code: code);
        await _setCart(type, next);
        if (type == CartOrderType.delivery &&
            next.showsScheduledDeliveryTierPicker(
              ref.read(pharmacySessionProvider),
            )) {
          await _refreshDeliveryTierOptions();
        }
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
          clearSpecialOccasionPackage: !enabled,
        );
        await _setCart(type, next);
      },
      onOccasionPackageSelected: (packageId) async {
        final next = await repo.updatePreferences(
          type: type,
          specialOccasionPackageId: packageId,
          clearSpecialOccasionPackage: packageId == null,
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
        final slug = snap.storeTypeSlug?.trim().toLowerCase() ?? '';
        const variantRetailSlugs = {
          'fashion',
          'electronics',
          'flowers',
          'pharmacy',
        };
        final variantLine = (item.variantId ?? '').isNotEmpty;
        if (variantLine ||
            snap.usesScheduledDeliveryMethods ||
            variantRetailSlugs.contains(slug)) {
          context.push(
            BrowseRoutes.electronicsProductDetail(
              storeId: vendorId,
              productId: item.productId,
              variantId: item.variantId,
              quantity: item.quantity,
            ),
          );
          return;
        }
        context.push(
          BrowseRoutes.itemDetail(vendorId: vendorId, itemId: item.productId),
        );
      },
      onAddMore: () {
        final vendorId = snap.vendorId;
        if (vendorId != null && vendorId.isNotEmpty) {
          if (tab == CartTab.services) {
            context.push(BrowseRoutes.servicesProvider(providerId: vendorId));
            return;
          }
          context.push(
            BrowseRoutes.vendorMenu(
              vendorId: vendorId,
              tab: 2,
              cartType: tab == CartTab.pickup ? 'pickup' : null,
              returnTo: '${RouteNames.home}?tab=2',
            ),
          );
          return;
        }
        widget.onBrowseVendors();
      },
      onCheckout: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        if (isScheduledOnly) {
          final fresh = await repo.fetchScheduledCart();
          _setScheduled(fresh);
          if (fresh == null || !fresh.hasItems) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(NavigationStrings.cartEmptyTitle)),
            );
            return;
          }
        } else {
          final fresh = await repo.fetchCart(type);
          await _setCart(type, fresh);
          if (!fresh.hasItems) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(NavigationStrings.cartEmptyTitle)),
            );
            return;
          }
        }
        if (!mounted) return;
        final scheduledRetailCheckout =
            tab == CartTab.orders &&
            (isScheduledOnly ||
                snap.showsScheduledDeliveryTierPicker(
                  ref.read(pharmacySessionProvider),
                ));
        if (scheduledRetailCheckout) {
          await _refreshDeliveryTierOptions();
          if (!mounted) return;
          final methods =
              scheduledDeliveryMethodsFromApi(_scheduledRetailDeliveryOptions);
          final ui = ref.read(scheduledDeliveryUiSpeedProvider);
          final tierOk = methods.any((m) => m.id == ui && m.available);
          if (!tierOk) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please choose an available delivery method'),
              ),
            );
            return;
          }
        }
        switch (tab) {
          case CartTab.dineIn:
            context.push(DineInCartRoutes.checkout);
          case CartTab.pickup:
            context.push(PickupCartRoutes.checkout);
          case CartTab.services:
            context.push(ServicesBookingRoutes.booking);
          case CartTab.orders:
            final vendorId = snap.vendorId;
            if (vendorId != null && vendorId.isNotEmpty) {
              final range = await checkDeliveryRange(
                addresses: ref.read(addressesRepositoryProvider),
                vendorId: vendorId,
                failClosed: true,
              );
              if (!mounted) return;
              if (!range.allowsDelivery) {
                if (range.outcome == DeliveryRangeOutcome.noAddress) {
                  unawaited(context.push(CartRoutes.changeAddress));
                  return;
                }
                unawaited(pushOutOfDelivery(context, address: range.address));
                return;
              }
            }
            if (isScheduledOnly) {
              context.push(ScheduledCartRoutes.checkout);
            } else if (snap.isVape) {
              context.push(VapeCartRoutes.checkout);
            } else {
              context.push(CartRoutes.checkout);
            }
        }
      },
    );
  }

  Future<void> _signInForCart() async {
    if (!await requireLogin(context, ref)) return;
    if (!mounted) return;
    await _loadAll();
  }

  Widget _buildTabBody(CartTab tab) {
    final loggedIn = ref.watch(storageServiceProvider).hasSession;
    if (!loggedIn) {
      return GuestSignInEmptyState(
        message: NavigationStrings.signInToViewYourCart,
        onSignIn: _signInForCart,
      );
    }
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
    // Rebuild Orders body when focus switches between food vs scheduled basket.
    ref.watch(shellProvider.select((s) => s.focusScheduledCart));
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

    final tab = CartTab.values[_tabIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigateBack(context);
      },
      child: Scaffold(
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
                        NavCircleBackButton(
                          onTap: widget.onBack ?? () => navigateBack(context),
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
                        NavCircleBackButton(
                          onTap: widget.onBack ?? () => navigateBack(context),
                        ),
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
      ),
    );
  }
}
