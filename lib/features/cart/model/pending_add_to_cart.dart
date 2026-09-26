import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';

/// Which cart API to use when retrying a pending add.
enum PendingCartVertical {
  food,
  dineIn,
  electronics,
  vape,
  services,
}

/// Add-to-cart deferred until the user logs in or picks an in-range address.
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
    this.returnPath,
    this.vertical = PendingCartVertical.food,
  });

  final String productId;
  final int quantity;
  final List<String> optionIds;
  final List<String> addonIds;
  final String cartType;
  final String? vendorId;
  final String? geofenceTriggerId;
  final bool replaceCart;

  /// GoRouter location to restore after login (e.g. product or menu page).
  final String? returnPath;

  final PendingCartVertical vertical;

  bool get isPickup => cartType.toUpperCase() == 'PICKUP';
}

final pendingAddToCartProvider = StateProvider<PendingAddToCart?>((ref) => null);

/// Standalone return path when login was required without a full pending payload.
final postLoginReturnPathProvider = StateProvider<String?>((ref) => null);

void rememberPendingAddToCart(WidgetRef ref, PendingAddToCart pending) {
  ref.read(pendingAddToCartProvider.notifier).state = pending;
  final path = pending.returnPath?.trim();
  if (path != null && path.isNotEmpty) {
    ref.read(postLoginReturnPathProvider.notifier).state = path;
  }
}

void clearPendingAddToCart(WidgetRef ref) {
  ref.read(pendingAddToCartProvider.notifier).state = null;
}

void clearPostLoginReturnPath(WidgetRef ref) {
  ref.read(postLoginReturnPathProvider.notifier).state = null;
}

/// Retries a stored add after login or after the user saved an in-range address.
Future<({bool ok, bool outOfRange, bool vendorConflict, String? message})>
    retryPendingAddToCart(WidgetRef ref) async {
  final pending = ref.read(pendingAddToCartProvider);
  if (pending == null) {
    return (
      ok: false,
      outOfRange: false,
      vendorConflict: false,
      message: null,
    );
  }

  switch (pending.vertical) {
    case PendingCartVertical.food:
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
        _markCartUpdated(ref, pending);
      }
      return (
        ok: result.ok,
        outOfRange: result.outOfRange,
        vendorConflict: result.vendorConflict,
        message: result.message,
      );

    case PendingCartVertical.dineIn:
      final result = await ref.read(dineInVendorsRepositoryProvider).addToCart(
            productId: pending.productId,
            quantity: pending.quantity,
            optionIds: pending.optionIds,
            addonIds: pending.addonIds,
            replaceCart: pending.replaceCart,
          );
      if (result.ok) {
        clearPendingAddToCart(ref);
        _markCartUpdated(ref, pending);
      }
      return (
        ok: result.ok,
        outOfRange: false,
        vendorConflict: result.vendorConflict,
        message: result.message,
      );

    case PendingCartVertical.electronics:
      final result =
          await ref.read(electronicsVendorsRepositoryProvider).addToCart(
                productId: pending.productId,
                quantity: pending.quantity,
                optionIds: pending.optionIds,
                addonIds: pending.addonIds,
                replaceCart: pending.replaceCart,
              );
      if (result.ok) {
        clearPendingAddToCart(ref);
        _markCartUpdated(ref, pending);
      }
      return (
        ok: result.ok,
        outOfRange: false,
        vendorConflict: result.vendorConflict,
        message: result.message,
      );

    case PendingCartVertical.vape:
      final result = await ref.read(vapeVendorsRepositoryProvider).addToCart(
            productId: pending.productId,
            quantity: pending.quantity,
            optionIds: pending.optionIds,
            addonIds: pending.addonIds,
            replaceCart: pending.replaceCart,
            vendorId: pending.vendorId,
            geofenceTriggerId: pending.geofenceTriggerId,
          );
      if (result.ok) {
        clearPendingAddToCart(ref);
        _markCartUpdated(ref, pending);
      }
      return (
        ok: result.ok,
        outOfRange: result.outOfRange,
        vendorConflict: result.vendorConflict,
        message: result.message,
      );

    case PendingCartVertical.services:
      final result =
          await ref.read(servicesVendorsRepositoryProvider).addToCart(
                productId: pending.productId,
                quantity: pending.quantity,
                optionIds: pending.optionIds,
                addonIds: pending.addonIds,
                replaceCart: pending.replaceCart,
              );
      if (result.ok) {
        clearPendingAddToCart(ref);
        _markCartUpdated(ref, pending);
      }
      return (
        ok: result.ok,
        outOfRange: false,
        vendorConflict: result.vendorConflict,
        message: result.message,
      );
  }
}

void _markCartUpdated(WidgetRef ref, PendingAddToCart pending) {
  final type = pending.cartType.toUpperCase();
  switch (pending.vertical) {
    case PendingCartVertical.food:
      ref.read(shellProvider.notifier).markCartUpdated(
            delivery: type == 'DELIVERY',
            pickup: type == 'PICKUP',
            dineIn: type == 'DINE_IN',
          );
    case PendingCartVertical.dineIn:
      ref.read(shellProvider.notifier).markCartUpdated(dineIn: true);
    case PendingCartVertical.electronics:
      ref.read(shellProvider.notifier).markCartUpdated(scheduled: true);
    case PendingCartVertical.vape:
      ref.read(shellProvider.notifier).markCartUpdated(vape: true);
    case PendingCartVertical.services:
      // Services booking cart is separate from the shell tab badges.
      break;
  }
}
