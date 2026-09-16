import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/services/location_service.dart';
import 'package:yjeek_app/features/geofence/model/geofence_models.dart';
import 'package:yjeek_app/features/geofence/service/geofence_session_controller.dart';
import 'package:yjeek_app/features/geofence/view/geofence_offer_screen.dart';
import 'package:yjeek_app/features/home/view/home_screen.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/view/account_screen.dart';
import 'package:yjeek_app/features/navigation/view/cart_screen.dart';
import 'package:yjeek_app/features/navigation/view/orders_screen.dart';
import 'package:yjeek_app/features/navigation/view/wallet_screen.dart';
import 'package:yjeek_app/features/ui_content/view/ui_banner_widgets.dart';
import 'package:yjeek_app/l10n/locale_controller.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    this.initialIndex = 0,
    this.cartHasItems = false,
    this.emptyCart = false,
    this.dineInHasItems = false,
    this.scheduledHasItems = false,
    this.pickupHasItems = false,
    this.vapeHasItems = false,
  });

  final int initialIndex;
  final bool cartHasItems;
  final bool emptyCart;
  final bool dineInHasItems;
  final bool scheduledHasItems;
  final bool pickupHasItems;
  final bool vapeHasItems;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  ProviderSubscription<GeofenceEnterResult?>? _unlockSub;
  ProviderSubscription<LocationPermissionOutcome?>? _locationPromptSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_applyInitialTab);
    Future.microtask(_startGeofenceWatcher);
    _unlockSub = ref.listenManual(geofenceLastUnlockProvider, (prev, next) {
      if (next == null || next.alreadyTriggered) return;
      if (!mounted) return;
      final code = next.promoCode;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              code.isEmpty
                  ? 'Nearby offer unlocked at ${next.vendorName}'
                  : 'Offer unlocked: $code',
            ),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                context.push(
                  geofenceOfferLocation(
                    triggerId: next.trigger.id,
                    promoCode: next.promoCode,
                    campaignId: next.campaignId,
                    vendorName: next.vendorName,
                    expiresAt: next.trigger.expiresAt?.toIso8601String(),
                  ),
                );
              },
            ),
          ),
        );
      ref.read(geofenceLastUnlockProvider.notifier).state = null;
    });
    _locationPromptSub = ref.listenManual(geofenceLocationPromptProvider, (
      prev,
      next,
    ) {
      if (next == null || !mounted) return;
      final message = switch (next) {
        LocationPermissionOutcome.serviceDisabled =>
          'Turn on Location to unlock nearby offers',
        LocationPermissionOutcome.deniedForever =>
          'Location permission is blocked. Enable it in Settings',
        LocationPermissionOutcome.denied =>
          'Allow location access to unlock nearby offers',
        LocationPermissionOutcome.granted => null,
      };
      if (message == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: next == LocationPermissionOutcome.denied
                  ? 'Allow'
                  : 'Settings',
              onPressed: () {
                unawaited(
                  ref
                      .read(geofenceSessionControllerProvider)
                      .retryPermissionFromSettings(),
                );
              },
            ),
          ),
        );
      ref.read(geofenceLocationPromptProvider.notifier).state = null;
    });
  }

  void _startGeofenceWatcher() {
    if (!mounted) return;
    final storage = ref.read(storageServiceProvider);
    if (!storage.hasSession) return;
    ref.read(geofenceSessionControllerProvider).start();
  }

  @override
  void dispose() {
    _unlockSub?.close();
    _locationPromptSub?.close();
    WidgetsBinding.instance.removeObserver(this);
    try {
      ref.read(geofenceSessionControllerProvider).stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      invalidateCmsBanners(ref);
      ref.invalidate(homeFeedProvider);
      final storage = ref.read(storageServiceProvider);
      if (storage.hasSession) {
        ref.read(geofenceSessionControllerProvider).start();
        unawaited(ref.read(geofenceSessionControllerProvider).scan());
      }
    } else if (state == AppLifecycleState.paused) {
      ref.read(geofenceSessionControllerProvider).stop();
    }
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex ||
        oldWidget.cartHasItems != widget.cartHasItems ||
        oldWidget.emptyCart != widget.emptyCart ||
        oldWidget.dineInHasItems != widget.dineInHasItems ||
        oldWidget.scheduledHasItems != widget.scheduledHasItems ||
        oldWidget.pickupHasItems != widget.pickupHasItems ||
        oldWidget.vapeHasItems != widget.vapeHasItems) {
      Future.microtask(_applyInitialTab);
    }
  }

  void _applyInitialTab() {
    if (!mounted) return;
    final notifier = ref.read(shellProvider.notifier);
    if (widget.dineInHasItems) {
      notifier.openDineInCartWithItems();
    } else if (widget.vapeHasItems) {
      notifier.openVapeCartWithItems();
    } else if (widget.pickupHasItems) {
      notifier.openPickupCartWithItems();
    } else if (widget.scheduledHasItems) {
      notifier.openScheduledCartWithItems();
    } else if (widget.cartHasItems) {
      notifier.openCartWithItems();
    } else if (widget.emptyCart) {
      notifier.openEmptyCart();
    } else {
      notifier.setTab(widget.initialIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shell = ref.watch(shellProvider);
    ref.watch(localeControllerProvider);
    final notifier = ref.read(shellProvider.notifier);

    final pages = [
      const HomeScreen(),
      OrdersScreen(onReorder: notifier.openCartWithItems),
      CartScreen(
        hasItems: shell.cartHasItems,
        hasDineInItems: shell.dineInHasItems,
        hasScheduledItems: shell.scheduledHasItems,
        hasPickupItems: shell.pickupHasItems,
        hasVapeItems: shell.vapeHasItems,
        initialTab: shell.cartTab,
        onBrowseVendors: notifier.browseVendors,
        onBack: () {
          final returnPath = shell.cartReturnPath;
          if (returnPath != null && returnPath.isNotEmpty) {
            notifier.setCartReturnPath(null);
            context.go(returnPath);
            return;
          }
          // Opened cart from bottom nav (or no saved browse path) — previous tab.
          notifier.leaveCart();
        },
        onCartTabChanged: notifier.setCartTab,
      ),
      const WalletScreen(showBottomNav: true),
      const AccountScreen(),
    ];

    return UiAppOpenPopupHost(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: shell.currentIndex,
          children: pages,
        ),
        bottomNavigationBar: HomeBottomNavBar(
          currentIndex: shell.currentIndex,
          onTap: notifier.setTab,
        ),
      ),
    );
  }
}
