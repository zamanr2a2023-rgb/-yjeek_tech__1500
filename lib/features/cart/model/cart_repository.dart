import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cashback_preview.dart';
import 'package:yjeek_app/features/cart/model/cart_referral_credit.dart';
import 'package:yjeek_app/features/browse/model/pharmacy_order_modes.dart';
import 'package:yjeek_app/features/cart/model/delivery_quote.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

enum CartOrderType {
  delivery('DELIVERY'),
  dineIn('DINE_IN'),
  pickup('PICKUP'),
  service('SERVICE');

  const CartOrderType(this.apiValue);
  final String apiValue;
}

/// Thrown when checkout rejects a voucher (wallet exclusive / expired).
class CheckoutVoucherException implements Exception {
  CheckoutVoucherException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Thrown when checkout rejects CASH / cash on delivery.
class CheckoutCashUnavailableException implements Exception {
  CheckoutCashUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// COD eligibility from GET /cart → `payment` (vendor cash + order shape).
class CartPaymentEligibility {
  const CartPaymentEligibility({
    required this.acceptsCashOrders,
    required this.cashOnDeliveryAvailable,
    this.cashOnDeliveryUnavailableReason,
  });

  final bool acceptsCashOrders;
  final bool cashOnDeliveryAvailable;
  final String? cashOnDeliveryUnavailableReason;

  static CartPaymentEligibility? tryParse(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return CartPaymentEligibility(
      acceptsCashOrders: raw['acceptsCashOrders'] != false,
      cashOnDeliveryAvailable: raw['cashOnDeliveryAvailable'] == true,
      cashOnDeliveryUnavailableReason:
          (raw['cashOnDeliveryUnavailableReason'] as String?)?.trim(),
    );
  }
}

/// Thrown when POST /cart/scheduled/items hits the 3-vendor cap (409).
class ScheduledVendorLimitException implements Exception {
  ScheduledVendorLimitException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CartSideLine {
  const CartSideLine({
    required this.name,
    required this.quantity,
    required this.priceLabel,
    this.cartItemId,
  });

  final String name;
  final int quantity;
  final String priceLabel;
  final String? cartItemId;
}

/// One server cart row backing a displayed line (merged lines have many).
class CartLineSegment {
  const CartLineSegment({required this.id, required this.quantity});

  final String id;
  final int quantity;
}

class CartLineItem {
  const CartLineItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.subtitle,
    required this.quantity,
    required this.unitPriceLabel,
    this.compareAtPriceLabel,
    this.imageUrl,
    this.sides = const [],
    this.durationLabel,
    this.durationMinutes,
    this.variantId,
    this.variantLabel,
    this.segments,
  });

  final String id;
  final String productId;
  final String name;
  final String subtitle;
  final int quantity;
  final String unitPriceLabel;

  /// Set when the line is a catalog SKU. Null on Food and older cart lines.
  final String? variantId;

  /// Server label such as `M / Navy`. Null when the line has no variant.
  final String? variantLabel;
  final String? compareAtPriceLabel;
  final String? imageUrl;
  final List<CartSideLine> sides;

  /// Service duration label from prep time plus option duration changes.
  final String? durationLabel;

  /// Total minutes for this line (prep + option deltas) × quantity.
  final int? durationMinutes;

  /// Populated when identical server rows are merged for display.
  final List<CartLineSegment>? segments;

  List<CartLineSegment> get lineSegments =>
      segments ??
      [
        if (id.isNotEmpty) CartLineSegment(id: id, quantity: quantity),
      ];
}

/// Stable key for lines that share product, variant, and add-ons.
String cartLineMergeKey(CartLineItem item) {
  final sideParts = item.sides
      .map((s) => '${s.name.trim().toLowerCase()}:${s.quantity}')
      .toList()
    ..sort();
  return [
    item.productId,
    item.variantId ?? '',
    item.variantLabel ?? '',
    sideParts.join(','),
  ].join('|');
}

double? _parseBhdLabel(String label) {
  final cleaned = label.replaceAll('BHD', '').trim();
  return double.tryParse(cleaned);
}

double _unitDisplayAmount(CartLineItem item, CartOrderType type) {
  final labeled = _parseBhdLabel(item.unitPriceLabel) ?? 0;
  if (type == CartOrderType.pickup && item.quantity > 0) {
    return labeled / item.quantity;
  }
  return labeled;
}

List<CartLineSegment> _sortedSegments(List<CartLineSegment> segments) {
  final copy = List<CartLineSegment>.from(segments);
  copy.sort((a, b) => a.id.compareTo(b.id));
  return copy;
}

List<CartLineItem> mergeEquivalentCartLines(
  List<CartLineItem> items,
  CartOrderType type,
) {
  if (items.length < 2) return items;

  final merged = <String, CartLineItem>{};
  final firstIndex = <String, int>{};

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    final key = cartLineMergeKey(item);
    firstIndex.putIfAbsent(key, () => i);
    final existing = merged[key];
    if (existing == null) {
      merged[key] = item;
      continue;
    }

    final totalQty = existing.quantity + item.quantity;
    final unit = _unitDisplayAmount(existing, type);
    final priceLabel = type == CartOrderType.pickup
        ? _money(unit * totalQty)
        : _money(unit);

    var durationMinutes = existing.durationMinutes;
    final addDuration = item.durationMinutes;
    if (durationMinutes != null || addDuration != null) {
      durationMinutes = (durationMinutes ?? 0) + (addDuration ?? 0);
    }

    final segments = _sortedSegments([
      ...existing.lineSegments,
      CartLineSegment(id: item.id, quantity: item.quantity),
    ]);

    merged[key] = CartLineItem(
      id: segments.first.id,
      productId: existing.productId,
      name: existing.name,
      subtitle: existing.subtitle,
      quantity: totalQty,
      unitPriceLabel: priceLabel,
      compareAtPriceLabel: existing.compareAtPriceLabel,
      imageUrl: existing.imageUrl,
      sides: existing.sides,
      durationLabel: existing.durationLabel ?? item.durationLabel,
      durationMinutes: durationMinutes,
      variantId: existing.variantId,
      variantLabel: existing.variantLabel,
      segments: segments,
    );
  }

  final keys = merged.keys.toList()
    ..sort((a, b) => firstIndex[a]!.compareTo(firstIndex[b]!));
  return [for (final key in keys) merged[key]!];
}

/// Preserves row order across cart refreshes (API often reorders after qty patch).
List<CartLineItem> stableCartLineOrder(
  List<CartLineItem> items, {
  List<String>? previousKeys,
}) {
  if (items.isEmpty) return items;

  final byKey = <String, CartLineItem>{
    for (final item in items) cartLineMergeKey(item): item,
  };
  final pending = byKey.keys.toSet();
  final ordered = <CartLineItem>[];

  if (previousKeys != null) {
    for (final key in previousKeys) {
      if (pending.remove(key)) {
        ordered.add(byKey[key]!);
      }
    }
  }

  for (final item in items) {
    final key = cartLineMergeKey(item);
    if (pending.remove(key)) {
      ordered.add(byKey[key]!);
    }
  }
  return ordered;
}

class CartUpsellItem {
  const CartUpsellItem({
    required this.productId,
    required this.name,
    required this.priceLabel,
    this.imageColor = const Color(0xFF6B4A2A),
    this.durationLabel,
    this.imageUrl,
  });

  final String productId;
  final String name;
  final String priceLabel;
  final Color imageColor;

  /// Service duration, e.g. "30 min" (from product prepTimeMin).
  final String? durationLabel;
  final String? imageUrl;
}

class CartPickupInfo {
  const CartPickupInfo({
    required this.title,
    required this.address,
    required this.readyLabel,
    this.mapUrl,
    this.latitude,
    this.longitude,
    this.noShowPolicy,
    this.vendorLabel,
    this.scheduledAt,
  });

  final String title;
  final String address;
  final String readyLabel;
  final String? mapUrl;
  final double? latitude;
  final double? longitude;
  final String? noShowPolicy;

  /// e.g. "Brew & Bean · Seef"
  final String? vendorLabel;
  final DateTime? scheduledAt;
}

class PickupTimeSlot {
  const PickupTimeSlot({
    required this.id,
    required this.label,
    this.scheduledAt,
    this.isAsap = false,
  });

  final String id;
  final String label;
  final DateTime? scheduledAt;
  final bool isAsap;
}

class PickupSlotsSnapshot {
  const PickupSlotsSnapshot({
    required this.slots,
    required this.selectedId,
    this.readyInMin = 15,
    this.readyLabel,
  });

  final List<PickupTimeSlot> slots;
  final String selectedId;
  final int readyInMin;
  final String? readyLabel;
}

class CartDeliveryEta {
  const CartDeliveryEta({
    required this.etaMin,
    required this.etaMax,
    required this.etaLabel,
  });

  final int etaMin;
  final int etaMax;
  final String etaLabel;
}

class DineInSeatingOption {
  const DineInSeatingOption({
    required this.preference,
    required this.available,
  });

  final String preference;
  final bool available;
}

class DineInOccasionPackage {
  const DineInOccasionPackage({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;
}

class CartDineInInfo {
  const CartDineInInfo({
    required this.readyInMin,
    required this.readyLabel,
    this.prepMode,
    this.scheduledAt,
    this.seatingMode,
    this.allowAny = false,
    this.seatingOptions = const [],
    this.occasionEnabled = false,
    this.occasionPackages = const [],
    this.selectedPackageId,
  });

  final int readyInMin;
  final String readyLabel;
  final String? prepMode;
  final DateTime? scheduledAt;
  final String? seatingMode;
  final bool allowAny;
  final List<DineInSeatingOption> seatingOptions;
  final bool occasionEnabled;
  final List<DineInOccasionPackage> occasionPackages;
  final String? selectedPackageId;
}

class DineInTimeSlot {
  const DineInTimeSlot({
    required this.id,
    required this.label,
    required this.scheduledAt,
    required this.scheduledAtIso,
  });

  final String id;
  final String label;
  /// Parsed instant (UTC) for comparisons.
  final DateTime scheduledAt;
  /// Exact ISO from API — sent back on PATCH to avoid drift.
  final String scheduledAtIso;
}

class DineInSlotsSnapshot {
  const DineInSlotsSnapshot({
    required this.slots,
    required this.selectedId,
    this.readyInMin = 60,
    this.readyLabel,
  });

  final List<DineInTimeSlot> slots;
  final String selectedId;
  final int readyInMin;
  final String? readyLabel;
}

class CartSnapshot {
  const CartSnapshot({
    required this.orderType,
    required this.vendorName,
    required this.items,
    required this.billLines,
    required this.upsell,
    required this.upsellTitle,
    required this.includeCutlery,
    required this.totalLabel,
    required this.cashbackLabel,
    this.vendorId,
    this.kitchenNote,
    this.partySize,
    this.seatingPreference,
    this.specialOccasion,
    this.pickup,
    this.itemCount = 0,
    this.upsellSubtitle,
    this.serviceMode,
    this.serviceScheduledAt,
    this.serviceVenueAddress,
    this.promoCode,
    this.isVape = false,
    this.totalAmount = 0,
    this.vatAmount,
    this.grandTotal,
    this.dineInPrepMode,
    this.scheduledDineInAt,
    this.storeTypeSlug,
    this.deliveryEta,
    this.dineIn,
    this.cashbackPreview,
    this.pricingModel,
    this.delivery,
    this.cartId,
    this.referralCredit,
    this.payment,
  });

  final CartOrderType orderType;
  final String vendorName;
  final String? vendorId;
  final List<CartLineItem> items;
  final List<BillLine> billLines;
  final List<CartUpsellItem> upsell;
  final String upsellTitle;
  final bool includeCutlery;
  final String? kitchenNote;
  final int? partySize;
  final String? seatingPreference;
  final String? specialOccasion;
  final CartPickupInfo? pickup;
  final String totalLabel;
  final String cashbackLabel;
  final CashbackPreview? cashbackPreview;
  final int itemCount;

  /// e.g. "Popular with Haircut & styling" (SERVICE carts).
  final String? upsellSubtitle;

  /// IN_SALON or AT_HOME (SERVICE carts).
  final String? serviceMode;
  final DateTime? serviceScheduledAt;

  /// Vendor branch address for IN_SALON (from cart `service.branch`).
  final String? serviceVenueAddress;
  final String? promoCode;

  /// Vape / nicotine store cart (scheduled delivery tiers). Not the same as ageRestricted.
  final bool isVape;

  /// Server pre-VAT total (`summary.totalAmount`).
  final double totalAmount;

  /// Server VAT (`summary.vatAmount`). Null when the payload omits it.
  final double? vatAmount;

  /// Server payable before tip (`summary.grandTotal`).
  final double? grandTotal;

  /// PREPARE_NOW | PREPARE_ON_ARRIVAL (DINE_IN).
  final String? dineInPrepMode;
  final DateTime? scheduledDineInAt;

  /// Vendor store type slug, e.g. 'food', 'electronics', 'vape'.
  final String? storeTypeSlug;

  /// Delivery / ready window from API (`deliveryEta`).
  final CartDeliveryEta? deliveryEta;

  /// Dine-in ready window from API (`dineIn`).
  final CartDineInInfo? dineIn;

  /// `legacy_flat` or `delivery_fees_v1` when the cart payload includes it.
  final String? pricingModel;

  /// Null for pickup, dine-in, and services. Present for delivery quotes.
  final DeliveryQuote? delivery;

  final String? cartId;
  final CartReferralCredit? referralCredit;
  final CartPaymentEligibility? payment;

  /// Electronics vendor cart — no cutlery / kitchen-note preferences.
  bool get isElectronics => storeTypeSlug == 'electronics';

  bool get isPharmacyStore =>
      storeTypeSlug?.trim().toLowerCase() == 'pharmacy';

  /// Fashion / flowers / variant retail on DELIVERY — tier picker, not cutlery.
  bool get usesScheduledDeliveryMethods {
    if (orderType != CartOrderType.delivery || isVape) return false;
    final slug = storeTypeSlug?.trim().toLowerCase() ?? '';
    const onDemandFood = {'food', 'cafe', 'restaurant', 'coffee'};
    if (onDemandFood.contains(slug)) return false;
    if (items.any((i) => (i.variantId ?? '').isNotEmpty)) return true;
    const scheduledRetail = {'fashion', 'flowers', 'electronics', 'pharmacy'};
    return scheduledRetail.contains(slug);
  }

  /// Pharmacy Deliver Now uses the delivery cart; scheduled SKUs use `/cart/scheduled`.
  bool showsScheduledDeliveryTierPicker(PharmacySession? pharmacySession) {
    if (!usesScheduledDeliveryMethods) return false;
    if (!isPharmacyStore) return true;
    if (pharmacySession != null &&
        vendorId != null &&
        vendorId!.isNotEmpty &&
        pharmacySession.matches(vendorId)) {
      if (pharmacySession.continueDeliveryAsScheduled) return true;
      return pharmacySession.mode == PharmacyDeliveryMode.scheduled;
    }
    return false;
  }

  bool get hasItems => itemCount > 0 || items.isNotEmpty;

  static CartSnapshot empty(CartOrderType type) => CartSnapshot(
    orderType: type,
    vendorName: '',
    items: const [],
    billLines: const [],
    upsell: const [],
    upsellTitle: type == CartOrderType.pickup
        ? 'You might also like'
        : 'Make it a combo',
    includeCutlery: false,
    totalLabel: 'BHD 0.000',
    cashbackLabel: '+ BHD 0.000',
    totalAmount: 0,
  );
}

class CartRepository {
  const CartRepository(
    this._apiClient,
    this._storage, {
    AddressesRepository? addresses,
  }) : _addresses = addresses;

  final ApiClient _apiClient;
  final StorageService _storage;
  final AddressesRepository? _addresses;

  String? get _token => _storage.token;

  String _cartPath(CartOrderType type, {String? deliverySpeed}) {
    final speed = deliverySpeed?.trim();
    final typeQuery = 'type=${type.apiValue}';
    if (speed == null || speed.isEmpty) return '/cart?$typeQuery';
    return '/cart?$typeQuery&deliverySpeed=${Uri.encodeQueryComponent(speed)}';
  }

  Future<CartSnapshot> fetchCart(
    CartOrderType type, {
    String? deliverySpeed,
  }) async {
    if (!_storage.hasSession) return CartSnapshot.empty(type);

    final response = await _apiClient.getJson(
      _cartPath(type, deliverySpeed: deliverySpeed),
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return CartSnapshot.empty(type);
    return cartSnapshotFromJson(data, type);
  }

  /// GET /cart?type= — includes deliveryOptions when vendor is vape/scheduled retail.
  Future<({CartSnapshot cart, List<Map<String, dynamic>> deliveryOptions})>
  fetchCartDetailed(CartOrderType type, {String? deliverySpeed}) async {
    if (!_storage.hasSession) {
      return (
        cart: CartSnapshot.empty(type),
        deliveryOptions: const <Map<String, dynamic>>[],
      );
    }
    final response = await _apiClient.getJson(
      _cartPath(type, deliverySpeed: deliverySpeed),
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return (
        cart: CartSnapshot.empty(type),
        deliveryOptions: const <Map<String, dynamic>>[],
      );
    }
    final options = _deliveryOptionsFromJson(data['deliveryOptions']);
    return (cart: cartSnapshotFromJson(data, type), deliveryOptions: options);
  }

  Future<CartSnapshot?> fetchScheduledCart() async {
    final detailed = await fetchScheduledCartDetailed();
    return detailed.cart;
  }

  Future<({CartSnapshot? cart, List<Map<String, dynamic>> deliveryOptions})>
  fetchScheduledCartDetailed({String? deliverySpeed}) async {
    if (!_storage.hasSession) {
      return (cart: null, deliveryOptions: const <Map<String, dynamic>>[]);
    }
    final speed = deliverySpeed?.trim();
    final path = speed == null || speed.isEmpty
        ? '/cart/scheduled'
        : '/cart/scheduled?deliverySpeed=${Uri.encodeQueryComponent(speed)}';
    final response = await _apiClient.getJson(path, bearerToken: _token);
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return (cart: null, deliveryOptions: const <Map<String, dynamic>>[]);
    }
    final options = _deliveryOptionsFromJson(data['deliveryOptions']);
    return (
      cart: scheduledCartSnapshotFromJson(data),
      deliveryOptions: options,
    );
  }

  /// Applies +1 / −1 to a displayed line (including merged server rows).
  Future<CartSnapshot> bumpCartLineQuantity({
    required CartOrderType type,
    required CartLineItem item,
    required int delta,
  }) async {
    if (delta == 0) return fetchCart(type);
    final segments = item.lineSegments;
    if (segments.isEmpty) return fetchCart(type);

    if (delta > 0) {
      final target = segments.first;
      return updateItemQuantity(
        type: type,
        itemId: target.id,
        quantity: target.quantity + delta,
      );
    }

    for (final seg in segments) {
      if (seg.quantity > 1) {
        return updateItemQuantity(
          type: type,
          itemId: seg.id,
          quantity: seg.quantity + delta,
        );
      }
    }
    return removeItem(type: type, itemId: segments.last.id);
  }

  Future<CartSnapshot?> bumpScheduledCartLineQuantity({
    required CartLineItem item,
    required int delta,
  }) async {
    if (delta == 0) return fetchScheduledCart();
    final segments = item.lineSegments;
    if (segments.isEmpty) return fetchScheduledCart();

    if (delta > 0) {
      final target = segments.first;
      return updateScheduledItemQuantity(
        itemId: target.id,
        quantity: target.quantity + delta,
      );
    }

    for (final seg in segments) {
      if (seg.quantity > 1) {
        return updateScheduledItemQuantity(
          itemId: seg.id,
          quantity: seg.quantity + delta,
        );
      }
    }
    return removeScheduledItem(segments.last.id);
  }

  Future<CartSnapshot> updateItemQuantity({
    required CartOrderType type,
    required String itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return removeItem(type: type, itemId: itemId);
    }
    final response = await _apiClient.patchJson(
      '/cart/items/$itemId?type=${type.apiValue}',
      {'quantity': quantity},
      bearerToken: _token,
    );
    final data = response.data;
    if (data != null) return cartSnapshotFromJson(data, type);
    return fetchCart(type);
  }

  Future<CartSnapshot> removeItem({
    required CartOrderType type,
    required String itemId,
  }) async {
    final response = await _apiClient.deleteJson(
      '/cart/items/$itemId?type=${type.apiValue}',
      bearerToken: _token,
    );
    final data = response.data;
    if (data != null) return cartSnapshotFromJson(data, type);
    return fetchCart(type);
  }

  Future<CartSnapshot> addProduct({
    required CartOrderType type,
    required String productId,
    int quantity = 1,
    String? vendorId,
    String? geofenceTriggerId,
    String? deliveryAddressId,
    double? deliveryLatitude,
    double? deliveryLongitude,
  }) async {
    final addresses = _addresses;
    if (type == CartOrderType.delivery &&
        addresses != null &&
        _storage.hasSession &&
        vendorId != null &&
        vendorId.isNotEmpty) {
      final range = await checkDeliveryRange(
        addresses: addresses,
        vendorId: vendorId,
        addressId: deliveryAddressId,
        latitude: deliveryLatitude,
        longitude: deliveryLongitude,
        failClosed: false,
      );
      if (range.isOutOfRange) {
        throw OutOfDeliveryRangeException();
      }
    }

    final response = await _apiClient
        .postJson('/cart/items?type=${type.apiValue}', {
          'productId': productId,
          'quantity': quantity,
          if (geofenceTriggerId != null && geofenceTriggerId.isNotEmpty)
            'geofenceTriggerId': geofenceTriggerId,
        }, bearerToken: _token);
    if (!response.ok) {
      if (isOutOfDeliveryRangeCode(response.errorCode) ||
          isOutOfDeliveryRangeMessage(response.message)) {
        throw OutOfDeliveryRangeException(
          response.message ??
              'This address is outside the vendor delivery area',
        );
      }
      throw Exception(response.message ?? 'Could not add to cart');
    }
    final data = response.data;
    if (data != null) return cartSnapshotFromJson(data, type);
    return fetchCart(type);
  }

  Future<CartSnapshot> updatePreferences({
    required CartOrderType type,
    bool? includeCutlery,
    String? kitchenNote,
    int? partySize,
    String? seatingPreference,
    bool? specialOccasionEnabled,
    String? specialOccasionPackageId,
    bool clearSpecialOccasionPackage = false,
    String? serviceMode,
    DateTime? serviceScheduledAt,
    String? dineInPrepMode,
    DateTime? scheduledDineInAt,
    String? scheduledDineInAtIso,
    bool clearScheduledDineInAt = false,
    DateTime? pickupScheduledAt,
    bool clearPickupScheduledAt = false,
  }) async {
    final body = <String, dynamic>{
      if (includeCutlery != null) 'includeCutlery': includeCutlery,
      if (kitchenNote != null) 'kitchenNote': kitchenNote,
      if (partySize != null) 'partySize': partySize,
      if (seatingPreference != null) 'seatingPreference': seatingPreference,
      if (specialOccasionEnabled != null)
        'specialOccasion': specialOccasionEnabled
            ? 'Candles & a little surprise on the table'
            : null,
      if (clearSpecialOccasionPackage)
        'specialOccasionPackageId': null
      else if (specialOccasionPackageId != null)
        'specialOccasionPackageId': specialOccasionPackageId,
      if (serviceMode != null) 'serviceMode': serviceMode,
      if (serviceScheduledAt != null)
        'serviceScheduledAt': serviceScheduledAt.toUtc().toIso8601String(),
      if (dineInPrepMode != null) 'dineInPrepMode': dineInPrepMode,
      if (clearScheduledDineInAt)
        'scheduledDineInAt': null
      else if (scheduledDineInAtIso != null && scheduledDineInAtIso.isNotEmpty)
        'scheduledDineInAt': scheduledDineInAtIso
      else if (scheduledDineInAt != null)
        'scheduledDineInAt': scheduledDineInAt.toUtc().toIso8601String(),
      if (clearPickupScheduledAt)
        'pickupScheduledAt': null
      else if (pickupScheduledAt != null)
        'pickupScheduledAt': pickupScheduledAt.toUtc().toIso8601String(),
    };
    final response = await _apiClient.patchJson(
      '/cart?type=${type.apiValue}',
      body,
      bearerToken: _token,
    );
    final data = response.data;
    if (data != null) return cartSnapshotFromJson(data, type);
    return fetchCart(type);
  }

  /// GET /cart/pickup-slots
  Future<PickupSlotsSnapshot> fetchPickupSlots() async {
    if (!_storage.hasSession) {
      return const PickupSlotsSnapshot(slots: [], selectedId: 'asap');
    }
    final response = await _apiClient.getJson(
      '/cart/pickup-slots',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return const PickupSlotsSnapshot(slots: [], selectedId: 'asap');
    }
    final slots = <PickupTimeSlot>[];
    final rawSlots = data['slots'];
    if (rawSlots is List) {
      for (final raw in rawSlots) {
        if (raw is! Map<String, dynamic>) continue;
        final id = raw['id']?.toString();
        if (id == null) continue;
        slots.add(
          PickupTimeSlot(
            id: id,
            label: raw['label']?.toString() ?? id,
            scheduledAt: DateTime.tryParse(
              raw['scheduledAt']?.toString() ?? '',
            )?.toLocal(),
            isAsap: raw['isAsap'] == true || id == 'asap',
          ),
        );
      }
    }
    return PickupSlotsSnapshot(
      slots: slots,
      selectedId: data['selectedId']?.toString() ?? 'asap',
      readyInMin: (data['readyInMin'] as num?)?.toInt() ?? 15,
      readyLabel: data['readyLabel']?.toString(),
    );
  }

  /// GET /cart/dine-in-slots
  Future<DineInSlotsSnapshot> fetchDineInSlots() async {
    if (!_storage.hasSession) {
      return const DineInSlotsSnapshot(slots: [], selectedId: '');
    }
    final response = await _apiClient.getJson(
      '/cart/dine-in-slots',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return const DineInSlotsSnapshot(slots: [], selectedId: '');
    }
    final slots = <DineInTimeSlot>[];
    final rawSlots = data['slots'];
    if (rawSlots is List) {
      for (final raw in rawSlots) {
        if (raw is! Map<String, dynamic>) continue;
        final id = raw['id']?.toString();
        final iso = raw['scheduledAt']?.toString() ?? '';
        final at = DateTime.tryParse(iso);
        if (id == null || at == null) continue;
        slots.add(
          DineInTimeSlot(
            id: id,
            label: raw['label']?.toString() ?? id,
            scheduledAt: at.toUtc(),
            scheduledAtIso: iso,
          ),
        );
      }
    }
    return DineInSlotsSnapshot(
      slots: slots,
      selectedId:
          data['selectedId']?.toString() ??
          (slots.isEmpty ? '' : slots.first.id),
      readyInMin: (data['readyInMin'] as num?)?.toInt() ?? 60,
      readyLabel: data['readyLabel']?.toString(),
    );
  }

  /// PATCH /cart/scheduled/items/:id (electronics scheduled basket)
  Future<CartSnapshot?> updateScheduledItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) return removeScheduledItem(itemId);
    final response = await _apiClient.patchJson(
      '/cart/scheduled/items/$itemId',
      {'quantity': quantity},
      bearerToken: _token,
    );
    final data = response.data;
    if (data != null) return scheduledCartSnapshotFromJson(data);
    return fetchScheduledCart();
  }

  /// DELETE /cart/scheduled/items/:id
  Future<CartSnapshot?> removeScheduledItem(String itemId) async {
    final response = await _apiClient.deleteJson(
      '/cart/scheduled/items/$itemId',
      bearerToken: _token,
    );
    final data = response.data;
    if (data != null) return scheduledCartSnapshotFromJson(data);
    return fetchScheduledCart();
  }

  /// POST /cart/scheduled/items
  Future<CartSnapshot?> addScheduledProduct({
    required String productId,
    int quantity = 1,
    bool replaceCart = false,
  }) async {
    final response = await _apiClient.postJson('/cart/scheduled/items', {
      'productId': productId,
      'quantity': quantity,
      'replaceCart': replaceCart,
    }, bearerToken: _token);
    if (!response.ok) {
      final error = response.json?['error'];
      final details = error is Map ? error['details'] : null;
      final detailCode = details is Map ? details['code']?.toString() : null;
      final code = error is Map ? error['code']?.toString() : null;
      if (response.statusCode == 409 ||
          detailCode == 'SCHEDULED_VENDOR_LIMIT' ||
          code == 'SCHEDULED_VENDOR_LIMIT' ||
          (response.message ?? '').toLowerCase().contains('up to 3 vendors')) {
        throw ScheduledVendorLimitException(
          response.message ?? 'Scheduled cart supports up to 3 vendors',
        );
      }
      throw Exception(response.message ?? 'Could not add to cart');
    }
    final data = response.data;
    if (data != null) return scheduledCartSnapshotFromJson(data);
    return fetchScheduledCart();
  }

  /// POST /cart/scheduled/promo
  Future<CartSnapshot?> applyScheduledPromo(String code) async {
    final response = await _apiClient.postJson('/cart/scheduled/promo', {
      'promoCode': code.trim(),
    }, bearerToken: _token);
    final data = response.data;
    if (data != null) return scheduledCartSnapshotFromJson(data);
    return fetchScheduledCart();
  }

  Future<CartSnapshot> applyPromo({
    required CartOrderType type,
    required String code,
  }) async {
    final response = await _apiClient.postJson(
      '/cart/promo?type=${type.apiValue}',
      {'promoCode': code.trim()},
      bearerToken: _token,
    );
    final data = response.data;
    if (data != null) return cartSnapshotFromJson(data, type);
    return fetchCart(type);
  }

  /// POST /cart/checkout — returns order payload on success.
  Future<Map<String, dynamic>?> checkout({
    required CartOrderType type,
    required String paymentMethod,
    double tipAmount = 0,
    String? addressId,
    double? walletAmount,
    double? referralCreditAmount,
    String? voucherId,
    List<String>? dropOffPreferences,
    bool saveDropOffPreferences = false,
    String? fulfillmentType,
    String? deliverySpeed,
    DateTime? scheduledAt,
    DateTime? windowStartAt,
    DateTime? windowEndAt,
    int? serviceDurationMin,
    String? serviceFulfillmentMode,
    String? serviceCategoryName,
    String? serviceStaffId,
    int? servicePeopleCount,
  }) async {
    final response = await _apiClient
        .postJson('/cart/checkout?type=${type.apiValue}', {
          'orderType': type.apiValue,
          'paymentMethod': paymentMethod,
          'tipAmount': tipAmount,
          if (addressId != null) 'addressId': addressId,
          if (walletAmount != null) 'walletAmount': walletAmount,
          if (referralCreditAmount != null)
            'referralCreditAmount': referralCreditAmount,
          if (voucherId != null && voucherId.isNotEmpty) 'voucherId': voucherId,
          if (dropOffPreferences != null && dropOffPreferences.isNotEmpty)
            'dropOffPreferences': dropOffPreferences,
          'saveDropOffPreferences': saveDropOffPreferences,
          if (fulfillmentType != null) 'fulfillmentType': fulfillmentType,
          if (deliverySpeed != null) 'deliverySpeed': deliverySpeed,
          if (scheduledAt != null)
            'scheduledAt': scheduledAt.toUtc().toIso8601String(),
          if (windowStartAt != null)
            'windowStartAt': windowStartAt.toUtc().toIso8601String(),
          if (windowEndAt != null)
            'windowEndAt': windowEndAt.toUtc().toIso8601String(),
          if (serviceDurationMin != null)
            'serviceDurationMin': serviceDurationMin,
          if (serviceFulfillmentMode != null)
            'serviceFulfillmentMode': serviceFulfillmentMode,
          if (serviceCategoryName != null)
            'serviceCategoryName': serviceCategoryName,
          if (serviceStaffId != null && serviceStaffId.isNotEmpty)
            'serviceStaffId': serviceStaffId,
          if (servicePeopleCount != null)
            'servicePeopleCount': servicePeopleCount,
        }, bearerToken: _token);
    if (!response.ok) {
      final instant = instantDeliveryUnavailableFrom(response);
      if (instant != null) throw instant;
      if (isOutOfDeliveryRangeCode(response.errorCode) ||
          isOutOfDeliveryRangeMessage(response.message)) {
        throw OutOfDeliveryRangeException(
          response.message ??
              'This address is outside the vendor delivery area',
        );
      }
      final code = response.errorCode;
      if (code == 'VOUCHER_WALLET_EXCLUSIVE' ||
          code == 'VOUCHER_EXPIRED_IN_CART') {
        throw CheckoutVoucherException(
          code: code!,
          message:
              response.message ??
              (code == 'VOUCHER_WALLET_EXCLUSIVE'
                  ? 'Wallet balance cannot be used with a voucher'
                  : 'Voucher expired — totals updated'),
        );
      }
      final message = response.message ?? '';
      if (_isCashCheckoutRejection(message, code)) {
        throw CheckoutCashUnavailableException(
          message.isNotEmpty ? message : 'Cash on delivery is not available',
        );
      }
      throw Exception(response.message ?? 'Checkout failed');
    }
    return response.data;
  }

  /// POST /cart/scheduled/checkout
  Future<Map<String, dynamic>?> checkoutScheduled({
    required String addressId,
    required String paymentMethod,
    required DateTime windowStartAt,
    DateTime? windowEndAt,
    String? deliverySpeed,
    List<String>? dropOffPreferences,
    String? note,
    List<String>? vendorIds,
    double tipAmount = 0,
    String? voucherId,
  }) async {
    final response = await _apiClient.postJson('/cart/scheduled/checkout', {
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      'windowStartAt': windowStartAt.toUtc().toIso8601String(),
      'tipAmount': tipAmount,
      if (windowEndAt != null)
        'windowEndAt': windowEndAt.toUtc().toIso8601String(),
      if (deliverySpeed != null) 'deliverySpeed': deliverySpeed,
      if (dropOffPreferences != null && dropOffPreferences.isNotEmpty)
        'dropOffPreferences': dropOffPreferences,
      if (note != null) 'note': note,
      if (vendorIds != null && vendorIds.isNotEmpty) 'vendorIds': vendorIds,
      if (voucherId != null && voucherId.isNotEmpty) 'voucherId': voucherId,
    }, bearerToken: _token);
    if (!response.ok) {
      if (isOutOfDeliveryRangeCode(response.errorCode) ||
          isOutOfDeliveryRangeMessage(response.message)) {
        throw OutOfDeliveryRangeException(
          response.message ??
              'This address is outside the vendor delivery area',
        );
      }
      final code = response.errorCode;
      if (code == 'VOUCHER_WALLET_EXCLUSIVE' ||
          code == 'VOUCHER_EXPIRED_IN_CART') {
        throw CheckoutVoucherException(
          code: code!,
          message:
              response.message ??
              (code == 'VOUCHER_WALLET_EXCLUSIVE'
                  ? 'Wallet balance cannot be used with a voucher'
                  : 'Voucher expired — totals updated'),
        );
      }
      final highValueMessage = highValueCheckoutMessage(response.errorCode);
      throw Exception(
        highValueMessage ?? response.message ?? 'Checkout failed',
      );
    }
    return response.data;
  }
}

/// Customer copy when scheduled checkout fails with a high-value server code.
/// Other errors stay unchanged. This does not decide who may buy the item.
String? highValueCheckoutMessage(String? code) {
  if (code == null || code.isEmpty) return null;
  if (code == 'HIGH_VALUE' ||
      code.startsWith('HIGH_VALUE_') ||
      code == 'SECURE_DELIVERY_REQUIRED') {
    return 'This high-value item couldn’t be checked out. Please try again.';
  }
  return null;
}

String? productImageUrlFromJson(Map<String, dynamic>? productMap) {
  if (productMap == null) return null;
  final direct = productMap['imageUrl'];
  if (direct is String && direct.trim().isNotEmpty) return direct.trim();
  final image = productMap['image'];
  if (image is String && image.trim().isNotEmpty) return image.trim();
  final images = productMap['images'];
  if (images is List) {
    for (final entry in images) {
      if (entry is String && entry.trim().isNotEmpty) return entry.trim();
      if (entry is Map<String, dynamic>) {
        final url = entry['url'] ?? entry['imageUrl'];
        if (url is String && url.trim().isNotEmpty) return url.trim();
      }
    }
  }
  return null;
}

class _CartLineOptions {
  const _CartLineOptions({
    required this.optionLabels,
    required this.sides,
    this.variantId,
    this.variantLabel,
  });

  final List<String> optionLabels;
  final List<CartSideLine> sides;
  final String? variantId;
  final String? variantLabel;

  bool get isVariant =>
      (variantId != null && variantId!.isNotEmpty) ||
      (variantLabel != null && variantLabel!.isNotEmpty);

  /// `M / Navy` plus addon names. Used as the cart subtitle so carts that
  /// only render [CartLineItem.subtitle] still show the SKU.
  String get variantSubtitle {
    final parts = <String>[];
    final label = variantLabel?.trim();
    if (label != null && label.isNotEmpty) parts.add(label);
    for (final side in sides) {
      if (side.name.isNotEmpty) parts.add(side.name);
    }
    return parts.join(' · ');
  }
}

_CartLineOptions _readCartLineOptions(Map<String, dynamic> raw) {
  final options = raw['options'];
  final optionLabels = <String>[];
  if (options is List) {
    for (final option in options) {
      if (option is Map) {
        final name = option['name']?.toString() ?? option['label']?.toString();
        if (name != null && name.isNotEmpty) optionLabels.add(name);
      } else if (option is String && option.isNotEmpty) {
        optionLabels.add(option);
      }
    }
  } else if (options is Map) {
    final labels = options['labels'];
    if (labels is List) {
      for (final label in labels) {
        final text = label?.toString();
        if (text != null && text.isNotEmpty) optionLabels.add(text);
      }
    }
  }

  final sides = <CartSideLine>[];
  if (options is Map) {
    final addons = options['addons'];
    if (addons is List) {
      for (final addon in addons) {
        if (addon is! Map) continue;
        final name = addon['name']?.toString();
        if (name == null || name.isEmpty) continue;
        final qty = (addon['quantity'] as num?)?.toInt() ?? 1;
        final unitAddon = addon['price'] is num
            ? (addon['price'] as num).toDouble()
            : double.tryParse(addon['price']?.toString() ?? '') ?? 0;
        sides.add(
          CartSideLine(
            name: name,
            quantity: qty,
            priceLabel: _money(unitAddon * qty),
          ),
        );
      }
    }
  }

  final variantMap = raw['variant'];
  final optionsMap = options is Map ? options : null;
  final variantId =
      _nonEmpty(raw['variantId']) ??
      _nonEmpty(optionsMap?['variantId']) ??
      (variantMap is Map ? _nonEmpty(variantMap['id']) : null);
  final variantLabel =
      _nonEmpty(optionsMap?['variantLabel']) ??
      (variantMap is Map ? _nonEmpty(variantMap['label']) : null);

  return _CartLineOptions(
    optionLabels: optionLabels,
    sides: sides,
    variantId: variantId,
    variantLabel: variantLabel,
  );
}

String? _nonEmpty(Object? raw) {
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) return null;
  return value;
}

String _bhd(num value) => 'BHD ${value.toStringAsFixed(3)}';

List<Map<String, dynamic>> _deliveryOptionsFromJson(dynamic raw) {
  final options = <Map<String, dynamic>>[];
  if (raw is! List) return options;
  for (final item in raw) {
    if (item is Map<String, dynamic>) {
      options.add(item);
    } else if (item is Map) {
      options.add(Map<String, dynamic>.from(item));
    }
  }
  return options;
}

String _money(dynamic raw) {
  if (raw is num) return _bhd(raw);
  final parsed = double.tryParse(raw?.toString() ?? '');
  return parsed == null ? 'BHD 0.000' : _bhd(parsed);
}

/// Minutes added by a selected option when the product exposes a duration change.
///
/// Recognized keys: `durationDelta`, `prepTimeDelta`, `durationChangeMin`.
/// Price deltas are ignored. Food option payloads without those keys add 0.
int optionDurationDeltaMinutes(Object? options, Object? product) {
  final ids = <String>{};
  if (options is Map) {
    final list = options['optionIds'];
    if (list is List) {
      for (final id in list) {
        final value = id?.toString();
        if (value != null && value.isNotEmpty) ids.add(value);
      }
    }
  }

  int deltaOf(Map opt) {
    for (final key in const [
      'durationDelta',
      'prepTimeDelta',
      'durationChangeMin',
    ]) {
      final raw = opt[key];
      if (raw is num) return raw.toInt();
    }
    return 0;
  }

  if (product is Map && ids.isNotEmpty) {
    final groups = product['optionGroups'];
    if (groups is List) {
      var extra = 0;
      var matched = false;
      for (final group in groups) {
        if (group is! Map) continue;
        final opts = group['options'];
        if (opts is! List) continue;
        for (final opt in opts) {
          if (opt is! Map) continue;
          final id = opt['id']?.toString();
          if (id == null || !ids.contains(id)) continue;
          matched = true;
          extra += deltaOf(opt);
        }
      }
      if (matched) return extra;
    }
  }

  if (options is! Map) return 0;
  var extra = 0;
  for (final key in const ['selected', 'selectedOptions']) {
    final selected = options[key];
    if (selected is! List) continue;
    for (final item in selected) {
      if (item is Map) extra += deltaOf(item);
    }
  }
  return extra;
}

/// Per-visit label plus line total (prep + option duration changes) × quantity.
({int? minutes, String? label}) serviceLineDuration(
  Map<String, dynamic> raw,
  Map<String, dynamic>? productMap,
  int qty,
) {
  final prep = (productMap?['prepTimeMin'] as num?)?.toInt();
  final delta = optionDurationDeltaMinutes(raw['options'], productMap);
  final perVisit = (prep ?? 0) + delta;
  if (perVisit <= 0) return (minutes: null, label: null);
  final count = qty > 0 ? qty : 1;
  return (minutes: perVisit * count, label: '$perVisit min');
}

/// Slot and checkout duration. Null when no line has a real duration.
int? serviceCartDurationMin(Iterable<CartLineItem> items) {
  var total = 0;
  var known = false;
  for (final item in items) {
    final minutes = item.durationMinutes;
    if (minutes == null || minutes <= 0) continue;
    known = true;
    total += minutes;
  }
  return known && total > 0 ? total : null;
}

/// Service checkout fields. `addressId` is included only for AT_HOME.
Map<String, Object> serviceCheckoutExtras({
  required String serviceFulfillmentMode,
  DateTime? scheduledAt,
  String? addressId,
  String? serviceStaffId,
  int? serviceDurationMin,
}) {
  final mode = serviceFulfillmentMode.trim().isEmpty
      ? 'IN_SALON'
      : serviceFulfillmentMode.trim();
  final staff = serviceStaffId?.trim();
  return {
    'orderType': CartOrderType.service.apiValue,
    'serviceFulfillmentMode': mode,
    if (scheduledAt != null)
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    if (mode == 'AT_HOME' && addressId != null && addressId.trim().isNotEmpty)
      'addressId': addressId.trim(),
    if (staff != null && staff.isNotEmpty) 'serviceStaffId': staff,
    if (serviceDurationMin != null && serviceDurationMin > 0)
      'serviceDurationMin': serviceDurationMin,
  };
}

CartSnapshot cartSnapshotFromJson(
  Map<String, dynamic> json,
  CartOrderType type,
) {
  final vendor = json['vendor'];
  final vendorName = vendor is Map<String, dynamic>
      ? (vendor['name'] as String? ?? '')
      : '';
  final vendorId = vendor is Map<String, dynamic>
      ? vendor['id']?.toString()
      : json['vendorId']?.toString();

  final itemsRaw = json['items'];
  final items = <CartLineItem>[];
  if (itemsRaw is List) {
    for (final raw in itemsRaw) {
      if (raw is! Map<String, dynamic>) continue;
      final product = raw['product'];
      final productMap = product is Map<String, dynamic> ? product : null;
      final name = productMap?['name'] as String? ?? 'Item';
      final parsed = _readCartLineOptions(raw);
      final specs = productMap?['specs'] as String?;
      final desc = productMap?['description'] as String?;
      final sides = parsed.sides;
      // Variant lines show the server label (and addon names). Food lines keep
      // option labels, or the description when addons are already side rows.
      final subtitle = parsed.isVariant
          ? parsed.variantSubtitle
          : sides.isNotEmpty
          ? (specs?.trim().isNotEmpty == true
                ? specs!.trim()
                : (desc?.trim() ?? ''))
          : (parsed.optionLabels.isNotEmpty
                ? parsed.optionLabels.join(' · ')
                : (specs?.trim().isNotEmpty == true
                      ? specs!.trim()
                      : (desc?.trim() ?? '')));
      final unit = raw['unitPrice'] ?? productMap?['price'] ?? 0;
      final compare = productMap?['compareAtPrice'];
      // Food shows the product price on the main row and addon prices beside
      // it. A variant line uses the server unit price as-is (variant + addons).
      final basePrice = productMap?['price'] ?? unit;
      final displayPrice = parsed.isVariant
          ? unit
          : (sides.isNotEmpty ? basePrice : unit);
      final displayNum = displayPrice is num
          ? displayPrice.toDouble()
          : double.tryParse(displayPrice?.toString() ?? '') ?? 0;
      final qty = (raw['quantity'] as num?)?.toInt() ?? 1;
      // Pickup Figma rows show line totals (qty × unit), e.g. 2× cookie → BHD 1.600.
      final priceForLabel = type == CartOrderType.pickup
          ? displayNum * qty
          : displayNum;
      final compareNum = compare is num
          ? compare.toDouble()
          : double.tryParse(compare?.toString() ?? '');
      final showCompare =
          compareNum != null && compareNum > displayNum + 0.0001;
      final duration = serviceLineDuration(raw, productMap, qty);
      items.add(
        CartLineItem(
          id: raw['id']?.toString() ?? '',
          productId:
              raw['productId']?.toString() ??
              productMap?['id']?.toString() ??
              '',
          name: name,
          subtitle: subtitle,
          quantity: qty,
          unitPriceLabel: _money(priceForLabel),
          compareAtPriceLabel: showCompare ? _money(compare) : null,
          imageUrl:
              productImageUrlFromJson(productMap) ??
              (raw['imageUrl'] as String?),
          sides: parsed.isVariant ? const [] : sides,
          durationLabel: duration.label,
          durationMinutes: duration.minutes,
          variantId: parsed.variantId,
          variantLabel: parsed.variantLabel,
        ),
      );
    }
  }

  final summary = json['summary'];
  final summaryMap = summary is Map<String, dynamic> ? summary : null;
  final delivery = json.containsKey('delivery')
      ? DeliveryQuote.tryParse(json['delivery'])
      : null;
  final billLines = _billLinesFromSummary(summaryMap, type, delivery: delivery);
  final cashback = summaryMap?['cashbackEarn'];
  final total = summaryMap?['totalAmount'];
  final cashbackPreview =
      CashbackPreview.tryParse(summaryMap?['cashbackPreview']) ??
      CashbackPreview.tryParse(json['cashbackPreview']);
  final cashbackLabel = cashbackPreview != null && cashbackPreview.hasMessage
      ? cashbackPreview.amountLabel
      : cashback == null
      ? '+ BHD 0.000'
      : '+ ${_money(cashback)}';

  final upsellRaw = json['upsell'];
  final upsellMap = upsellRaw is Map<String, dynamic> ? upsellRaw : null;
  final upsellTitle =
      upsellMap?['title'] as String? ??
      (type == CartOrderType.pickup
          ? 'You might also like'
          : 'Make it a combo');
  final upsellItems = <CartUpsellItem>[];
  final upsellList = upsellMap?['items'];
  if (upsellList is List) {
    var i = 0;
    for (final raw in upsellList) {
      if (raw is! Map<String, dynamic>) continue;
      final name = raw['name'] as String? ?? 'Item';
      final prepMin = (raw['prepTimeMin'] as num?)?.toInt();
      upsellItems.add(
        CartUpsellItem(
          productId: raw['id']?.toString() ?? '',
          name: name,
          priceLabel: _money(raw['price']),
          imageColor: type == CartOrderType.dineIn
              ? _dineInUpsellColor(i++)
              : _upsellColor(i++),
          durationLabel: prepMin != null ? '$prepMin min' : null,
          imageUrl: raw['imageUrl'] as String?,
        ),
      );
    }
  }

  CartPickupInfo? pickup;
  final pickupRaw = json['pickup'];
  if (pickupRaw is Map<String, dynamic>) {
    final branch = pickupRaw['branch'];
    final branchMap = branch is Map<String, dynamic> ? branch : null;
    final label =
        branchMap?['label'] as String? ??
        [vendorName, branchMap?['area']].whereType<String>().join(' · ');
    // Prefer full address string from API (may already include distance).
    final rawAddress = (branchMap?['address'] as String?)?.trim();
    final address = (rawAddress != null && rawAddress.isNotEmpty)
        ? rawAddress
        : [
            branchMap?['area'],
            branchMap?['city'],
          ].whereType<String>().where((e) => e.isNotEmpty).join(' · ');
    pickup = CartPickupInfo(
      title: 'Pickup from ${vendorName.isEmpty ? 'store' : vendorName}',
      address: address.isEmpty ? (label.isEmpty ? 'Nearby' : label) : address,
      readyLabel: _pickupReadyLabel(pickupRaw, json),
      mapUrl: branchMap?['mapUrl'] as String?,
      latitude: (branchMap?['latitude'] as num?)?.toDouble(),
      longitude: (branchMap?['longitude'] as num?)?.toDouble(),
      noShowPolicy: pickupRaw['noShowPolicy'] as String?,
      vendorLabel: label.isEmpty ? null : label,
      scheduledAt: DateTime.tryParse(
        pickupRaw['scheduledAt']?.toString() ?? '',
      )?.toLocal(),
    );
  }

  final itemCount =
      (json['itemCount'] as num?)?.toInt() ??
      items.fold<int>(0, (s, i) => s + i.quantity);
  final totalNum = total is num
      ? total.toDouble()
      : double.tryParse(total?.toString() ?? '') ?? 0;
  final vatAmount = _readMoney(summaryMap?['vatAmount']);
  final grandTotal = _readMoney(summaryMap?['grandTotal']);

  final displayItems = mergeEquivalentCartLines(items, type);

  return CartSnapshot(
    orderType: type,
    vendorName: vendorName,
    vendorId: vendorId,
    items: displayItems,
    billLines: billLines,
    upsell: upsellItems,
    upsellTitle: upsellTitle,
    includeCutlery: json['includeCutlery'] == true,
    kitchenNote: json['kitchenNote'] as String?,
    partySize: (json['partySize'] as num?)?.toInt(),
    seatingPreference: json['seatingPreference']?.toString(),
    specialOccasion: json['specialOccasion'] as String?,
    pickup: pickup,
    totalLabel: _money(grandTotal ?? totalNum),
    cashbackLabel: cashbackLabel,
    cashbackPreview: cashbackPreview,
    itemCount: itemCount,
    upsellSubtitle: upsellMap?['subtitle'] as String?,
    serviceMode: json['serviceMode']?.toString(),
    serviceScheduledAt: DateTime.tryParse(
      json['serviceScheduledAt']?.toString() ?? '',
    )?.toLocal(),
    serviceVenueAddress: _serviceVenueAddressFromJson(json['service']),
    promoCode: json['promoCode'] as String?,
    isVape:
        json['isVape'] == true ||
        (vendor is Map<String, dynamic> &&
            ((vendor['storeType'] as Map?)?['slug']?.toString().toLowerCase() ??
                    '')
                .contains('vape')),
    totalAmount: totalNum,
    vatAmount: vatAmount,
    grandTotal: grandTotal,
    storeTypeSlug: vendor is Map<String, dynamic>
        ? ((vendor['storeType'] as Map?)?['slug']?.toString())
        : null,
    dineInPrepMode: json['dineInPrepMode']?.toString(),
    scheduledDineInAt: DateTime.tryParse(
      json['scheduledDineInAt']?.toString() ?? '',
    )?.toLocal(),
    deliveryEta: _deliveryEtaFromJson(json['deliveryEta']),
    dineIn: _dineInInfoFromJson(json['dineIn']),
    pricingModel: json['pricingModel']?.toString(),
    delivery: delivery,
    cartId: json['id']?.toString() ?? json['cartId']?.toString(),
    referralCredit: CartReferralCredit.tryParse(summaryMap),
    payment: CartPaymentEligibility.tryParse(json['payment']),
  );
}

CartDeliveryEta? _deliveryEtaFromJson(dynamic raw) {
  if (raw is! Map) return null;
  final min = (raw['etaMin'] as num?)?.toInt();
  final max = (raw['etaMax'] as num?)?.toInt() ?? min;
  final label = raw['etaLabel']?.toString();
  if (min == null || label == null || label.isEmpty) return null;
  return CartDeliveryEta(etaMin: min, etaMax: max ?? min, etaLabel: label);
}

CartDineInInfo? _dineInInfoFromJson(dynamic raw) {
  if (raw is! Map) return null;
  final readyInMin = (raw['readyInMin'] as num?)?.toInt() ?? 60;
  final readyLabel = raw['readyLabel']?.toString();
  final seatingRaw = raw['seating'];
  final seatingMap = seatingRaw is Map ? seatingRaw : null;
  final seatingOptions = <DineInSeatingOption>[];
  final optionRows = seatingMap?['options'];
  if (optionRows is List) {
    for (final row in optionRows) {
      if (row is! Map) continue;
      final preference = row['seatingPreference']?.toString();
      if (preference == null || preference.isEmpty) continue;
      seatingOptions.add(
        DineInSeatingOption(
          preference: preference,
          available: row['available'] != false,
        ),
      );
    }
  }
  final occasionRaw = raw['specialOccasion'];
  final occasionMap = occasionRaw is Map ? occasionRaw : null;
  final packages = <DineInOccasionPackage>[];
  final packageRows = occasionMap?['packages'];
  if (packageRows is List) {
    for (final row in packageRows) {
      if (row is! Map) continue;
      final id = row['id']?.toString();
      final name = row['name']?.toString();
      if (id == null || id.isEmpty || name == null || name.isEmpty) continue;
      packages.add(
        DineInOccasionPackage(
          id: id,
          name: name,
          price: (row['price'] as num?)?.toDouble() ?? 0,
        ),
      );
    }
  }
  return CartDineInInfo(
    readyInMin: readyInMin,
    readyLabel: (readyLabel != null && readyLabel.isNotEmpty)
        ? readyLabel
        : (readyInMin >= 60
              ? 'in ~${(readyInMin / 60).round()} hour'
              : 'in ~$readyInMin min'),
    prepMode: raw['prepMode']?.toString(),
    scheduledAt: DateTime.tryParse(
      raw['scheduledAt']?.toString() ?? '',
    )?.toLocal(),
    seatingMode: seatingMap?['mode']?.toString(),
    allowAny: seatingMap?['allowAny'] == true,
    seatingOptions: seatingOptions,
    occasionEnabled: occasionMap?['enabled'] == true && packages.isNotEmpty,
    occasionPackages: packages,
    selectedPackageId: raw['selectedSpecialOccasionPackageId']?.toString(),
  );
}

CartSnapshot? scheduledCartSnapshotFromJson(Map<String, dynamic> json) {
  final groups = json['groups'] ?? json['vendors'];
  if (groups is! List || groups.isEmpty) return null;

  final items = <CartLineItem>[];
  String vendorName = '';
  String? vendorId;
  for (final group in groups) {
    if (group is! Map<String, dynamic>) continue;
    final vendor = group['vendor'];
    if (vendor is Map<String, dynamic> && vendorName.isEmpty) {
      vendorName = vendor['name'] as String? ?? '';
      vendorId = vendor['id']?.toString() ?? group['vendorId']?.toString();
    }
    final groupItems = group['items'];
    if (groupItems is! List) continue;
    for (final raw in groupItems) {
      if (raw is! Map<String, dynamic>) continue;
      final product = raw['product'];
      final productMap = product is Map<String, dynamic> ? product : null;
      final parsed = _readCartLineOptions(raw);
      final fallbackSubtitle =
          raw['description'] as String? ??
          productMap?['specs'] as String? ??
          productMap?['description'] as String? ??
          '';
      items.add(
        CartLineItem(
          id: raw['id']?.toString() ?? '',
          productId:
              raw['productId']?.toString() ??
              productMap?['id']?.toString() ??
              '',
          name:
              raw['name'] as String? ??
              productMap?['name'] as String? ??
              'Item',
          subtitle: parsed.isVariant
              ? parsed.variantSubtitle
              : fallbackSubtitle,
          quantity: (raw['quantity'] as num?)?.toInt() ?? 1,
          unitPriceLabel: _money(raw['unitPrice'] ?? productMap?['price']),
          compareAtPriceLabel: productMap?['compareAtPrice'] == null
              ? null
              : _money(productMap?['compareAtPrice']),
          imageUrl:
              (raw['imageUrl'] as String?)?.trim().isNotEmpty == true
                  ? (raw['imageUrl'] as String).trim()
                  : productImageUrlFromJson(productMap),
          variantId: parsed.variantId,
          variantLabel: parsed.variantLabel,
        ),
      );
    }
  }
  if (items.isEmpty) return null;

  final displayItems = mergeEquivalentCartLines(items, CartOrderType.delivery);

  final upsellRaw = json['upsell'];
  final upsellMap = upsellRaw is Map<String, dynamic> ? upsellRaw : null;
  final upsellItems = <CartUpsellItem>[];
  final upsellList = upsellMap?['items'];
  if (upsellList is List) {
    var i = 0;
    for (final raw in upsellList) {
      if (raw is! Map<String, dynamic>) continue;
      upsellItems.add(
        CartUpsellItem(
          productId: raw['id']?.toString() ?? '',
          name: raw['name'] as String? ?? 'Item',
          priceLabel: _money(raw['price']),
          imageColor: _upsellColor(i++),
          imageUrl: raw['imageUrl'] as String?,
        ),
      );
    }
  }

  final summary = json['summary'];
  final summaryMap = summary is Map<String, dynamic> ? summary : null;
  final delivery = json.containsKey('delivery')
      ? DeliveryQuote.tryParse(json['delivery'])
      : null;
  final counted = (json['itemCount'] as num?)?.toInt();
  final itemCount =
      counted ?? displayItems.fold<int>(0, (sum, item) => sum + item.quantity);
  final scheduledTotalRaw =
      summaryMap?['totalAmount'] ?? summaryMap?['grandTotal'] ?? 0;
  final scheduledTotal = scheduledTotalRaw is num
      ? scheduledTotalRaw.toDouble()
      : double.tryParse(scheduledTotalRaw.toString()) ?? 0;
  final vatAmount = _readMoney(summaryMap?['vatAmount']);
  final grandTotal = _readMoney(summaryMap?['grandTotal']);
  final cashback = (summaryMap?['cashbackEarn'] as num?)?.toDouble();
  final cashbackPreview =
      CashbackPreview.tryParse(summaryMap?['cashbackPreview']) ??
      CashbackPreview.tryParse(json['cashbackPreview']);
  final cashbackLabel = cashbackPreview != null
      ? cashbackPreview.amountLabel
      : cashback == null
      ? '+ BHD 0.000'
      : '+ ${_money(cashback)}';

  return CartSnapshot(
    orderType: CartOrderType.delivery,
    vendorName: vendorName.isEmpty ? 'Scheduled cart' : vendorName,
    vendorId: vendorId,
    items: displayItems,
    billLines: _electronicsBillLines(summaryMap, delivery: delivery),
    pricingModel: json['pricingModel']?.toString(),
    delivery: delivery,
    upsell: upsellItems,
    upsellTitle: upsellMap?['title'] as String? ?? 'Add more … ?',
    includeCutlery: false,
    totalLabel: _money(grandTotal ?? scheduledTotal),
    cashbackLabel: cashbackLabel,
    cashbackPreview: cashbackPreview,
    itemCount: itemCount,
    promoCode:
        json['promoCode'] as String? ??
        (summaryMap?['appliedPromotion'] is Map
            ? (summaryMap!['appliedPromotion'] as Map)['name']?.toString()
            : null),
    totalAmount: scheduledTotal,
    vatAmount: vatAmount,
    grandTotal: grandTotal,
    cartId: json['id']?.toString() ?? json['cartId']?.toString(),
    referralCredit: CartReferralCredit.tryParse(summaryMap),
    payment: CartPaymentEligibility.tryParse(json['payment']),
  );
}

bool _isCashCheckoutRejection(String message, String? code) {
  final lower = message.toLowerCase();
  if (code != null &&
      (code == 'CASH_NOT_AVAILABLE' ||
          code == 'CASH_ON_DELIVERY_UNAVAILABLE')) {
    return true;
  }
  return lower.contains('not accepting cash') ||
      lower.contains('cash on delivery is only available');
}

List<BillLine> _electronicsBillLines(
  Map<String, dynamic>? summary, {
  DeliveryQuote? delivery,
}) {
  if (summary == null) return const [];
  final lines = <BillLine>[
    BillLine(label: 'Subtotal', value: _money(summary['subtotal'] ?? 0)),
  ];
  final discount = (summary['discountAmount'] as num?)?.toDouble() ?? 0;
  if (discount > 0) {
    lines.add(
      BillLine(
        label: 'Discount',
        value: '- ${_money(discount)}',
        isDiscount: true,
      ),
    );
  }
  _appendFeeLines(lines, summary, CartOrderType.delivery, delivery);
  _appendServerTaxLines(lines, summary, totalLabel: 'Total');
  return lines;
}

void _appendFeeLines(
  List<BillLine> lines,
  Map<String, dynamic> summary,
  CartOrderType type,
  DeliveryQuote? delivery,
) {
  if (delivery != null) {
    lines.add(BillLine(label: 'Delivery fee', value: delivery.feeLabel));
  }
  if (type != CartOrderType.dineIn) {
    final serviceFee = _readMoney(summary['serviceFee']) ?? 0;
    if (serviceFee > 0) {
      lines.add(BillLine(label: 'Service fee', value: _money(serviceFee)));
    }
  }
}

List<BillLine> _billLinesFromSummary(
  Map<String, dynamic>? summary,
  CartOrderType type, {
  DeliveryQuote? delivery,
}) {
  if (summary == null) return const [];
  final lines = <BillLine>[];
  lines.add(
    BillLine(
      label: 'Subtotal',
      value: _money(summary['itemsSubtotal'] ?? summary['subtotal'] ?? 0),
    ),
  );
  final occasionAmount =
      (summary['specialOccasionAmount'] as num?)?.toDouble() ?? 0;
  if (occasionAmount > 0) {
    final pkg = summary['specialOccasionPackage'];
    final name = pkg is Map ? pkg['name']?.toString() : null;
    lines.add(
      BillLine(
        label: (name != null && name.isNotEmpty) ? name : 'Special occasion',
        value: _money(occasionAmount),
      ),
    );
  }
  final discount = (summary['discountAmount'] as num?)?.toDouble() ?? 0;
  if (discount > 0) {
    lines.add(
      BillLine(
        label: 'Discount',
        value: '- ${_money(discount)}',
        isDiscount: true,
      ),
    );
  }
  _appendFeeLines(lines, summary, type, delivery);
  _appendServerTaxLines(lines, summary, totalLabel: 'Order total');
  return lines;
}

void _appendServerTaxLines(
  List<BillLine> lines,
  Map<String, dynamic> summary, {
  required String totalLabel,
}) {
  final vat = _readMoney(summary['vatAmount']);
  if (vat != null && vat > 0) {
    lines.add(BillLine(label: 'VAT', value: _money(vat)));
  }
  final grand = _readMoney(summary['grandTotal']);
  final preVat = _readMoney(summary['totalAmount']) ?? 0;
  lines.add(
    BillLine(
      label: totalLabel,
      value: _money(grand ?? preVat),
      isBold: true,
    ),
  );
}

double? _readMoney(dynamic raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '');
}

Color _upsellColor(int index) {
  const colors = [
    Color(0xFF6B4A2A),
    Color(0xFF8A5B2A),
    Color(0xFF9A6B3A),
    Color(0xFF4A6B5A),
    Color(0xFF5A4A6B),
  ];
  return colors[index % colors.length];
}

/// Matches dine-in basket combo card greens from design.
Color _dineInUpsellColor(int index) {
  const colors = [
    Color(0xFF6B8A3A),
    Color(0xFF9A6B2A),
    Color(0xFF3A6B48),
    Color(0xFF5A7A3A),
    Color(0xFF2F6B4A),
  ];
  return colors[index % colors.length];
}

String _formatReadyInMinutes(int minutes) {
  final rounded = minutes < 1 ? 1 : minutes;
  return 'Ready in $rounded ${rounded == 1 ? 'minute' : 'minutes'}';
}

/// Longest item prep time. Pickup ready time is this, not a chosen clock slot.
int? _maxCartItemPrepMin(Map<String, dynamic> json) {
  final items = json['items'];
  if (items is! List) return null;
  var max = 0;
  for (final raw in items) {
    if (raw is! Map) continue;
    final product = raw['product'];
    if (product is! Map) continue;
    final prep = product['prepTimeMin'];
    if (prep is num && prep > max) max = prep.toInt();
  }
  return max > 0 ? max : null;
}

String? _serviceVenueAddressFromJson(Object? raw) {
  if (raw is! Map<String, dynamic>) return null;
  final branch = raw['branch'];
  if (branch is! Map<String, dynamic>) return null;
  final address = (branch['address'] as String?)?.trim();
  if (address != null && address.isNotEmpty) return address;
  final parts = [
    branch['area'],
    branch['city'],
  ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);
  final joined = parts.join(' · ');
  return joined.isEmpty ? null : joined;
}

String _pickupReadyLabel(
  Map<String, dynamic> pickupRaw,
  Map<String, dynamic> json,
) {
  final fromItems = _maxCartItemPrepMin(json);
  if (fromItems != null) return _formatReadyInMinutes(fromItems);
  final ready = pickupRaw['readyLabel'] as String?;
  if (ready != null && ready.isNotEmpty) return ready;
  final eta = json['deliveryEta'];
  if (eta is Map && eta['etaLabel'] is String) {
    return eta['etaLabel'] as String;
  }
  return 'Ready soon';
}
