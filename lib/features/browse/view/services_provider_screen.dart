import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/services_widgets.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';

class ServicesProviderScreen extends ConsumerStatefulWidget {
  const ServicesProviderScreen({
    super.key,
    required this.providerId,
    this.bottomNavIndex = 0,
  });

  final String providerId;
  final int bottomNavIndex;

  @override
  ConsumerState<ServicesProviderScreen> createState() =>
      _ServicesProviderScreenState();
}

class _ServicesProviderScreenState
    extends ConsumerState<ServicesProviderScreen> {
  String _selectedSection = ServicesData.glowBeautySections.first;
  List<String> _sections = ServicesData.glowBeautySections;
  List<ServiceMenuItem> _allItems = const [];
  ServiceProvider _provider = ServicesData.popularProviders.first;
  ServicesCartSummary _cart = ServicesCartSummary.empty;
  bool _loading = true;
  String _menuQuery = '';
  Timer? _searchDebounce;

  List<ServiceMenuItem> get _items {
    final sectionItems = _allItems
        .where((item) => item.section == _selectedSection)
        .toList();
    final q = _menuQuery.trim().toLowerCase();
    if (q.isEmpty) return sectionItems;
    return sectionItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(q) ||
              item.description.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _provider = ServicesData.providerById(widget.providerId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onMenuQueryChanged(String value) {
    setState(() => _menuQuery = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _load(query: value);
    });
  }

  Future<void> _load({String? query}) async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(servicesVendorsRepositoryProvider);
      final menu = await repo.fetchProviderMenu(
        widget.providerId,
        query: query,
      );
      final cart = await repo.fetchServiceCart();
      if (!mounted) return;
      setState(() {
        _applyMenu(menu);
        _cart = cart;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _applyMenu(ServicesVendorMenu menu) {
    _provider = menu.provider;
    _sections = menu.sections.isNotEmpty
        ? menu.sections
        : ServicesData.glowBeautySections;
    _allItems = menu.items;
    if (!_sections.contains(_selectedSection) && _sections.isNotEmpty) {
      _selectedSection = _sections.first;
    }
  }

  Future<void> _addService(ServiceMenuItem item) async {
    final cartVendorId = _cart.vendorId;
    final needsReplace = cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.providerId &&
        _cart.itemCount > 0;

    Future<void> doAdd({bool replace = false}) async {
      final result = await ref.read(servicesVendorsRepositoryProvider).addToCart(
            productId: item.id,
            quantity: 1,
            replaceCart: replace,
          );
      if (!mounted) return;
      if (result.ok) {
        await _load(query: _menuQuery);
        return;
      }
      if (result.vendorConflict) {
        showCartNewCartDialog(
          context,
          onConfirm: () => doAdd(replace: true),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Could not add to booking')),
      );
    }

    if (needsReplace) {
      showCartNewCartDialog(context, onConfirm: () => doAdd(replace: true));
      return;
    }
    await doAdd();
  }

  Future<void> _openItem(ServiceMenuItem item) async {
    final cartVendorId = _cart.vendorId;
    final needsReplace = cartVendorId != null &&
        cartVendorId.isNotEmpty &&
        cartVendorId != widget.providerId &&
        _cart.itemCount > 0;

    void goDetail() {
      context
          .push(
            BrowseRoutes.servicesItemDetail(
              providerId: widget.providerId,
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

  @override
  Widget build(BuildContext context) {
    final showBar = _cart.itemCount > 0;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ServicesProviderHero(provider: _provider),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    // Design body: padding 16 20, gap 14
                    padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                    children: [
                      BrowseSearchBar(
                        hint: 'Search services…',
                        value: _menuQuery,
                        autofocus: false,
                        onChanged: _onMenuQueryChanged,
                      ),
                      SizedBox(height: 14.w),
                      ServicesProviderInfoCard(provider: _provider),
                      SizedBox(height: 14.w),
                      if (_sections.isNotEmpty)
                        ServicesSectionChips(
                          options: _sections,
                          selected: _selectedSection,
                          onSelected: (v) =>
                              setState(() => _selectedSection = v),
                        ),
                      SizedBox(height: 14.w),
                      for (var i = 0; i < _items.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE0E6E0),
                          ),
                        ServicesMenuItemRow(
                          item: _items[i],
                          onAdd: () => _addService(_items[i]),
                          onTap: () => _openItem(_items[i]),
                        ),
                      ],
                    ],
                  ),
          ),
          if (showBar)
            ServicesBookingBar(
              itemCount: _cart.itemCount,
              total: _cart.totalLabel,
              onTap: () => context.push(ServicesBookingRoutes.booking),
            ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
    );
  }
}
