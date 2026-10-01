import 'package:yjeek_app/features/catalog/model/catalog_product.dart';

/// Pure variant-matrix helpers. No widgets and no network calls.
///
/// Food modifiers do not belong here. A Food line is `optionIds` + `addonIds`
/// priced as base + deltas inside the existing item detail state. These
/// functions only answer: which [CatalogVariant] row matches the selected
/// axis keys, which axis values can still form a purchasable row, and what
/// absolute price that row already carries.
///
/// Callers must not invent a price with `base + delta`. [variantPrice] returns
/// [CatalogVariant.price] unchanged.

/// The variant whose [CatalogVariant.attributes] equal [selectedAttributes].
///
/// Returns null until every axis key on that row is selected. An out-of-stock
/// row still matches so the caller can tell "this SKU exists" from "no such
/// combination". Use [variantIsSelectable] before enabling add to cart.
///
/// If two rows share the same attributes, the first one is returned. The API
/// contract is one variant per attribute combination.
CatalogVariant? matchVariant({
  required List<CatalogVariant> variants,
  required Map<String, String> selectedAttributes,
}) {
  for (final variant in variants) {
    if (_attributesMatch(variant.attributes, selectedAttributes)) {
      return variant;
    }
  }
  return null;
}

/// Enable flags for one axis, keyed by axis value key (`m`, `navy`, `12mg`).
///
/// A value is `true` only when some variant:
/// - carries that value on [axisKey]
/// - matches every other selected axis (the current axis is ignored, so the
///   customer can switch size without the old size hiding the alternatives)
/// - passes [variantIsSelectable]
///
/// [axisValueKeys] are included even when no variant uses them, as `false`.
/// Missing keys in the returned map should be treated as disabled.
Map<String, bool> availableValuesForAxis({
  required List<CatalogVariant> variants,
  required String axisKey,
  Map<String, String> selectedAttributes = const {},
  List<String> axisValueKeys = const [],
}) {
  if (axisKey.isEmpty) return const {};

  final keys = <String>[];
  final seen = <String>{};
  void addKey(String? key) {
    if (key == null || key.isEmpty || !seen.add(key)) return;
    keys.add(key);
  }

  for (final key in axisValueKeys) {
    addKey(key);
  }
  for (final variant in variants) {
    addKey(variant.attributes[axisKey]);
  }

  final enabled = <String, bool>{};
  for (final key in keys) {
    var selectable = false;
    for (final variant in variants) {
      if (variant.attributes[axisKey] != key) continue;
      if (!_matchesOtherAxes(variant.attributes, selectedAttributes, axisKey)) {
        continue;
      }
      if (!variantIsSelectable(variant)) continue;
      selectable = true;
      break;
    }
    enabled[key] = selectable;
  }
  return enabled;
}

/// Absolute unit price of the selected variant. Null when nothing is selected
/// or the payload omitted `price`.
double? variantPrice(CatalogVariant? selectedVariant) => selectedVariant?.price;

/// Variant unit plus selected addon prices.
///
/// Addon amounts are added as their own prices. This is not Food's
/// base-price-plus-option-delta formula, and it does not read a product base
/// price.
double? variantUnitWithAddons(
  CatalogVariant? selectedVariant,
  Iterable<double> addonPrices,
) {
  final price = variantPrice(selectedVariant);
  if (price == null) return null;
  var total = price;
  for (final addon in addonPrices) {
    total += addon;
  }
  return total;
}

/// True when every required axis has a value, a variant row matches, and that
/// row is purchasable.
///
/// An axis with `isRequired == null` counts as required. `isRequired: false`
/// does not. Stock comes only from [variantIsSelectable] (`stockStatus` /
/// `isAvailable`), never from a client-side quantity check.
bool variantSelectionReady({
  required List<CatalogAxis> axes,
  required Map<String, String> selectedAttributes,
  required CatalogVariant? matched,
}) {
  for (final axis in axes) {
    if (axis.isRequired == false) continue;
    final key = axis.key;
    if (key == null || key.isEmpty) continue;
    final value = selectedAttributes[key];
    if (value == null || value.isEmpty) return false;
  }
  if (matched == null) return false;
  return variantIsSelectable(matched);
}

/// Purchasable SKU: the row exists, `isAvailable` is not false, and
/// `stockStatus` is not `OUT_OF_STOCK`.
///
/// `LOW_STOCK` stays selectable. A missing `isAvailable` or `stockStatus` does
/// not by itself disable the row, because the API may omit either field.
bool variantIsSelectable(CatalogVariant variant) {
  if (variant.isAvailable == false) return false;
  final status = variant.stockStatus?.trim().toUpperCase();
  if (status == CatalogStockStatus.outOfStock) return false;
  return true;
}

bool _attributesMatch(
  Map<String, String> attributes,
  Map<String, String> selectedAttributes,
) {
  if (attributes.length != selectedAttributes.length) return false;
  for (final entry in selectedAttributes.entries) {
    if (attributes[entry.key] != entry.value) return false;
  }
  return true;
}

bool _matchesOtherAxes(
  Map<String, String> attributes,
  Map<String, String> selectedAttributes,
  String axisKey,
) {
  for (final entry in selectedAttributes.entries) {
    if (entry.key == axisKey) continue;
    if (attributes[entry.key] != entry.value) return false;
  }
  return true;
}
