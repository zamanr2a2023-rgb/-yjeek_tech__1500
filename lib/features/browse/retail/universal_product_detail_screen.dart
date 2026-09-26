import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/retail/product_detail_strategies.dart';
import 'package:yjeek_app/features/browse/view/widgets/item_detail_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Shared product customize page for Electronics / Vape / Services.
class UniversalProductDetailScreen extends ConsumerStatefulWidget {
  const UniversalProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
    required this.strategy,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final String productId;
  final ProductDetailStrategy strategy;
  final int bottomNavIndex;

  @override
  ConsumerState<UniversalProductDetailScreen> createState() =>
      _UniversalProductDetailScreenState();
}

class _UniversalProductDetailScreenState
    extends ConsumerState<UniversalProductDetailScreen> {
  int _quantity = 1;
  final Map<int, Set<int>> _selectedOptionsByGroup = {};
  final Set<int> _selectedAddons = {};
  final Set<int> _collapsedGroups = {};
  bool _addonsExpanded = true;
  bool _isGridView = true;
  bool _loading = true;
  bool _adding = false;
  bool _loadError = false;

  UniversalProductDetail? _detail;

  ProductDetailStrategy get strategy => widget.strategy;

  bool get _hasCustomize {
    final d = _detail;
    if (d == null) return false;
    return d.optionGroups.isNotEmpty || d.addons.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = false;
    });
    try {
      final detail = await strategy.load(
        ref,
        storeId: widget.storeId,
        productId: widget.productId,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _selectedOptionsByGroup
          ..clear()
          ..addAll(initialOptionSelections(detail.optionGroups));
        for (final entry in _selectedOptionsByGroup.entries) {
          final gi = entry.key;
          if (gi < 0 || gi >= detail.optionGroups.length) continue;
          entry.value.removeWhere(
            (oi) =>
                oi < 0 ||
                oi >= detail.optionGroups[gi].options.length ||
                !detail.optionGroups[gi].options[oi].isAvailable,
          );
        }
        _selectedAddons.clear();
        _collapsedGroups.clear();
        _addonsExpanded = true;
        _quantity = 1;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = true;
        });
      }
    }
  }

  String get _displayPrice {
    final item = _detail;
    if (item == null) return '0.000';
    final base = double.tryParse(item.price) ?? 0;
    final optionExtra = optionSelectionsExtraPrice(
      item.optionGroups,
      _selectedOptionsByGroup,
    );
    var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      if (index >= 0 && index < item.addons.length) {
        addonTotal += double.tryParse(item.addons[index].price) ?? 0;
      }
    }
    return ((base + optionExtra + addonTotal) * _quantity).toStringAsFixed(3);
  }

  String get _basePriceLabel {
    final item = _detail;
    if (item == null) return 'BHD 0.000';
    final p = double.tryParse(item.price) ?? 0;
    return 'BHD ${p.toStringAsFixed(3)}';
  }

  void _toggleOption(int groupIndex, int optionIndex) {
    final groups = _detail?.optionGroups ?? const [];
    if (groupIndex < 0 || groupIndex >= groups.length) return;
    final group = groups[groupIndex];
    if (optionIndex < 0 || optionIndex >= group.options.length) return;
    if (!group.options[optionIndex].isAvailable) return;

    setState(() {
      final current = Set<int>.from(_selectedOptionsByGroup[groupIndex] ?? {});
      if (group.allowsMultiple) {
        if (current.contains(optionIndex)) {
          current.remove(optionIndex);
        } else if (current.length < group.maxSelect) {
          current.add(optionIndex);
        }
      } else {
        current
          ..clear()
          ..add(optionIndex);
      }
      _selectedOptionsByGroup[groupIndex] = current;
    });
  }

  void _toggleAddon(int index) {
    final addons = _detail?.addons ?? const [];
    setState(() {
      if (_selectedAddons.contains(index)) {
        _selectedAddons.remove(index);
        return;
      }
      if (_selectedAddons.length >= addons.length) return;
      _selectedAddons.add(index);
    });
  }

  Future<void> _addToCart({bool replaceCart = false}) async {
    final detail = _detail;
    if (_adding || detail == null) return;

    final validationError = validateOptionSelections(
      detail.optionGroups,
      _selectedOptionsByGroup,
    );
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final optionIds = optionSelectionIds(
      detail.optionGroups,
      _selectedOptionsByGroup,
    );
    final addonIds = <String>[];
    for (final index in _selectedAddons) {
      if (index >= 0 &&
          index < detail.addons.length &&
          detail.addons[index].id != null) {
        addonIds.add(detail.addons[index].id!);
      }
    }

    if (!ref.read(storageServiceProvider).hasSession) {
      rememberPendingAddToCart(
        ref,
        PendingAddToCart(
          productId: widget.productId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          vendorId: widget.storeId,
          replaceCart: replaceCart,
          cartType: strategy.cartType,
          returnPath: currentReturnPath(context),
          vertical: strategy.pendingVertical,
        ),
      );
    }

    if (strategy.beforeAdd != null) {
      if (!await strategy.beforeAdd!(
        context,
        ref,
        productName: detail.name,
      )) {
        return;
      }
    } else {
      if (!await requireLogin(context, ref)) return;
    }
    if (!mounted) return;

    setState(() => _adding = true);
    final result = await strategy.add(
      ref,
      storeId: widget.storeId,
      productId: widget.productId,
      quantity: _quantity,
      optionIds: optionIds,
      addonIds: addonIds,
      replaceCart: replaceCart,
    );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      clearPendingAddToCart(ref);
      if (strategy.afterSuccess != null) {
        await strategy.afterSuccess!(
          context,
          ref,
          productName: detail.name,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${detail.name} added to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    if (result.outOfRange) {
      rememberPendingAddToCart(
        ref,
        PendingAddToCart(
          productId: widget.productId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          vendorId: widget.storeId,
          replaceCart: replaceCart,
          vertical: strategy.pendingVertical,
        ),
      );
      await pushOutOfDelivery(context);
      return;
    }

    if (result.vendorConflict) {
      showCartNewCartDialog(
        context,
        onConfirm: () => _addToCart(replaceCart: true),
      );
      return;
    }

    if (await redirectToLoginIfAuthError(context, ref, result.message)) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Could not add to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _loadError || _detail == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load item',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(child: _buildBody()),
                    ItemAddToCartBar(
                      label: '${strategy.ctaVerb} · BHD $_displayPrice',
                      busy: _adding,
                      onTap: () => _addToCart(),
                    ),
                  ],
                ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _buildBody() {
    final item = _detail!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildImageSection()),
        if (strategy.showAgeBanner)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              child: const VapeAgeBanner(),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                item.name,
                style: AppTextStyles.titleMedium(
                  color: AppColors.textPrimary,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                _basePriceLabel,
                style: AppTextStyles.titleSmall(color: AppColors.primary)
                    .copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  height: 1.2,
                ),
              ),
              if (item.description.trim().isNotEmpty &&
                  item.description.trim() != '___') ...[
                SizedBox(height: 8.h),
                Text(
                  item.description,
                  style: AppTextStyles.bodyMedium(
                    color: const Color(0xFF6B6B6B),
                  ).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    height: 1.25,
                  ),
                ),
              ],
              if (_hasCustomize) ...[
                SizedBox(height: 12.h),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E2E2),
                ),
                SizedBox(height: 4.h),
                ItemCustomizeHeader(
                  isGridView: _isGridView,
                  onViewChanged: (v) => setState(() => _isGridView = v),
                ),
                for (var gi = 0; gi < item.optionGroups.length; gi++)
                  _buildOptionGroup(gi),
                if (item.addons.isNotEmpty) _buildAddonsSection(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E2E2),
                ),
              ],
              ItemQuantityRow(
                quantity: _quantity,
                label: item.quantityLabel,
                onMinus: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                onPlus: () => setState(() => _quantity++),
              ),
              SizedBox(height: 8.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    final imageUrl = _detail?.imageUrl;
    return SizedBox(
      height: 280.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: const Color(0xFFE8F5E9),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? AppNetworkImage(
                    url: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: const ColoredBox(color: Color(0xFFE8F5E9)),
                  )
                : null,
          ),
          Positioned(
            top: 0,
            left: 16.w,
            child: SafeArea(
              bottom: false,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(strategy.fallbackStoreRoute(widget.storeId));
                  }
                },
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 22.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionGroup(int gi) {
    final group = _detail!.optionGroups[gi];
    final expanded = !_collapsedGroups.contains(gi);
    final style = _gridStyleFor(group.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemOptionAccordionHeader(
          title: group.name,
          hint: _groupHint(group, gi),
          expanded: expanded,
          onTap: () => setState(() {
            if (expanded) {
              _collapsedGroups.add(gi);
            } else {
              _collapsedGroups.remove(gi);
            }
          }),
        ),
        if (expanded)
          ItemOptionsLayout(
            isGridView: _isGridView,
            gridStyle: style,
            multiple: group.allowsMultiple,
            itemCount: group.options.length,
            labelAt: (i) => group.options[i].label,
            priceAt: (i) => group.options[i].priceDisplay,
            selectedAt: (i) =>
                _selectedOptionsByGroup[gi]?.contains(i) ?? false,
            imageAt: (i) => group.options[i].hasNetworkImage
                ? group.options[i].imageUrl
                : null,
            swatchColorAt: (i) => group.options[i].swatchColor,
            stockAt: (i) => group.options[i].stockLabel,
            enabledAt: (i) => group.options[i].isAvailable,
            onTapAt: (i) => _toggleOption(gi, i),
          ),
      ],
    );
  }

  Widget _buildAddonsSection() {
    final addons = _detail!.addons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemOptionAccordionHeader(
          title: 'Add extras',
          hint: 'Optional · Select any',
          expanded: _addonsExpanded,
          onTap: () => setState(() => _addonsExpanded = !_addonsExpanded),
        ),
        if (_addonsExpanded)
          ItemOptionsLayout(
            isGridView: _isGridView,
            gridStyle: _addonsGridStyle,
            multiple: true,
            itemCount: addons.length,
            labelAt: (i) => addons[i].label,
            priceAt: (i) => addons[i].priceLabel,
            selectedAt: (i) => _selectedAddons.contains(i),
            imageAt: (i) => addons[i].imageUrl,
            onTapAt: _toggleAddon,
          ),
      ],
    );
  }

  ItemOptionGridStyle get _addonsGridStyle {
    final flowerish = (_detail?.optionGroups ?? const []).any((g) {
      final n = g.name.toLowerCase();
      return n.contains('bouquet') || n.contains('flower');
    });
    return flowerish ? ItemOptionGridStyle.chips : ItemOptionGridStyle.cards;
  }

  String _groupHint(BrowseOptionGroup group, int gi) {
    final picks = _selectedOptionsByGroup[gi];
    String? selectedLabel;
    if (picks != null && picks.isNotEmpty) {
      final oi = picks.first;
      if (oi >= 0 && oi < group.options.length) {
        selectedLabel = group.options[oi].label;
      }
    }
    if (group.isRequired) {
      if (selectedLabel != null && selectedLabel.isNotEmpty) {
        return 'Required · $selectedLabel';
      }
      return 'Required';
    }
    if (selectedLabel != null && selectedLabel.isNotEmpty) {
      return 'Optional · $selectedLabel';
    }
    return 'Optional · Select any';
  }

  ItemOptionGridStyle _gridStyleFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('colour') || n.contains('color')) {
      return ItemOptionGridStyle.swatches;
    }
    if (n.contains('storage') ||
        n.contains('size') ||
        n.contains('memory') ||
        n.contains('bouquet')) {
      return ItemOptionGridStyle.chips;
    }
    return ItemOptionGridStyle.cards;
  }
}
