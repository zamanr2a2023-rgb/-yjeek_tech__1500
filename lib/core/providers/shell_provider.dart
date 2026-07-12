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
    );
  }
}

class ShellNotifier extends StateNotifier<ShellState> {
  ShellNotifier([ShellState? initial]) : super(initial ?? const ShellState());

  void setTab(int index) {
    if (index == state.currentIndex) return;
    state = state.copyWith(
      previousIndex: state.currentIndex,
      currentIndex: index,
      clearCartReturnPath: index != 2,
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
    );
  }

  void openVapeCartWithItems() {
    state = state.copyWith(
      previousIndex: state.currentIndex == 2
          ? state.previousIndex
          : state.currentIndex,
      vapeHasItems: true,
      currentIndex: 2,
      cartTab: CartTab.services,
    );
  }

  void setCartTab(CartTab tab) {
    state = state.copyWith(cartTab: tab);
  }
}

final shellProvider = StateNotifierProvider<ShellNotifier, ShellState>(
  (ref) => ShellNotifier(),
);
