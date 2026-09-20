import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Security context when the customer starts an order from a Geofence Offer.
class ActiveGeofenceOrderContext {
  const ActiveGeofenceOrderContext({
    required this.geofenceTriggerId,
    required this.campaignId,
    required this.vendorId,
    required this.allowedOrderTypes,
    required this.expiresAt,
    this.discountBadge,
  });

  final String geofenceTriggerId;
  final String campaignId;
  final String vendorId;
  final List<String> allowedOrderTypes;
  final DateTime expiresAt;
  final String? discountBadge;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());

  bool matchesVendor(String? vendorId) {
    final id = vendorId?.trim() ?? '';
    return id.isNotEmpty && id == this.vendorId;
  }

  bool allowsOrderType(String orderType) {
    if (allowedOrderTypes.isEmpty) return true;
    final upper = orderType.toUpperCase();
    return allowedOrderTypes.any((t) => t.toUpperCase() == upper);
  }

  /// Modes allowed by both the campaign and the selected vendor.
  static List<String> intersectOrderTypes(
    List<String> campaignTypes,
    List<String> vendorTypes,
  ) {
    final vendor = vendorTypes.map((t) => t.toUpperCase()).toSet();
    if (campaignTypes.isEmpty) {
      return vendor.isEmpty ? const ['DELIVERY'] : vendor.toList();
    }
    if (vendor.isEmpty) {
      return campaignTypes.map((t) => t.toUpperCase()).toList();
    }
    final out = <String>[];
    for (final t in campaignTypes) {
      final upper = t.toUpperCase();
      if (vendor.contains(upper) && !out.contains(upper)) out.add(upper);
    }
    return out;
  }

  /// Prefer delivery when available — cart/items?type must match vendor support.
  String resolveCartType() {
    final modes = allowedOrderTypes.isEmpty
        ? const ['DELIVERY']
        : allowedOrderTypes;
    for (final preferred in ['DELIVERY', 'PICKUP', 'DINE_IN', 'SERVICE']) {
      if (modes.any((t) => t.toUpperCase() == preferred)) {
        return _toCartType(preferred);
      }
    }
    return _toCartType(modes.first);
  }

  static String _toCartType(String mode) {
    switch (mode.toUpperCase()) {
      case 'PICKUP':
        return 'pickup';
      case 'DINE_IN':
        return 'dine_in';
      case 'SERVICE':
        return 'service';
      case 'DELIVERY':
      default:
        return 'delivery';
    }
  }
}

final activeGeofenceOrderContextProvider =
    StateProvider<ActiveGeofenceOrderContext?>((ref) => null);

/// Returns trigger id only when vendor + order type still match an unexpired context.
String? resolveGeofenceTriggerId(
  WidgetRef ref, {
  required String? vendorId,
  required String orderType,
}) {
  final ctx = ref.read(activeGeofenceOrderContextProvider);
  if (ctx == null) return null;
  if (ctx.isExpired) {
    ref.read(activeGeofenceOrderContextProvider.notifier).state = null;
    return null;
  }
  if (!ctx.matchesVendor(vendorId)) return null;
  if (!ctx.allowsOrderType(orderType)) return null;
  return ctx.geofenceTriggerId;
}

void clearGeofenceOrderContext(WidgetRef ref) {
  ref.read(activeGeofenceOrderContextProvider.notifier).state = null;
}
