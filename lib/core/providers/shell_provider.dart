import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShellState {
  const ShellState({
    this.currentIndex = 0,
    this.cartHasItems = false,
  });

  final int currentIndex;
  final bool cartHasItems;

  ShellState copyWith({int? currentIndex, bool? cartHasItems}) {
    return ShellState(
      currentIndex: currentIndex ?? this.currentIndex,
      cartHasItems: cartHasItems ?? this.cartHasItems,
    );
  }
}

class ShellNotifier extends StateNotifier<ShellState> {
  ShellNotifier([ShellState? initial]) : super(initial ?? const ShellState());

  void setTab(int index) => state = state.copyWith(currentIndex: index);

  void addToCart() {
    state = state.copyWith(cartHasItems: true, currentIndex: 2);
  }

  void clearCart() {
    state = state.copyWith(cartHasItems: false);
  }

  void browseVendors() {
    state = state.copyWith(currentIndex: 0, cartHasItems: false);
  }

  void openCartWithItems() {
    state = state.copyWith(cartHasItems: true, currentIndex: 2);
  }
}

final shellProvider = StateNotifierProvider<ShellNotifier, ShellState>(
  (ref) => ShellNotifier(),
);
