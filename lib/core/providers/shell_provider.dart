import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class ShellState {
  const ShellState({
    this.currentIndex = 0,
    this.previousIndex = 0,
    this.cartHasItems = false,
    this.dineInHasItems = false,
    this.scheduledHasItems = false,
    this.pickupHasItems = false,
    this.vapeHasItems = false,
    this.focusScheduledCart = false,
    this.cartTab = CartTab.orders,
    this.cartReturnPath,
    this.cartRevision = 0,
  });

  final int currentIndex;
  final int previousIndex;
  final bool cartHasItems;
  final bool dineInHasItems;
  final bool scheduledHasItems;
  final bool pickupHasItems;
  final bool vapeHasItems;

  /// When true, Orders tab shows the scheduled (grocery/fashion/electronics)
  /// basket even if a food delivery cart also has items.
  final bool focusScheduledCart;
  final CartTab cartTab;
  final String? cartReturnPath;

  /// Bumped whenever the cart may have changed, so the cart tab refetches.
  final int cartRevision;

  ShellState copyWith({
    int? currentIndex,
    int? previousIndex,
    bool? cartHasItems,
    bool? dineInHasItems,
    bool? scheduledHasItems,
    bool? pickupHasItems,
    bool? vapeHasItems,
    bool? focusScheduledCart,
    CartTab? cartTab,
    String? cartReturnPath,
    bool clearCartReturnPath = false,
    int? cartRevision,
  }) {
    return ShellState(
      currentIndex: currentIndex ?? this.currentIndex,
      previousIndex: previousIndex ?? this.previousIndex,
      cartHasItems: cartHasItems ?? this.cartHasItems,
      dineInHasItems: dineInHasItems ?? this.dineInHasItems,
      scheduledHasItems: scheduledHasItems ?? this.scheduledHasItems,
      pickupHasItems: pickupHasItems ?? this.pickupHasItems,
      vapeHasItems: vapeHasItems ?? this.vapeHasItems,
      focusScheduledCart: focusScheduledCart ?? this.focusScheduledCart,
      cartTab: cartTab ?? this.cartTab,
      cartReturnPath: clearCartReturnPath
          ? null
          : (cartReturnPath ?? this.cartReturnPath),
      cartRevision: cartRevision ?? this.cartRevision,
    );
  }
}

class ShellNotifier extends StateNotifier<ShellState> {
  ShellNotifier([ShellState? initial]) : super(initial ?? const ShellState());

  int get _nextRevision => state.cartRevision + 1;

  /// Forces the cart tab to refetch from the API on its next build.
  void markCartDirty() {
    state = state.copyWith(cartRevision: _nextRevision);
  }

  void setTab(int index) {
    if (index == state.currentIndex) return;
    state = state.copyWith(
      previousIndex: state.currentIndex,
      currentIndex: index,
      // Bottom-nav switches never restore a browse return path — only goHome
      // (add-to-cart / cart icon) sets cartReturnPath for Cart back.
      clearCartReturnPath: true,
      cartRevision: index == 2 ? _nextRevision : null,
    );
  }

  void setCartReturnPath(String? path) {
    state = state.copyWith(
      cartReturnPath: path,
      clearCartReturnPath: path == null,
    );
  }

  void addToCart() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      cartHasItems: true,
      focusScheduledCart: false,
      currentIndex: 2,
      cartTab: CartTab.orders,
      cartRevision: _nextRevision,
    );
  }

  void clearCart() {
    state = state.copyWith(
      cartHasItems: false,
      dineInHasItems: false,
      scheduledHasItems: false,
      pickupHasItems: false,
      vapeHasItems: false,
      focusScheduledCart: false,
    );
  }

  /// Leaves the cart tab without clearing items — returns to prior screen/tab.
  void leaveCart() {
    state = state.copyWith(
      currentIndex: state.previousIndex == 2 ? 0 : state.previousIndex,
      clearCartReturnPath: true,
    );
  }

  void browseVendors() {
    state = state.copyWith(
      currentIndex: 0,
      cartHasItems: false,
      dineInHasItems: false,
      scheduledHasItems: false,
      pickupHasItems: false,
      vapeHasItems: false,
      focusScheduledCart: false,
      clearCartReturnPath: true,
    );
  }

  void openCartWithItems() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      cartHasItems: true,
      focusScheduledCart: false,
      currentIndex: 2,
      cartTab: CartTab.orders,
      cartRevision: _nextRevision,
    );
  }

  void openEmptyCart() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      cartHasItems: false,
      dineInHasItems: false,
      scheduledHasItems: false,
      pickupHasItems: false,
      vapeHasItems: false,
      focusScheduledCart: false,
      currentIndex: 2,
      cartTab: CartTab.orders,
      cartRevision: _nextRevision,
    );
  }

  void openDineInCartWithItems() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      dineInHasItems: true,
      focusScheduledCart: false,
      currentIndex: 2,
      cartTab: CartTab.dineIn,
      cartRevision: _nextRevision,
    );
  }

  void openScheduledCartWithItems() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      scheduledHasItems: true,
      focusScheduledCart: true,
      currentIndex: 2,
      // Grocery / fashion / electronics scheduled basket lives under Orders.
      cartTab: CartTab.orders,
      cartRevision: _nextRevision,
    );
  }

  void openPickupCartWithItems() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      pickupHasItems: true,
      focusScheduledCart: false,
      currentIndex: 2,
      cartTab: CartTab.pickup,
      cartRevision: _nextRevision,
    );
  }

  void openVapeCartWithItems() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      cartHasItems: true,
      vapeHasItems: true,
      focusScheduledCart: false,
      currentIndex: 2,
      // Vape uses DELIVERY cart → Orders tab (Services tab = SERVICE bookings).
      cartTab: CartTab.orders,
      cartRevision: _nextRevision,
    );
  }

  /// Sync tab badges from real API cart counts.
  void syncCartFlags({
    required bool delivery,
    required bool dineIn,
    required bool pickup,
    required bool scheduled,
    required bool service,
    bool? vape,
  }) {
    state = state.copyWith(
      cartHasItems: delivery,
      dineInHasItems: dineIn,
      pickupHasItems: pickup,
      scheduledHasItems: scheduled,
      vapeHasItems: vape ?? state.vapeHasItems,
      focusScheduledCart:
          scheduled ? state.focusScheduledCart : false,
    );
  }

  void setCartTab(CartTab tab) {
    state = state.copyWith(
      cartTab: tab,
      // Manual tab change: keep scheduled focus only while on Orders.
      focusScheduledCart:
          tab == CartTab.orders ? state.focusScheduledCart : false,
    );
  }
}

final shellProvider = StateNotifierProvider<ShellNotifier, ShellState>(
  (ref) => ShellNotifier(),
);
