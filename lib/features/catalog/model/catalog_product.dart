/// Multi-store catalog models.
///
/// Food and variant catalogs are different products, not two views of the
/// same option list.
///
/// [CatalogMode.modifiers] is the existing Food path. The customer picks
/// `optionGroups` (sent as `optionIds`) and extras (`addonIds`). Those
/// choices are not SKUs. The charged price is the product base price plus
/// option and addon deltas, and that math stays in the Food item screens.
/// This file does not parse `optionGroups`.
///
/// [CatalogMode.variants] is Fashion, Electronics, Vape, and Flowers. Axes
/// only describe how to find one row in [CatalogProduct.variants]. The cart
/// line is `productId` + `variantId` + optional `addonIds`. The charged unit
/// price is that variant's absolute [CatalogVariant.price], never a base
/// price plus a size or colour delta.
///
/// `CatalogAddon` is the extras list on a catalog payload (`name`, numeric
/// `price`, `isActive`). Food screens keep using `BrowseAddonOption`, which
/// is a display row (string price, `label`) and is not this API shape.
library;

enum CatalogMode {
  /// Today's Food path: option groups and addons. No `variantId`.
  modifiers('MODIFIERS'),

  /// Fashion, Electronics, Vape, Flowers: axis selection resolves a SKU.
  variants('VARIANTS');

  const CatalogMode(this.apiValue);

  final String apiValue;

  /// `HYBRID` and any unknown mode stay null. Hybrid is not implemented.
  static CatalogMode? tryParse(String? raw) {
    final value = raw?.trim().toUpperCase();
    for (final mode in values) {
      if (mode.apiValue == value) return mode;
    }
    return null;
  }

  bool get isModifiers => this == modifiers;
  bool get isVariants => this == variants;
}

/// API `stockStatus` strings. Mobile does not recompute the threshold.
abstract final class CatalogStockStatus {
  static const inStock = 'IN_STOCK';
  static const lowStock = 'LOW_STOCK';
  static const outOfStock = 'OUT_OF_STOCK';
}

/// API `uiHint` strings. The axis widget renders [pill] and [swatch].
abstract final class CatalogUiHint {
  static const pill = 'PILL';
  static const swatch = 'SWATCH';

  /// Reserved by the API. The axis widget falls back to pills until a
  /// dropdown design exists.
  static const dropdown = 'DROPDOWN';
}

class CatalogProduct {
  const CatalogProduct({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.catalogMode,
    this.axes = const [],
    this.variants = const [],
    this.addons = const [],
    this.restrictions,
    this.ageRestriction,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? imageUrl;
  final CatalogMode? catalogMode;
  final List<CatalogAxis> axes;
  final List<CatalogVariant> variants;
  final List<CatalogAddon> addons;
  final CatalogRestrictions? restrictions;
  final CatalogAgeRestriction? ageRestriction;

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    return CatalogProduct(
      id: _asString(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      imageUrl: _asString(json['imageUrl']),
      catalogMode: CatalogMode.tryParse(_asString(json['catalogMode'])),
      axes: _mapList(json['axes'], CatalogAxis.fromJson),
      variants: _mapList(json['variants'], CatalogVariant.fromJson),
      addons: _mapList(json['addons'], CatalogAddon.fromJson),
      restrictions: _mapOrNull(
        json['restrictions'],
        CatalogRestrictions.fromJson,
      ),
      ageRestriction: _mapOrNull(
        json['ageRestriction'],
        CatalogAgeRestriction.fromJson,
      ),
    );
  }
}

class CatalogAxis {
  const CatalogAxis({
    this.id,
    this.key,
    this.name,
    this.uiHint,
    this.isRequired,
    this.values = const [],
  });

  final String? id;

  /// Attribute key stored on each variant, e.g. `size`, `colour`, `nicotine`.
  final String? key;
  final String? name;

  /// [CatalogUiHint.pill], [CatalogUiHint.swatch], or [CatalogUiHint.dropdown].
  final String? uiHint;

  /// API `isRequired`. Null means the payload omitted it; variant selection
  /// treats that as required.
  final bool? isRequired;
  final List<CatalogAxisValue> values;

  factory CatalogAxis.fromJson(Map<String, dynamic> json) {
    return CatalogAxis(
      id: _asString(json['id']),
      key: _asString(json['key']),
      name: _asString(json['name']),
      uiHint: _asString(json['uiHint'])?.toUpperCase(),
      isRequired: _asBool(json['isRequired']),
      values: _mapList(json['values'], CatalogAxisValue.fromJson),
    );
  }
}

class CatalogAxisValue {
  const CatalogAxisValue({
    this.id,
    this.key,
    this.label,
    this.colorHex,
    this.sortOrder,
    this.isActive,
  });

  final String? id;

  /// Value written into `variant.attributes`, e.g. `m`, `navy`, `12mg`.
  final String? key;
  final String? label;
  final String? colorHex;
  final int? sortOrder;
  final bool? isActive;

  factory CatalogAxisValue.fromJson(Map<String, dynamic> json) {
    return CatalogAxisValue(
      id: _asString(json['id']),
      key: _asString(json['key']),
      label: _asString(json['label']),
      colorHex: _asString(json['colorHex']),
      sortOrder: _asInt(json['sortOrder']),
      isActive: _asBool(json['isActive']),
    );
  }
}

class CatalogVariant {
  const CatalogVariant({
    this.id,
    this.sku,
    this.attributes = const {},
    this.label,
    this.price,
    this.compareAtPrice,
    this.stockQty,
    this.stockStatus,
    this.isAvailable,
    this.imageUrl,
  });

  final String? id;
  final String? sku;

  /// Axis key → axis value key. Example: `{size: m, colour: navy}`.
  final Map<String, String> attributes;
  final String? label;

  /// Absolute unit price. Not a delta from a base price.
  final double? price;
  final double? compareAtPrice;
  final int? stockQty;
  final String? stockStatus;
  final bool? isAvailable;
  final String? imageUrl;

  factory CatalogVariant.fromJson(Map<String, dynamic> json) {
    return CatalogVariant(
      id: _asString(json['id']),
      sku: _asString(json['sku']),
      attributes: _stringMap(json['attributes']),
      label: _asString(json['label']),
      price: _asDouble(json['price']),
      compareAtPrice: _asDouble(json['compareAtPrice']),
      stockQty: _asInt(json['stockQty']),
      stockStatus: _asString(json['stockStatus'])?.toUpperCase(),
      isAvailable: _asBool(json['isAvailable']),
      imageUrl: _asString(json['imageUrl']),
    );
  }
}

/// Optional extra on a catalog product. Same payload for variant stores
/// (gift wrap, warranty, coil pack) and, when present, modifier stores.
///
/// Food item detail does not read this type. It still builds
/// `BrowseAddonOption` rows from its own parser.
class CatalogAddon {
  const CatalogAddon({
    this.id,
    this.name,
    this.price,
    this.imageUrl,
    this.isActive,
  });

  final String? id;
  final String? name;

  /// Absolute addon price added on top of the variant (or Food base) price
  /// by the cart. This model does not apply that sum.
  final double? price;
  final String? imageUrl;
  final bool? isActive;

  factory CatalogAddon.fromJson(Map<String, dynamic> json) {
    return CatalogAddon(
      id: _asString(json['id']),
      name: _asString(json['name']),
      price: _asDouble(json['price']),
      imageUrl: _asString(json['imageUrl']),
      isActive: _asBool(json['isActive']),
    );
  }
}

class CatalogRestrictions {
  const CatalogRestrictions({this.highValue, this.ageRestricted});

  final bool? highValue;
  final bool? ageRestricted;

  /// Customer indicator only. Missing or false stays off.
  /// Secure delivery stays on the server.
  bool get isHighValue => highValue == true;

  factory CatalogRestrictions.fromJson(Map<String, dynamic> json) {
    return CatalogRestrictions(
      highValue: _asBool(json['highValue']),
      ageRestricted: _asBool(json['ageRestricted']),
    );
  }
}

class CatalogAgeBanner {
  const CatalogAgeBanner({this.title, this.message});

  final String? title;
  final String? message;

  factory CatalogAgeBanner.fromJson(Map<String, dynamic> json) {
    return CatalogAgeBanner(
      title: _asString(json['title']),
      message: _asString(json['message']),
    );
  }
}

class CatalogAgeRestriction {
  const CatalogAgeRestriction({
    this.isRequired,
    this.minimumAge,
    this.canPurchase,
    this.cta,
    this.banner,
  });

  /// API field `required`. Named [isRequired] because `required` is a Dart
  /// built-in and cannot be a constructor parameter.
  final bool? isRequired;
  final int? minimumAge;
  final bool? canPurchase;

  /// `VERIFY_AGE` when the customer must verify before add to cart.
  /// Null when purchase is allowed.
  final String? cta;
  final CatalogAgeBanner? banner;

  /// Product button is "Verify your age" and add to cart stays blocked.
  bool get requiresAgeVerification {
    if (cta == 'VERIFY_AGE') return true;
    if (isRequired == true && canPurchase != true) return true;
    return false;
  }

  factory CatalogAgeRestriction.fromJson(Map<String, dynamic> json) {
    return CatalogAgeRestriction(
      isRequired: _asBool(json['required']),
      minimumAge: _asInt(json['minimumAge']),
      canPurchase: _asBool(json['canPurchase']),
      cta: _asString(json['cta']),
      banner: _mapOrNull(json['banner'], CatalogAgeBanner.fromJson),
    );
  }
}

List<T> _mapList<T>(Object? raw, T Function(Map<String, dynamic> json) parse) {
  if (raw is! List) return const [];
  final out = <T>[];
  for (final row in raw) {
    final map = _asMap(row);
    if (map == null) continue;
    out.add(parse(map));
  }
  return out;
}

T? _mapOrNull<T>(Object? raw, T Function(Map<String, dynamic> json) parse) {
  final map = _asMap(raw);
  if (map == null) return null;
  return parse(map);
}

Map<String, dynamic>? _asMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return null;
}

Map<String, String> _stringMap(Object? raw) {
  final map = _asMap(raw);
  if (map == null) return const {};
  final out = <String, String>{};
  for (final entry in map.entries) {
    final key = _asString(entry.key);
    final value = _asString(entry.value);
    if (key == null || value == null) continue;
    out[key] = value;
  }
  return out;
}

String? _asString(Object? raw) {
  if (raw == null) return null;
  final value = raw.toString().trim();
  if (value.isEmpty) return null;
  return value;
}

double? _asDouble(Object? raw) {
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw.trim());
  return null;
}

int? _asInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw.trim());
  return null;
}

bool? _asBool(Object? raw) {
  if (raw is bool) return raw;
  return null;
}
