import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/features/dine_in_cart/model/dine_in_cart_data.dart';

/// Food delivery — held until Review & confirm places the order.
class PendingCheckout {
  const PendingCheckout({
    required this.paymentId,
    required this.tipAmount,
    required this.addressId,
    this.dropOffIndex = 0,
    this.saveDropOff = false,
  });

  final String paymentId;
  final double tipAmount;
  final String addressId;
  final int dropOffIndex;
  final bool saveDropOff;
}

final pendingCheckoutProvider = StateProvider<PendingCheckout?>((ref) => null);

/// Services booking — held until Review & confirm places the booking.
class PendingServiceCheckout {
  const PendingServiceCheckout({
    required this.paymentId,
    required this.tipAmount,
    this.specialistId,
    this.specialistName,
  });

  final String paymentId;
  final double tipAmount;
  final String? specialistId;
  final String? specialistName;
}

final pendingServiceCheckoutProvider =
    StateProvider<PendingServiceCheckout?>((ref) => null);

/// Dine-in — held until Review & confirm places the order.
class PendingDineInCheckout {
  const PendingDineInCheckout({
    required this.paymentId,
    required this.prepMode,
  });

  final String paymentId;
  final DineInPrepMode prepMode;
}

final pendingDineInCheckoutProvider =
    StateProvider<PendingDineInCheckout?>((ref) => null);
