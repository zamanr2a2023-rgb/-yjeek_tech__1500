import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/core/utils/api_media_url.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/retail/product_detail_strategies.dart';
import 'package:yjeek_app/features/browse/utils/vape_age_gate.dart';
import 'package:yjeek_app/features/browse/view/widgets/item_detail_widgets.dart';
import 'package:yjeek_app/features/catalog/model/catalog_product.dart';
import 'package:yjeek_app/features/catalog/model/variant_match.dart';
import 'package:yjeek_app/features/catalog/widgets/variant_axis_section.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Shared product customize page.
///
/// `catalogMode == VARIANTS` shows axes and prices the matched SKU.
/// Every other mode, including Food-style `MODIFIERS` and services with no
/// catalog payload, keeps option groups. The branch is not the store type.
class UniversalProductDetailScreen extends ConsumerStatefulWidget {
  const UniversalProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
    required this.strategy,
    this.bottomNavIndex = 0,
    this.initialVariantId,
    this.initialQuantity,
  });

  final String storeId;
  final String productId;
  final ProductDetailStrategy strategy;
  final int bottomNavIndex;
  final String? initialVariantId;
  final int? initialQuantity;

  @override
  ConsumerState<UniversalProductDetailScreen> createState() =>
      _UniversalProductDetailScreenState();
}

class _UniversalProductDetailScreenState
    extends ConsumerState<UniversalProductDetailScreen> {
  int _quantity = 1;
  final Map<int, Set<int>> _selectedOptionsByGroup = {};
  final Set<int> _selectedAddons = {};

  /// Axis key → selected value key. Variant catalogs only.
  final Map<String, String> _selectedAxisValues = {};
  CatalogVariant? _selectedVariant;
  final Set<int> _collapsedGroups = {};
  bool _addonsExpanded = true;
  bool _isGridView = true;
  bool _loading = true;
  bool _adding = false;
  bool _loadError = false;
  bool _agePromptShown = false;
  bool _ageFlowOpen = false;

  UniversalProductDetail? _detail;

  ProductDetailStrategy get strategy => widget.strategy;

  bool get _isVariantMode => _detail?.usesVariantSelection ?? false;

  bool get _hasCustomize {
    final d = _detail;
    if (d == null) return false;
    if (d.usesVariantSelection) {
      return (d.catalog?.axes.isNotEmpty ?? false) || d.addons.isNotEmpty;
    }
    return d.optionGroups.isNotEmpty || d.addons.isNotEmpty;
  }

  bool get _variantReady {
    final detail = _detail;
    if (detail == null || !detail.usesVariantSelection) return false;
    return variantSelectionReady(
      axes: detail.catalog?.axes ?? const [],
      selectedAttributes: _selectedAxisValues,
      matched: _selectedVariant,
    );
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
        _selectedAxisValues.clear();
        _selectedVariant = null;
        if (detail.usesVariantSelection) {
          final catalog = detail.catalog;
          if (catalog != null && catalog.variants.isNotEmpty) {
            final presetId = widget.initialVariantId?.trim();
            CatalogVariant? preset;
            if (presetId != null && presetId.isNotEmpty) {
              for (final row in catalog.variants) {
                if (row.id == presetId) {
                  preset = row;
                  break;
                }
              }
            }
            if (preset != null) {
              _selectedAxisValues.addAll(preset.attributes);
              _selectedVariant = preset;
            } else {
              _selectedAxisValues.addAll(
                initialVariantAxisSelection(variants: catalog.variants),
              );
              _selectedVariant = matchVariant(
                variants: catalog.variants,
                selectedAttributes: _selectedAxisValues,
              );
            }
          }
        }
        _collapsedGroups.clear();
        _addonsExpanded = true;
        final presetQty = widget.initialQuantity;
        _quantity = presetQty != null && presetQty > 0 ? presetQty : 1;
        _loading = false;
      });
      _maybePromptAgeVerification();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = true;
        });
      }
    }
  }

  double get _selectedAddonTotal {
    final item = _detail;
    if (item == null) return 0;
    var addonTotal = 0.0;
    for (final index in _selectedAddons) {
      if (index >= 0 && index < item.addons.length) {
        addonTotal += double.tryParse(item.addons[index].price) ?? 0;
      }
    }
    return addonTotal;
  }

  /// Addon ids for the current extras selection. The chips stay index-based
  /// so the existing extras block is unchanged.
  List<String> get _selectedAddonIds {
    final item = _detail;
    if (item == null) return const [];
    final ids = <String>[];
    for (final index in _selectedAddons) {
      if (index < 0 || index >= item.addons.length) continue;
      final id = item.addons[index].id;
      if (id != null && id.isNotEmpty) ids.add(id);
    }
    return ids;
  }

  String get _displayPrice {
    final item = _detail;
    if (item == null) return '0.000';
    if (item.usesVariantSelection) {
      final unit = variantUnitWithAddons(_selectedVariant, [
        _selectedAddonTotal,
      ]);
      if (unit == null) return '0.000';
      return (unit * _quantity).toStringAsFixed(3);
    }
    final base = double.tryParse(item.price) ?? 0;
    final optionExtra = optionSelectionsExtraPrice(
      item.optionGroups,
      _selectedOptionsByGroup,
    );
    return ((base + optionExtra + _selectedAddonTotal) * _quantity)
        .toStringAsFixed(3);
  }

  String get _basePriceLabel {
    final item = _detail;
    if (item == null) return 'BHD 0.000';
    if (item.usesVariantSelection) {
      final unit = variantPrice(_selectedVariant);
      if (unit != null) return 'BHD ${unit.toStringAsFixed(3)}';
      final from = catalogLowestSelectableVariantPrice(item.catalog);
      if (from != null) return 'From BHD ${from.toStringAsFixed(3)}';
      return 'BHD —';
    }
    final p = double.tryParse(item.price) ?? 0;
    return 'BHD ${p.toStringAsFixed(3)}';
  }

  bool get _requiresAgeVerification =>
      _detail?.catalog?.ageRestriction?.requiresAgeVerification ?? false;

  String get _ctaLabel {
    if (_requiresAgeVerification) return 'Verify your age';
    if (_isVariantMode && variantPrice(_selectedVariant) == null) {
      return strategy.ctaVerb;
    }
    return '${strategy.ctaVerb} · BHD $_displayPrice';
  }

  void _maybePromptAgeVerification() {
    if (!_requiresAgeVerification || _agePromptShown) return;
    _agePromptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAgeVerification();
    });
  }

  Future<void> _startAgeVerification() async {
    if (_ageFlowOpen) return;
    _ageFlowOpen = true;
    try {
      final ok = await ensureVapeAgeVerifiedForPurchase(
        context,
        ref,
        productName: _detail?.name,
      );
      if (!mounted || !ok) return;
      await _load();
    } finally {
      _ageFlowOpen = false;
    }
  }

  bool get _variantAddBlocked => _isVariantMode && !_variantReady;

  List<String> get _productImageUrls {
    final item = _detail;
    if (item == null) return const [];

    final seen = <String>{};
    final urls = <String>[];

    void add(String? raw) {
      final resolved = resolveApiMediaUrl(raw);
      if (resolved == null || resolved.isEmpty) return;
      if (seen.add(resolved)) urls.add(resolved);
    }

    final variantImage = resolveApiMediaUrl(_selectedVariant?.imageUrl);
    if (variantImage != null && variantImage.isNotEmpty) {
      add(variantImage);
    }

    for (final url in item.imageUrls) {
      add(url);
    }
    add(item.imageUrl);
    add(item.catalog?.imageUrl);
    for (final variant in item.catalog?.variants ?? const <CatalogVariant>[]) {
      add(variant.imageUrl);
    }
    return urls;
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

  void _onAxisChanged(String axisKey, String valueKey) {
    if (axisKey.isEmpty || valueKey.isEmpty) return;
    setState(() {
      _selectedAxisValues[axisKey] = valueKey;
      _selectedVariant = matchVariant(
        variants: _detail?.catalog?.variants ?? const [],
        selectedAttributes: _selectedAxisValues,
      );
      final max = _maxSelectableQuantity;
      if (max != null && _quantity > max) {
        _quantity = max > 0 ? max : 1;
      }
    });
  }

  int? get _maxSelectableQuantity {
    final qty = _selectedVariant?.stockQty;
    if (qty == null || qty < 0) return null;
    return qty;
  }

  String _variantSkuSummary() {
    final variant = _selectedVariant;
    if (variant == null) return '';
    final label = variant.label?.trim();
    if (label != null && label.isNotEmpty) return label;
    final parts = <String>[];
    final catalog = _detail?.catalog;
    if (catalog != null) {
      for (final axis in catalog.axes) {
        final key = axis.key;
        if (key == null || key.isEmpty) continue;
        final valueKey = _selectedAxisValues[key];
        if (valueKey == null || valueKey.isEmpty) continue;
        String? display;
        for (final axisValue in axis.values) {
          if (axisValue.key == valueKey) {
            display = axisValue.label?.trim();
            break;
          }
        }
        parts.add(
          display != null && display.isNotEmpty ? display : valueKey,
        );
      }
    }
    if (parts.isEmpty) return '';
    final stock = _maxSelectableQuantity;
    final stockNote = stock != null ? ' · $stock in stock' : '';
    return '${parts.join(' / ')}$stockNote';
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

    final isVariant = detail.usesVariantSelection;
    if (isVariant) {
      if (!_variantReady || _selectedVariant?.id == null) return;
    } else {
      final validationError = validateOptionSelections(
        detail.optionGroups,
        _selectedOptionsByGroup,
      );
      if (validationError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(validationError)));
        return;
      }
    }

    // Variant SKUs must not send option ids. Modifier lines must not send
    // a variant id.
    final optionIds = isVariant
        ? const <String>[]
        : optionSelectionIds(detail.optionGroups, _selectedOptionsByGroup);
    final addonIds = _selectedAddonIds;
    final variantId = isVariant ? _selectedVariant?.id : null;

    if (!ref.read(storageServiceProvider).hasSession) {
      rememberPendingAddToCart(
        ref,
        PendingAddToCart(
          productId: widget.productId,
          quantity: _quantity,
          optionIds: optionIds,
          addonIds: addonIds,
          variantId: variantId,
          vendorId: widget.storeId,
          replaceCart: replaceCart,
          cartType: strategy.cartType,
          returnPath: currentReturnPath(context),
          vertical: strategy.pendingVertical,
        ),
      );
    }

    if (strategy.beforeAdd != null) {
      if (!await strategy.beforeAdd!(context, ref, productName: detail.name)) {
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
      variantId: variantId,
      replaceCart: replaceCart,
    );

    if (!mounted) return;
    setState(() => _adding = false);

    if (result.ok) {
      clearPendingAddToCart(ref);
      final notice = result.message;
      if (notice != null && notice.isNotEmpty && mounted) {
        await acknowledgeExtraDeliveryCharge(context, notice);
        if (!mounted) return;
      }
      if (strategy.afterSuccess != null) {
        await strategy.afterSuccess!(context, ref, productName: detail.name);
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
          variantId: variantId,
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
                  label: _ctaLabel,
                  busy: _adding,
                  onTap: _requiresAgeVerification
                      ? _startAgeVerification
                      : (_variantAddBlocked ? null : () => _addToCart()),
                ),
              ],
            ),
      bottomNavigationBar: ShellBottomNavBar(
        currentIndex: widget.bottomNavIndex,
      ),
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
                style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                    .copyWith(
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
              if (item.catalog?.restrictions?.isHighValue == true) ...[
                SizedBox(height: 8.h),
                const _HighValueItemNote(),
              ],
              if (item.description.trim().isNotEmpty &&
                  item.description.trim() != '___') ...[
                SizedBox(height: 8.h),
                Text(
                  item.description,
                  style:
                      AppTextStyles.bodyMedium(
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
                if (item.usesVariantSelection)
                  ..._buildVariantAxes()
                else
                  for (var gi = 0; gi < item.optionGroups.length; gi++)
                    _buildOptionGroup(gi),
                if (item.addons.isNotEmpty) _buildAddonsSection(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E2E2),
                ),
              ],
              if (_isVariantMode && _selectedVariant != null) ...[
                Text(
                  _variantSkuSummary(),
                  style: AppTextStyles.labelSmall(
                    color: AppColors.textSecondary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                ),
                SizedBox(height: 6.h),
              ],
              ItemQuantityRow(
                quantity: _quantity,
                label: item.quantityLabel,
                onMinus: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                onPlus: () {
                  final max = _maxSelectableQuantity;
                  if (max != null && _quantity >= max) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          max <= 0
                              ? 'This option is out of stock'
                              : 'Only $max available for this option',
                        ),
                      ),
                    );
                    return;
                  }
                  setState(() => _quantity++);
                },
              ),
              SizedBox(height: 8.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 300.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: const Color(0xFFE8F5E9),
            child: ItemProductImageGallery(
              imageUrls: _productImageUrls,
              placeholder: const ColoredBox(color: Color(0xFFE8F5E9)),
              errorPlaceholder: const ColoredBox(color: Color(0xFFE8F5E9)),
            ),
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

  List<Widget> _buildVariantAxes() {
    final catalog = _detail?.catalog;
    final axes = catalog?.axes ?? const <CatalogAxis>[];
    final variants = catalog?.variants ?? const <CatalogVariant>[];
    final referencePrice = catalogLowestSelectableVariantPrice(catalog);
    return [
      for (final axis in axes)
        if (axis.key != null && axis.key!.isNotEmpty)
          VariantAxisSection(
            axis: axis,
            variants: variants,
            selectedAttributes: _selectedAxisValues,
            referencePrice: referencePrice,
            isGridView: _isGridView,
            selectedValue: _selectedAxisValues[axis.key],
            availableValues: availableValuesForAxis(
              variants: variants,
              axisKey: axis.key!,
              selectedAttributes: _selectedAxisValues,
              axisValueKeys: [
                for (final value in axis.values)
                  if (value.key != null && value.key!.isNotEmpty) value.key!,
              ],
            ),
            onChanged: (valueKey) => _onAxisChanged(axis.key!, valueKey),
          ),
    ];
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
    final selectedNames = <String>[];
    for (final index in _selectedAddons) {
      if (index < 0 || index >= addons.length) continue;
      final name = addons[index].label.trim();
      if (name.isNotEmpty) selectedNames.add(name);
    }
    final extrasHint = selectedNames.isEmpty
        ? 'Optional · Select any'
        : 'Optional · ${selectedNames.join(', ')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemOptionAccordionHeader(
          title: 'Add extras',
          hint: extrasHint,
          expanded: _addonsExpanded,
          onTap: () => setState(() => _addonsExpanded = !_addonsExpanded),
        ),
        if (_addonsExpanded)
          ItemOptionsLayout(
            isGridView: _isGridView,
            gridStyle: ItemOptionGridStyle.extras,
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

/// Customer-facing label. No OTP, driver, or fee details.
class _HighValueItemNote extends StatelessWidget {
  const _HighValueItemNote();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          'High value item',
          style: AppTextStyles.labelSmall(
            color: const Color(0xFF1B5E20),
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
        ),
      ),
    );
  }
}
