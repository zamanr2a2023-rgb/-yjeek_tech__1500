import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/view/widgets/item_detail_widgets.dart';
import 'package:yjeek_app/features/catalog/model/catalog_product.dart';
import 'package:yjeek_app/features/catalog/model/variant_match.dart';

/// One catalog axis (Size, Colour, Storage, Nicotine, Bouquet size).
///
/// Displays the axis values, the current selection, and the disabled state
/// already computed by `availableValuesForAxis`. It does not match variants
/// and it does not calculate a price. Axis values have no delta; the parent
/// screen reads `variantPrice` from the matched [CatalogVariant].
///
/// Pills reuse [ItemOptionsLayout] / [ItemStorageChip]. Swatches reuse
/// [ItemColourSwatch]. Food option groups are not rendered here.
class VariantAxisSection extends StatelessWidget {
  const VariantAxisSection({
    super.key,
    required this.axis,
    required this.variants,
    required this.availableValues,
    required this.onChanged,
    this.selectedAttributes = const {},
    this.referencePrice,
    this.selectedValue,
    this.isGridView = true,
  });

  final CatalogAxis axis;
  final List<CatalogVariant> variants;
  final Map<String, String> selectedAttributes;
  final double? referencePrice;

  /// Axis value key → enabled. Keys are [CatalogAxisValue.key], the same
  /// strings stored on `variant.attributes`. A missing or false entry is
  /// disabled.
  final Map<String, bool> availableValues;

  /// Currently selected value key, not the display label.
  final String? selectedValue;

  /// Called with the axis value key when the customer picks an enabled value.
  final ValueChanged<String> onChanged;

  /// Passed through to [ItemOptionsLayout]. Grid shows chips or swatches;
  /// list shows the existing option rows.
  final bool isGridView;

  @override
  Widget build(BuildContext context) {
    final values = _visibleValues(axis);
    final name = axis.name?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (name != null && name.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
            child: Text(
              name,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                  .copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                    height: 1.2,
                  ),
            ),
          ),
        ItemOptionsLayout(
          isGridView: isGridView,
          multiple: false,
          gridStyle: _gridStyle(axis.uiHint),
          itemCount: values.length,
          labelAt: (index) => _label(values[index]),
          priceAt: (index) {
            final key = values[index].key;
            if (key == null || key.isEmpty) return '';
            final axisKey = axis.key;
            if (axisKey == null || axisKey.isEmpty) return '';
            final min = minSelectablePriceForAxisValue(
              variants: variants,
              axisKey: axisKey,
              valueKey: key,
              selectedAttributes: selectedAttributes,
            );
            return variantAxisValuePriceLabel(
              minPrice: min,
              referencePrice: referencePrice,
            );
          },
          selectedAt: (index) {
            final key = values[index].key;
            return key != null && key == selectedValue;
          },
          imageAt: (_) => null,
          swatchColorAt: (index) => _colorFromHex(values[index].colorHex),
          enabledAt: (index) => _isEnabled(values[index]),
          onTapAt: (index) {
            final value = values[index];
            final key = value.key;
            if (key == null || key.isEmpty || !_isEnabled(value)) return;
            onChanged(key);
          },
        ),
      ],
    );
  }

  bool _isEnabled(CatalogAxisValue value) {
    final key = value.key;
    if (key == null || key.isEmpty) return false;
    return availableValues[key] == true;
  }

  static List<CatalogAxisValue> _visibleValues(CatalogAxis axis) {
    final values = axis.values
        .where((value) => value.isActive != false)
        .toList();
    values.sort((a, b) {
      final byOrder = (a.sortOrder ?? 1 << 20).compareTo(
        b.sortOrder ?? 1 << 20,
      );
      if (byOrder != 0) return byOrder;
      return _label(a).compareTo(_label(b));
    });
    return values;
  }

  static String _label(CatalogAxisValue value) {
    final label = value.label?.trim();
    if (label != null && label.isNotEmpty) return label;
    return value.key ?? '';
  }

  /// [CatalogUiHint.dropdown] has no control yet, so it uses the pill chips.
  static ItemOptionGridStyle _gridStyle(String? uiHint) {
    switch (uiHint?.trim().toUpperCase()) {
      case CatalogUiHint.swatch:
        return ItemOptionGridStyle.swatches;
      case CatalogUiHint.pill:
      default:
        return ItemOptionGridStyle.chips;
    }
  }

  static Color? _colorFromHex(String? raw) {
    if (raw == null) return null;
    var hex = raw.trim();
    if (hex.isEmpty) return null;
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length != 6 && hex.length != 8) return null;
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    if (hex.length == 6) return Color(0xFF000000 | parsed);
    return Color(parsed);
  }
}
