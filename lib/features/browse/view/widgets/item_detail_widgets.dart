import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';

/// "Customize your order" + grid/list toggle (Figma CustomizeHeaderRow).
class ItemCustomizeHeader extends StatelessWidget {
  const ItemCustomizeHeader({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
    this.title = 'Customize your order',
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                  .copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                height: 1.2,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToggleBtn(
                  icon: Icons.grid_view_rounded,
                  active: isGridView,
                  onTap: () => onViewChanged(true),
                ),
                _ToggleBtn(
                  icon: Icons.view_list_rounded,
                  active: !isGridView,
                  onTap: () => onViewChanged(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 27.h,
        decoration: BoxDecoration(
          color: active ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 14.sp,
          color: active ? AppColors.textPrimary : const Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}

/// Accordion header for an option / extras group.
class ItemOptionAccordionHeader extends StatelessWidget {
  const ItemOptionAccordionHeader({
    super.key,
    required this.title,
    required this.hint,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final String hint;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    hint,
                    style: AppTextStyles.caption(
                      color: const Color(0xFF6B6B6B),
                    ).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 22.sp,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid option card (Figma OptionCard).
class ItemOptionGridCard extends StatelessWidget {
  const ItemOptionGridCard({
    super.key,
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
    this.imageUrl,
    this.multiple = false,
    this.enabled = true,
  });

  final String label;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;
  final String? imageUrl;
  final bool multiple;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: selected && enabled
                            ? AppColors.primary
                            : const Color(0xFFE2E2E2),
                        width: selected && enabled ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? AppNetworkImage(
                              url: imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: const ColoredBox(
                                color: Color(0xFFE8F5E9),
                              ),
                            )
                          : const ColoredBox(color: Color(0xFFE8F5E9)),
                    ),
                  ),
                  Positioned(
                    top: 5.h,
                    right: 5.w,
                    child: _SelectionBadge(
                      selected: selected && enabled,
                      multiple: multiple,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(color: AppColors.textPrimary)
                  .copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                height: 1.2,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              priceLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 11.sp,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List option row (Figma OptionRow) — optional stock status for fashion.
class ItemOptionListRow extends StatelessWidget {
  const ItemOptionListRow({
    super.key,
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
    this.imageUrl,
    this.swatchColor,
    this.multiple = false,
    this.showDivider = true,
    this.stockLabel,
    this.enabled = true,
    this.showThumb = true,
  });

  final String label;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;
  final String? imageUrl;
  final Color? swatchColor;
  final bool multiple;
  final bool showDivider;
  final String? stockLabel;
  final bool enabled;
  final bool showThumb;

  Color get _stockColor {
    final s = (stockLabel ?? '').toLowerCase();
    if (s.contains('out')) return const Color(0xFFBDBDBD);
    if (s.contains('low')) return const Color(0xFFD98C1A);
    if (s.contains('cleaner')) return const Color(0xFF6B6B6B);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final hasThumb = showThumb &&
        (swatchColor != null ||
            (imageUrl != null &&
                imageUrl!.isNotEmpty &&
                !imageUrl!.startsWith('color:')));

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                children: [
                  if (hasThumb) ...[
                    if (swatchColor != null)
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: swatchColor,
                          border: Border.all(
                            color: selected && enabled
                                ? AppColors.textPrimary
                                : const Color(0xFFE2E2E2),
                            width: selected && enabled ? 2 : 1,
                          ),
                        ),
                      )
                    else
                      _Thumb(
                        imageUrl: imageUrl,
                        selected: selected && enabled,
                      ),
                    SizedBox(width: 10.w),
                  ],
                  _SelectionControl(
                    selected: selected && enabled,
                    multiple: multiple,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium(
                            color: AppColors.textPrimary,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            height: 1.2,
                          ),
                        ),
                        if (stockLabel != null && stockLabel!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            stockLabel!,
                            style: AppTextStyles.caption(color: _stockColor)
                                .copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    priceLabel,
                    style: AppTextStyles.caption(
                      color: const Color(0xFF6B6B6B),
                    ).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showDivider)
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E2E2)),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.imageUrl, this.selected = false});

  final String? imageUrl;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    // Figma OptionRow thumb: 44×44, #E8F5E9, 8px radius, green border.
    final radius = BorderRadius.circular(8.r);
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: radius,
        border: Border.all(
          color: AppColors.primary,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7.r),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? AppNetworkImage(
                url: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: const ColoredBox(color: Color(0xFFE8F5E9)),
              )
            : const ColoredBox(color: Color(0xFFE8F5E9)),
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({
    required this.selected,
    required this.multiple,
  });

  final bool selected;
  final bool multiple;

  @override
  Widget build(BuildContext context) {
    // Grid: check badge for both modes (Figma OptionCard).
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(multiple ? 5.r : 11.r),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFA8A8A8),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Icon(Icons.check, size: 13.sp, color: AppColors.white)
          : null,
    );
  }
}

class _SelectionControl extends StatelessWidget {
  const _SelectionControl({
    required this.selected,
    required this.multiple,
  });

  final bool selected;
  final bool multiple;

  @override
  Widget build(BuildContext context) {
    // Extras / multi → square checkbox (5px radius).
    // Required single → radio circle with white center.
    if (multiple) {
      return Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFA8A8A8),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
            : null,
      );
    }

    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.white,
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFA8A8A8),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

/// Quantity label + green outline stepper (Figma QtyRow).
class ItemQuantityRow extends StatelessWidget {
  const ItemQuantityRow({
    super.key,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    this.label = 'Quantity',
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                .copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _StepBtn(icon: Icons.remove, onTap: onMinus),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '$quantity',
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                      .copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              _StepBtn(icon: Icons.add, onTap: onPlus),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Figma: 28×28 circle, white fill, 1px #4CAF50 stroke, green icon.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28.w,
        height: 28.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.primary),
      ),
    );
  }
}

/// Full-width green add-to-cart bar (Figma BottomBar / AddToCartBtn).
class ItemAddToCartBar extends StatelessWidget {
  const ItemAddToCartBar({
    super.key,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.busyLabel = 'Adding…',
  });

  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final String busyLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E2E2))),
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.zero,
          child: SizedBox(
            height: 46.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: busy ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.7,
                ),
                foregroundColor: AppColors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                busy ? busyLabel : label,
                style: AppTextStyles.labelMedium(color: AppColors.white)
                    .copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// How option choices render in grid mode (cart flow.md electronics).
enum ItemOptionGridStyle {
  /// 3-column square cards (fashion extras / default).
  cards,
  /// Horizontal storage/size chips (filled when selected).
  chips,
  /// Circular colour swatches.
  swatches,
}

/// Renders option choices in grid or list layout.
class ItemOptionsLayout extends StatelessWidget {
  const ItemOptionsLayout({
    super.key,
    required this.isGridView,
    required this.multiple,
    required this.itemCount,
    required this.labelAt,
    required this.priceAt,
    required this.selectedAt,
    required this.imageAt,
    required this.onTapAt,
    this.stockAt,
    this.enabledAt,
    this.gridStyle = ItemOptionGridStyle.cards,
    this.swatchColorAt,
  });

  final bool isGridView;
  final bool multiple;
  final int itemCount;
  final String Function(int index) labelAt;
  final String Function(int index) priceAt;
  final bool Function(int index) selectedAt;
  final String? Function(int index) imageAt;
  final void Function(int index) onTapAt;
  final String? Function(int index)? stockAt;
  final bool Function(int index)? enabledAt;
  final ItemOptionGridStyle gridStyle;
  final Color? Function(int index)? swatchColorAt;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    if (isGridView) {
      switch (gridStyle) {
        case ItemOptionGridStyle.chips:
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 10.h,
              children: [
                for (var i = 0; i < itemCount; i++)
                  ItemStorageChip(
                    label: labelAt(i),
                    priceLabel: priceAt(i),
                    selected: selectedAt(i),
                    enabled: enabledAt?.call(i) ?? true,
                    onTap: () => onTapAt(i),
                  ),
              ],
            ),
          );
        case ItemOptionGridStyle.swatches:
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                for (var i = 0; i < itemCount; i++)
                  ItemColourSwatch(
                    label: labelAt(i),
                    priceLabel: priceAt(i),
                    color: swatchColorAt?.call(i),
                    imageUrl: imageAt(i),
                    selected: selectedAt(i),
                    enabled: enabledAt?.call(i) ?? true,
                    onTap: () => onTapAt(i),
                  ),
              ],
            ),
          );
        case ItemOptionGridStyle.cards:
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                return ItemOptionGridCard(
                  label: labelAt(index),
                  priceLabel: priceAt(index),
                  selected: selectedAt(index),
                  imageUrl: imageAt(index),
                  multiple: multiple,
                  enabled: enabledAt?.call(index) ?? true,
                  onTap: () => onTapAt(index),
                );
              },
            ),
          );
      }
    }

    return Column(
      children: [
        for (var i = 0; i < itemCount; i++)
          ItemOptionListRow(
            label: labelAt(i),
            priceLabel: priceAt(i),
            selected: selectedAt(i),
            imageUrl: imageAt(i),
            swatchColor: swatchColorAt?.call(i),
            multiple: multiple,
            showDivider: i < itemCount - 1,
            stockLabel: stockAt?.call(i),
            enabled: enabledAt?.call(i) ?? true,
            showThumb: gridStyle != ItemOptionGridStyle.chips,
            onTap: () => onTapAt(i),
          ),
      ],
    );
  }
}

/// Storage / size chip (Figma SizeChips — solid green when selected).
class ItemStorageChip extends StatelessWidget {
  const ItemStorageChip({
    super.key,
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = selected && enabled;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 70.w,
          child: Column(
            children: [
              Container(
                height: 38.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: active
                        ? AppColors.primary
                        : const Color(0xFFE2E2E2),
                  ),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall(
                    color: active ? AppColors.white : AppColors.textPrimary,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                priceLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(
                  color: enabled
                      ? AppColors.primary
                      : const Color(0xFFBDBDBD),
                ).copyWith(fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colour circle swatch (Figma ColourSwatches).
class ItemColourSwatch extends StatelessWidget {
  const ItemColourSwatch({
    super.key,
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
    this.color,
    this.imageUrl,
    this.enabled = true,
  });

  final String label;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final String? imageUrl;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = selected && enabled;
    final fill = color ?? const Color(0xFFE8F5E9);
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 56.w,
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill,
                  border: Border.all(
                    color: active
                        ? AppColors.textPrimary
                        : const Color(0xFFE2E2E2),
                    width: active ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: active
                    ? Icon(
                        Icons.check,
                        size: 18.sp,
                        color: fill.computeLuminance() > 0.55
                            ? AppColors.textPrimary
                            : AppColors.white,
                      )
                    : null,
              ),
              SizedBox(height: 4.h),
              Text(
                priceLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(color: AppColors.primary)
                    .copyWith(fontSize: 10.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
