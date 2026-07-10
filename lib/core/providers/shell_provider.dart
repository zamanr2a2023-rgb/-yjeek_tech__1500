import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class ShellState {
  const ShellState({
    this.currentIndex = 0,
    this.cartHasItems = false,
    this.dineInHasItems = false,
    this.scheduledHasItems = false,
    this.pickupHasItems = false,
    this.vapeHasItems = false,
    this.cartTab = CartTab.orders,
  });

  final int currentIndex;
  final bool cartHasItems;
  final bool dineInHasItems;
  final bool scheduledHasItems;
  final bool pickupHasItems;
  final bool vapeHasItems;
  final CartTab cartTab;

  ShellState copyWith({
    int? currentIndex,
    bool? cartHasItems,
    bool? dineInHasItems,
    bool? scheduledHasItems,
    bool? pickupHasItems,
    bool? vapeHasItems,
    CartTab? cartTab,
  }) {
    return ShellState(
      currentIndex: currentIndex ?? this.currentIndex,
      cartHasItems: cartHasItems ?? this.cartHasItems,
      dineInHasItems: dineInHasItems ?? this.dineInHasItems,
      scheduledHasItems: scheduledHasItems ?? this.scheduledHasItems,
      pickupHasItems: pickupHasItems ?? this.pickupHasItems,
      vapeHasItems: vapeHasItems ?? this.vapeHasItems,
      cartTab: cartTab ?? this.cartTab,
    );
  }
}

class ShellNotifier extends StateNotifier<ShellState> {
  ShellNotifier([ShellState? initial]) : super(initial ?? const ShellState());

  void setTab(int index) => state = state.copyWith(currentIndex: index);

  void addToCart() {
    state = state.copyWith(
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

  void browseVendors() {
    state = state.copyWith(
      currentIndex: 0,
      cartHasItems: false,
      dineInHasItems: false,
      scheduledHasItems: false,
      pickupHasItems: false,
      vapeHasItems: false,
    );
  }

  void openCartWithItems() {
    state = state.copyWith(
      cartHasItems: true,
      currentIndex: 2,
      cartTab: CartTab.orders,
    );
  }

  void openDineInCartWithItems() {
    state = state.copyWith(
      dineInHasItems: true,
      currentIndex: 2,
      cartTab: CartTab.dineIn,
    );
  }

  void openScheduledCartWithItems() {
    state = state.copyWith(
      scheduledHasItems: true,
      currentIndex: 2,
      cartTab: CartTab.pickup,
    );
  }

  void openPickupCartWithItems() {
    state = state.copyWith(
      pickupHasItems: true,
      currentIndex: 2,
      cartTab: CartTab.pickup,
    );
  }

  void openVapeCartWithItems() {
    state = state.copyWith(
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
