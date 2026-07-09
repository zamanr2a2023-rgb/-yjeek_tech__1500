import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/features/home/view/home_screen.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/view/account_screen.dart';
import 'package:yjeek_app/features/navigation/view/cart_screen.dart';
import 'package:yjeek_app/features/navigation/view/orders_screen.dart';
import 'package:yjeek_app/features/navigation/view/wallet_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    this.initialIndex = 0,
    this.cartHasItems = false,
  });

  final int initialIndex;
  final bool cartHasItems;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(shellProvider.notifier);
      if (widget.cartHasItems) {
        notifier.openCartWithItems();
      } else {
        notifier.setTab(widget.initialIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shell = ref.watch(shellProvider);
    final notifier = ref.read(shellProvider.notifier);

    final pages = [
      const HomeScreen(),
      OrdersScreen(onReorder: notifier.openCartWithItems),
      CartScreen(
        hasItems: shell.cartHasItems,
        onBrowseVendors: notifier.browseVendors,
        onBack: notifier.clearCart,
      ),
      const WalletScreen(showBottomNav: true),
      const AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: shell.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: shell.currentIndex,
        onTap: notifier.setTab,
      ),
    );
  }
}
