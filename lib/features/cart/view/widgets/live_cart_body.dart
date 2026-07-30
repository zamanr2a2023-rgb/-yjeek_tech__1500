import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_google_map.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';
import 'package:yjeek_app/features/dine_in_cart/view/widgets/dine_in_cart_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

/// Live cart body — Food-cart visual language, API-driven (no mock items).
class LiveCartBody extends StatefulWidget {
  const LiveCartBody({
    super.key,
    required this.cart,
    required this.onQuantityChanged,
    required this.onRemoveItem,
    required this.onUpsellAdd,
    required this.onApplyPromo,
    required this.onAddMore,
    required this.onCheckout,
    this.onCutleryChanged,
    this.onKitchenNote,
    this.onEditItem,
    this.onPartySizeChanged,
    this.onSeatingChanged,
    this.onSpecialOccasionChanged,
    this.showCutlery = true,
    this.showDineInPreferences = false,
    this.showPickupHeader = false,
    this.showElectronicsCart = false,
    this.showVapeCart = false,
    this.checkoutLabel,
  });

  final CartSnapshot cart;
  final Future<void> Function(String itemId, int quantity) onQuantityChanged;
  final Future<void> Function(String itemId) onRemoveItem;
  final Future<void> Function(String productId) onUpsellAdd;
  final Future<void> Function(String code) onApplyPromo;
  final ValueChanged<bool>? onCutleryChanged;
  final Future<void> Function(String note)? onKitchenNote;
  final ValueChanged<CartLineItem>? onEditItem;
  final Future<void> Function(int partySize)? onPartySizeChanged;
  final Future<void> Function(String seatingPreference)? onSeatingChanged;
  final Future<void> Function(bool enabled)? onSpecialOccasionChanged;
  final VoidCallback onAddMore;
  final VoidCallback onCheckout;
  final bool showCutlery;
  final bool showDineInPreferences;
  final bool showPickupHeader;
  final bool showElectronicsCart;
  final bool showVapeCart;
  final String? checkoutLabel;

  @override
  State<LiveCartBody> createState() => _LiveCartBodyState();
}

class _LiveCartBodyState extends State<LiveCartBody> {
  final _promoController = TextEditingController();
  final _promoFocusNode = FocusNode();
  bool _busy = false;

  CartSnapshot get cart => widget.cart;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openKitchenNote() async {
    final onNote = widget.onKitchenNote;
    if (onNote == null) return;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _KitchenNoteDialog(
        initialText: cart.kitchenNote ?? '',
      ),
    );
    if (!mounted || result == null) return;
    await _run(() => onNote(result));
  }

  DineInSeating _seatingFromApi(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'OUTDOOR':
        return DineInSeating.outdoor;
      case 'NO_PREFERENCE':
        return DineInSeating.any;
      case 'INDOOR':
      default:
        return DineInSeating.indoor;
    }
  }

  String _seatingToApi(DineInSeating seating) {
    return switch (seating) {
      DineInSeating.indoor => 'INDOOR',
      DineInSeating.outdoor => 'OUTDOOR',
      DineInSeating.any => 'NO_PREFERENCE',
    };
  }

  @override
  void dispose() {
    _promoFocusNode.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPickupFood =
        widget.showPickupHeader && !widget.showElectronicsCart;

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              isPickupFood ? 16 : 20,
              8,
              isPickupFood ? 16 : 20,
              16,
            ),
            children: [
              if (widget.showPickupHeader && cart.pickup != null) ...[
                _PickupHeader(info: cart.pickup!),
                SizedBox(height: isPickupFood ? 14 : 14),
              ],
              if (!widget.showElectronicsCart) ...[
                if (isPickupFood)
                  _PickupSectionHeader(title: NavigationStrings.yourItems)
                else
                  Text(
                    NavigationStrings.yourItems,
                    style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
                  ),
                const SizedBox(height: 10),
              ],
              if (widget.showDineInPreferences && cart.items.isNotEmpty)
                _dineInItemsCard(cart.items)
              else if (widget.showElectronicsCart)
                ...cart.items.map(_electronicsItemCard)
              else if (isPickupFood)
                _pickupItemsCard(cart.items)
              else
                ...cart.items.map(_itemCard),
              if (cart.upsell.isNotEmpty) ...[
                const SizedBox(height: 18),
                if (isPickupFood)
                  _PickupSectionHeader(title: cart.upsellTitle)
                else
                  Text(
                    cart.upsellTitle,
                    style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 133,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cart.upsell.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = cart.upsell[index];
                      return _UpsellCard(
                        item: item,
                        onAdd: () => _run(() => widget.onUpsellAdd(item.productId)),
                      );
                    },
                  ),
                ),
              ],
              if (widget.showDineInPreferences) ...[
                const SizedBox(height: 18),
                Text(
                  NavigationStrings.haveAPromoCode,
                  style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                _PromoApplyRow(
                  controller: _promoController,
                  focusNode: _promoFocusNode,
                  busy: _busy,
                  onSubmit: () {
                    final code = _promoController.text.trim();
                    if (code.isEmpty) return;
                    _run(() => widget.onApplyPromo(code));
                  },
                ),
                const SizedBox(height: 18),
                DineInPreferencesCard(
                  partySize: cart.partySize ?? DineInCartData.defaultPartySize,
                  seating: _seatingFromApi(cart.seatingPreference),
                  specialOccasion: cart.specialOccasion?.trim().isNotEmpty == true,
                  kitchenNoteHint: cart.kitchenNote,
                  onPartySizeChanged: (v) {
                    final cb = widget.onPartySizeChanged;
                    if (cb != null) _run(() => cb(v));
                  },
                  onSeatingChanged: (v) {
                    final cb = widget.onSeatingChanged;
                    if (cb != null) _run(() => cb(_seatingToApi(v)));
                  },
                  onSpecialOccasionChanged: (v) {
                    final cb = widget.onSpecialOccasionChanged;
                    if (cb != null) _run(() => cb(v));
                  },
                  onKitchenNoteTap: widget.onKitchenNote == null
                      ? null
                      : () => _openKitchenNote(),
                ),
              ] else if (widget.showCutlery) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8DD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NavigationStrings.orderPreferences,
                        style: AppTextStyles.titleSmall().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.restaurant_outlined,
                            size: 22,
                            color: Color(0xFF0F4D27),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  NavigationStrings.includeCutlery,
                                  style: AppTextStyles.labelMedium().copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  NavigationStrings.includeCutlerySubtitle,
                                  style: AppTextStyles.labelSmall(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: cart.includeCutlery,
                            activeThumbColor: AppColors.primary,
                            onChanged: widget.onCutleryChanged == null
                                ? null
                                : (v) => widget.onCutleryChanged!(v),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Color(0xFFE2E8DD)),
                      InkWell(
                        onTap: widget.onKitchenNote == null
                            ? null
                            : () => _openKitchenNote(),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 22,
                              color: Color(0xFF0F4D27),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    NavigationStrings.noteForKitchen,
                                    style: AppTextStyles.labelMedium().copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (cart.kitchenNote?.trim().isNotEmpty ?? false)
                                        ? cart.kitchenNote!.trim()
                                        : NavigationStrings.noteForKitchenSubtitle,
                                    style: AppTextStyles.labelSmall(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF6B7B6E),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (widget.showVapeCart || isPickupFood) ...[
                Text(
                  NavigationStrings.haveAPromoCode,
                  style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                _PromoApplyRow(
                  controller: _promoController,
                  focusNode: _promoFocusNode,
                  busy: _busy,
                  onSubmit: () {
                    final code = _promoController.text.trim();
                    if (code.isEmpty) return;
                    _run(() => widget.onApplyPromo(code));
                  },
                ),
                const SizedBox(height: 10),
              ] else if (!widget.showDineInPreferences) ...[
                Text(
                  widget.showElectronicsCart
                      ? 'Order options'
                      : NavigationStrings.billSummary,
                  style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (widget.showElectronicsCart)
                  _ElectronicsPromoRow(
                    controller: _promoController,
                    focusNode: _promoFocusNode,
                    busy: _busy,
                    appliedCode: cart.promoCode,
                    onSubmit: () {
                      final code = _promoController.text.trim();
                      if (code.isEmpty) return;
                      _run(() => widget.onApplyPromo(code));
                    },
                  )
                else
                  _PromoApplyRow(
                    controller: _promoController,
                    focusNode: _promoFocusNode,
                    busy: _busy,
                    onSubmit: () {
                      final code = _promoController.text.trim();
                      if (code.isEmpty) return;
                      _run(() => widget.onApplyPromo(code));
                    },
                  ),
                const SizedBox(height: 10),
              ],
              if (widget.showDineInPreferences) ...[
                Text(
                  NavigationStrings.billSummary,
                  style: AppTextStyles.titleSmall().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
              ],
              BillSummaryCard(
                lines: cart.billLines,
                showCashback: !widget.showElectronicsCart,
                cashbackAmount: cart.cashbackLabel,
              ),
            ],
          ),
        ),
        if (isPickupFood)
          _PickupCheckoutFooter(
            totalLabel: cart.totalLabel,
            onCheckout: widget.onCheckout,
          )
        else
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onAddMore,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.textPrimary,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: Color(0xFFE2E8DD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        NavigationStrings.addMore,
                        style: AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        widget.checkoutLabel ?? NavigationStrings.checkout,
                        style: AppTextStyles.labelMedium(
                          color: AppColors.white,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _pickupItemsCard(List<CartLineItem> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFE6EBE3)),
            _PickupCartItemRow(item: items[i]),
          ],
        ],
      ),
    );
  }

  Widget _dineInItemsCard(List<CartLineItem> items) {
    final main = items.first;
    final extraItems = items.length > 1 ? items.sublist(1) : const <CartLineItem>[];
    final sides = <CartSideLine>[
      ...main.sides,
      for (final side in extraItems)
        CartSideLine(
          name: side.name,
          quantity: side.quantity,
          priceLabel: side.unitPriceLabel,
          cartItemId: side.id,
        ),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8DD)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dineInMainBlock(main),
            if (sides.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(
                height: 16,
                thickness: 1,
                color: Color(0xFFE2E8DD),
              ),
              for (final side in sides) _secondaryItemRow(side),
            ],
          ],
        ),
      ),
    );
  }

  /// Matches dine-in design: title → subtitle → Edit, price pinned near bottom (under image).
  Widget _dineInMainBlock(CartLineItem item) {
    // Right column: 82 image + 8 gap + ~31 qty pill.
    const rightColumnHeight = 82.0 + 8.0 + 31.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: rightColumnHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.28,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF6B7B6E),
                    ).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.28,
                    ),
                  ),
                ],
                if (widget.onEditItem != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => widget.onEditItem!(item),
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          NavigationStrings.edit,
                          style: AppTextStyles.labelSmall(
                            color: AppColors.primary,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Text(
                      item.unitPriceLabel,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.primary,
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.28,
                      ),
                    ),
                    if (item.compareAtPriceLabel != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.compareAtPriceLabel!,
                        style: AppTextStyles.labelSmall(
                          color: const Color(0xFF6B7B6E),
                        ).copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 1.28,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(0xFF6B7B6E),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment(-0.6, -1),
                  end: Alignment(0.6, 1),
                  colors: [Color(0xFF6B8A3A), Color(0xFF15302B)],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _QtyControls(
              quantity: item.quantity,
              onMinus: () {
                if (item.quantity <= 1) {
                  _run(() => widget.onRemoveItem(item.id));
                } else {
                  _run(
                    () => widget.onQuantityChanged(
                      item.id,
                      item.quantity - 1,
                    ),
                  );
                }
              },
              onPlus: () => _run(
                () => widget.onQuantityChanged(
                  item.id,
                  item.quantity + 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _secondaryItemRow(CartSideLine item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE7D4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${item.quantity}×',
              style: AppTextStyles.labelSmall(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.labelSmall(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            item.priceLabel,
            style: AppTextStyles.labelSmall(
              color: AppColors.textPrimary,
            ).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (item.cartItemId != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => _run(() => widget.onRemoveItem(item.cartItemId!)),
              icon: const Icon(Icons.close, size: 16, color: Color(0xFF6B7B6E)),
            ),
        ],
      ),
    );
  }

  Widget _itemCard(CartLineItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8DD)),
        ),
        child: _itemCardContent(item, showBottomPrice: true),
      ),
    );
  }

  Widget _electronicsItemCard(CartLineItem item) {
    const titleColor = Color(0xFF121A14);
    const subtitleColor = Color(0xFF6B756E);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E6E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE1EEE6),
                borderRadius: BorderRadius.circular(9),
              ),
              clipBehavior: Clip.antiAlias,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Text('📦', style: TextStyle(fontSize: 19)),
                      ),
                    )
                  : const Center(
                      child: Text('📦', style: TextStyle(fontSize: 19)),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium(color: titleColor).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 18 / 14,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty)
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall(
                        color: subtitleColor,
                      ).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 16 / 12,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    item.unitPriceLabel,
                    style: AppTextStyles.labelMedium(color: titleColor).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 17 / 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ElectronicsQtyControls(
              quantity: item.quantity,
              onMinus: () {
                if (item.quantity <= 1) {
                  _run(() => widget.onRemoveItem(item.id));
                } else {
                  _run(
                    () => widget.onQuantityChanged(
                      item.id,
                      item.quantity - 1,
                    ),
                  );
                }
              },
              onPlus: () => _run(
                () => widget.onQuantityChanged(
                  item.id,
                  item.quantity + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCardContent(CartLineItem item, {required bool showBottomPrice}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.titleSmall().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.28,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 1.28,
                      ),
                    ),
                  ],
                  if (widget.onEditItem != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => widget.onEditItem!(item),
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            NavigationStrings.edit,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.primary,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (showBottomPrice) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          item.unitPriceLabel,
                          style: AppTextStyles.labelMedium(
                            color: AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        if (item.compareAtPriceLabel != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            item.compareAtPriceLabel!,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.textSecondary,
                            ).copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment(-0.8, -0.6),
                      end: Alignment(0.8, 0.8),
                      colors: [Color(0xFF7A4A22), Color(0xFF15302B)],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _QtyControls(
                  quantity: item.quantity,
                  onMinus: () {
                    if (item.quantity <= 1) {
                      _run(() => widget.onRemoveItem(item.id));
                    } else {
                      _run(
                        () => widget.onQuantityChanged(
                          item.id,
                          item.quantity - 1,
                        ),
                      );
                    }
                  },
                  onPlus: () => _run(
                    () => widget.onQuantityChanged(
                      item.id,
                      item.quantity + 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ElectronicsQtyControls extends StatelessWidget {
  const _ElectronicsQtyControls({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3EA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD5E6D8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMinus,
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.remove, size: 15, color: Color(0xFF121A14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelMedium(
                color: const Color(0xFF121A14),
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          InkWell(
            onTap: onPlus,
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.add, size: 15, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElectronicsPromoRow extends StatelessWidget {
  const _ElectronicsPromoRow({
    required this.controller,
    required this.busy,
    required this.onSubmit,
    this.focusNode,
    this.appliedCode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool busy;
  final VoidCallback onSubmit;
  final String? appliedCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E6E0)),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: AppTextStyles.bodySmall(
                    color: const Color(0xFF121A14),
                  ).copyWith(fontSize: 14, height: 1.28),
                  decoration: InputDecoration(
                    hintText: 'Promo code',
                    hintStyle: AppTextStyles.bodySmall(
                      color: const Color(0xFF6B756E),
                    ).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.28,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: busy ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: const Color(0xFFDCE7D4),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  busy ? '…' : 'Apply',
                  style: AppTextStyles.labelMedium(color: AppColors.white)
                      .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (appliedCode != null && appliedCode!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '✓ $appliedCode applied',
            style: AppTextStyles.labelSmall(
              color: AppColors.primary,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _QtyControls extends StatelessWidget {
  const _QtyControls({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onMinus,
            child: Icon(
              quantity <= 1 ? Icons.delete_outline : Icons.remove,
              size: 15,
              color: quantity <= 1 ? const Color(0xFFC0392B) : AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Text(
              '$quantity',
              style: AppTextStyles.labelMedium().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: onPlus,
            child: const Icon(Icons.add, size: 15, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _UpsellCard extends StatelessWidget {
  const _UpsellCard({required this.item, required this.onAdd});

  final CartUpsellItem item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 120,
                  height: 90,
                  color: item.imageColor,
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const Alignment(-0.6, -1),
                                end: const Alignment(0.6, 1),
                                colors: [item.imageColor, const Color(0xFF15302B)],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: const Alignment(-0.6, -1),
                              end: const Alignment(0.6, 1),
                              colors: [item.imageColor, const Color(0xFF15302B)],
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8DD)),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall(
              color: AppColors.textPrimary,
            ).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
          Text(
            item.priceLabel,
            style: AppTextStyles.labelSmall(
              color: AppColors.textPrimary,
            ).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupSectionHeader extends StatelessWidget {
  const _PickupSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 15,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: AppTextStyles.titleSmall(color: const Color(0xFF1A1A1A)).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _PickupHeader extends StatelessWidget {
  const _PickupHeader({required this.info});

  final CartPickupInfo info;

  Future<void> _openMap(BuildContext context) async {
    final url = info.mapUrl?.trim();
    Uri? uri;
    if (url != null && url.isNotEmpty) {
      uri = Uri.tryParse(url);
    } else if (info.latitude != null && info.longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${info.latitude},${info.longitude}',
      );
    } else {
      final q = Uri.encodeComponent(
        [info.title, info.address].where((s) => s.trim().isNotEmpty).join(' '),
      );
      if (q.isNotEmpty) {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
      }
    }
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Map location unavailable')),
      );
      return;
    }
    if (!await canLaunchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = info.latitude != null && info.longitude != null;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _openMap(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 64.w,
                    height: 64.w,
                    child: hasCoords
                        ? AppMapPreview(
                            latitude: info.latitude!,
                            longitude: info.longitude!,
                            height: 64.w,
                            borderRadius: BorderRadius.circular(12.r),
                          )
                        : Container(
                            color: const Color(0xFFE4EAE0),
                            alignment: Alignment.center,
                            child: Container(
                              width: 26.w,
                              height: 26.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on,
                                size: 16.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A))
                          .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      info.address,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E))
                          .copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEFE0),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 12.sp, color: const Color(0xFFE08A1E)),
                          SizedBox(width: 4.w),
                          Text(
                            info.readyLabel,
                            style: AppTextStyles.caption(color: const Color(0xFFE08A1E))
                                .copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5.sp,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openMap(context),
              borderRadius: BorderRadius.circular(9.r),
              child: Container(
                width: double.infinity,
                height: 33.h,
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE6EBE3)),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.near_me, size: 15.sp, color: const Color(0xFF2E7D32)),
                    SizedBox(width: 6.w),
                    Text(
                      'Map',
                      style: AppTextStyles.labelSmall(color: const Color(0xFF2E7D32))
                          .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupCartItemRow extends StatelessWidget {
  const _PickupCartItemRow({required this.item});

  final CartLineItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}×',
              style: AppTextStyles.caption(color: const Color(0xFF2E7D32)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.labelMedium(color: const Color(0xFF1A1A1A))
                      .copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.caption(color: const Color(0xFF6B7B6E))
                        .copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.unitPriceLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupCheckoutFooter extends StatelessWidget {
  const _PickupCheckoutFooter({
    required this.totalLabel,
    required this.onCheckout,
  });

  final String totalLabel;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8DD))),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: onCheckout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Go to checkout',
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  totalLabel,
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoApplyRow extends StatelessWidget {
  const _PromoApplyRow({
    required this.controller,
    required this.busy,
    required this.onSubmit,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8DD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: AppTextStyles.bodySmall(
                color: AppColors.textPrimary,
              ).copyWith(fontSize: 14, height: 1.28),
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                hintStyle: AppTextStyles.bodySmall(
                  color: const Color(0xFF6B7B6E),
                ).copyWith(fontSize: 14, height: 1.28),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          TextButton(
            onPressed: busy ? null : onSubmit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              busy ? '…' : 'Submit',
              style: AppTextStyles.labelMedium(
                color: AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _KitchenNoteDialog extends StatefulWidget {
  const _KitchenNoteDialog({required this.initialText});

  final String initialText;

  @override
  State<_KitchenNoteDialog> createState() => _KitchenNoteDialogState();
}

class _KitchenNoteDialogState extends State<_KitchenNoteDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(NavigationStrings.noteForKitchen),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        maxLines: 4,
        maxLength: 500,
        decoration: const InputDecoration(
          hintText: NavigationStrings.noteForKitchenSubtitle,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final text = _controller.text.trim();
            _focusNode.unfocus();
            Navigator.of(context).pop(text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
