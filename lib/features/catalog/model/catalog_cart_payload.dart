/// Body for `POST /cart/items` and the scheduled cart add.
///
/// Food modifiers and variant SKUs are different payloads. A variant line
/// sends `variantId` and addon ids only. `optionIds` are omitted, because the
/// server rejects them for `catalogMode = VARIANTS`. A modifier line never
/// sends `variantId`.
Map<String, dynamic> catalogCartItemBody({
  required String productId,
  required int quantity,
  bool replaceCart = false,
  String? variantId,
  List<String> optionIds = const [],
  List<String> addonIds = const [],
  String? geofenceTriggerId,
}) {
  final variant = variantId?.trim();
  final hasVariant = variant != null && variant.isNotEmpty;
  return {
    'productId': productId,
    'quantity': quantity,
    'replaceCart': replaceCart,
    if (hasVariant) 'variantId': variant,
    if (geofenceTriggerId != null && geofenceTriggerId.trim().isNotEmpty)
      'geofenceTriggerId': geofenceTriggerId.trim(),
    'options': {
      if (!hasVariant && optionIds.isNotEmpty) 'optionIds': optionIds,
      if (addonIds.isNotEmpty) 'addonIds': addonIds,
    },
  };
}
