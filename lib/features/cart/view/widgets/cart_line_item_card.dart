import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';

/// Full cart line — image, description, edit, quantity (all order methods).
class CartLineItemCard extends StatelessWidget {
  const CartLineItemCard({
    super.key,
    required this.item,
    required this.onMinus,
    required this.onPlus,
    this.onEdit,
    this.onRemoveSide,
    this.sideBusy = false,
  });

  final CartLineItem item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback? onEdit;
  final void Function(CartSideLine side)? onRemoveSide;
  final bool sideBusy;

  String get _detailText {
    if (item.subtitle.trim().isNotEmpty) return item.subtitle.trim();
    final duration = item.durationLabel?.trim();
    if (duration != null && duration.isNotEmpty) return duration;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8DD)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _textColumn(context)),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      _CartLineThumbnail(imageUrl: item.imageUrl),
                      const SizedBox(height: 6),
                      CartLineQtyControls(
                        quantity: item.quantity,
                        onMinus: onMinus,
                        onPlus: onPlus,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (item.sides.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(
                height: 12,
                thickness: 1,
                color: Color(0xFFE2E8DD),
              ),
              for (final side in item.sides) _SideRow(
                side: side,
                onRemove: side.cartItemId != null && onRemoveSide != null
                    ? () => onRemoveSide!(side)
                    : null,
                busy: sideBusy,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _textColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleSmall().copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            height: 1.25,
            color: AppColors.textPrimary,
          ),
        ),
        if (_detailText.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            _detailText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall(
              color: const Color(0xFF6B7B6E),
            ).copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.25,
            ),
          ),
        ],
        if (onEdit != null) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
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
                fontSize: 15,
                height: 1.25,
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
    );
  }
}

class _CartLineThumbnail extends StatelessWidget {
  const _CartLineThumbnail({this.imageUrl});

  final String? imageUrl;

  static const double _size = 68;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AppNetworkImage(
          url: url,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(12),
          showShimmer: false,
        ),
      );
    }

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment(-0.6, -1),
          end: Alignment(0.6, 1),
          colors: [Color(0xFF6B8A3A), Color(0xFF15302B)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_rounded,
        color: Colors.white.withValues(alpha: 0.85),
        size: 24,
      ),
    );
  }
}

class CartLineQtyControls extends StatelessWidget {
  const CartLineQtyControls({
    super.key,
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
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
              color: quantity <= 1
                  ? const Color(0xFFC0392B)
                  : AppColors.primary,
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

class _SideRow extends StatelessWidget {
  const _SideRow({
    required this.side,
    this.onRemove,
    this.busy = false,
  });

  final CartSideLine side;
  final VoidCallback? onRemove;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE7D4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${side.quantity}×',
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
              side.name,
              style: AppTextStyles.labelSmall(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            side.priceLabel,
            style: AppTextStyles.labelSmall(
              color: AppColors.textPrimary,
            ).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (onRemove != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: busy ? null : onRemove,
              icon: const Icon(Icons.close, size: 16, color: Color(0xFF6B7B6E)),
            ),
        ],
      ),
    );
  }
}
