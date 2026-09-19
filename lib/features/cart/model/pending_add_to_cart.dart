import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';

/// Add-to-cart that failed because the delivery address was out of range.
/// Retried after the user picks an in-range address via "Deliver here".
class PendingAddToCart {
  const PendingAddToCart({
    required this.productId,
    this.quantity = 1,
    this.optionIds = const [],
    this.addonIds = const [],
    this.cartType = 'DELIVERY',
    this.vendorId,
    this.geofenceTriggerId,
    this.replaceCart = false,
  });

  final String productId;
  final int quantity;
  final List<String> optionIds;
  final List<String> addonIds;
  final String cartType;
  final String? vendorId;
  final String? geofenceTriggerId;
  final bool replaceCart;

  bool get isPickup => cartType.toUpperCase() == 'PICKUP';
}

final pendingAddToCartProvider = StateProvider<PendingAddToCart?>((ref) => null);

void rememberPendingAddToCart(WidgetRef ref, PendingAddToCart pending) {
  ref.read(pendingAddToCartProvider.notifier).state = pending;
}

void clearPendingAddToCart(WidgetRef ref) {
  ref.read(pendingAddToCartProvider.notifier).state = null;
}

/// Retries a stored add after the user saved an in-range address.
Future<({bool ok, bool outOfRange, String? message})> retryPendingAddToCart(
  WidgetRef ref,
) async {
  final pending = ref.read(pendingAddToCartProvider);
  if (pending == null) {
    return (ok: false, outOfRange: false, message: null);
  }

  final result = await ref.read(foodVendorsRepositoryProvider).addToCart(
        productId: pending.productId,
        quantity: pending.quantity,
        optionIds: pending.optionIds,
        addonIds: pending.addonIds,
        replaceCart: pending.replaceCart,
        cartType: pending.cartType,
        vendorId: pending.vendorId,
        geofenceTriggerId: pending.geofenceTriggerId,
      );

  if (result.ok) {
    clearPendingAddToCart(ref);
  }

  return (
    ok: result.ok,
    outOfRange: result.outOfRange,
    message: result.message,
  );
}
