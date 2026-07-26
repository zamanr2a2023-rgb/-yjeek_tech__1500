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
      clearCartReturnPath: index != 2,
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
      clearCartReturnPath: true,
    );
  }

  void openCartWithItems() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      cartHasItems: true,
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
      currentIndex: 2,
      cartTab: CartTab.pickup,
      cartRevision: _nextRevision,
    );
  }

  void openPickupCartWithItems() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      pickupHasItems: true,
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
    );
  }

  void setCartTab(CartTab tab) {
    state = state.copyWith(cartTab: tab);
  }
}

final shellProvider = StateNotifierProvider<ShellNotifier, ShellState>(
  (ref) => ShellNotifier(),
);
