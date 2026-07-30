import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/pickup_order_flow/model/pickup_order_flow_data.dart';

/// Figma pickup status: placed → accepted → preparing → ready → collected.
List<PickupOrderTimelineStep> pickupTimelineFromTrack({
  required List<dynamic>? timeline,
  required String? currentStatus,
}) {
  const steps = <(Set<String>, String)>[
    (
      {
        'PLACED',
        'PENDING_VENDOR_ACCEPT',
        'AWAITING_PAYMENT',
        'PENDING_CONFIRMATION',
      },
      'Order placed',
    ),
    (
      {
        'VENDOR_ACCEPTED',
        'CONFIRMED',
      },
      'Vendor accepted',
    ),
    (
      {
        'PREPARING',
      },
      'Preparing',
    ),
    (
      {
        'READY_FOR_PICKUP',
        'READY_FOR_YOU',
        'READY',
        'CUSTOMER_ARRIVED',
      },
      'Ready for pickup',
    ),
    (
      {
        'COLLECTED',
        'COMPLETED',
      },
      'Collected',
    ),
  ];

  final history = <String, String>{};
  if (timeline != null) {
    for (final raw in timeline) {
      if (raw is! Map) continue;
      final status = (raw['status'] as String?)?.toUpperCase();
      if (status == null) continue;
      history.putIfAbsent(status, () => formatClock(raw['createdAt']));
    }
  }

  final current = (currentStatus ?? '').toUpperCase();
  var currentIndex = -1;
  for (var i = 0; i < steps.length; i++) {
    if (steps[i].$1.contains(current)) {
      currentIndex = i;
      break;
    }
  }
  if (currentIndex < 0 && history.isNotEmpty) {
    for (var i = 0; i < steps.length; i++) {
      if (steps[i].$1.any(history.containsKey)) currentIndex = i;
    }
  }

  // Paid / confirmed implies vendor accepted is done.
  if (current == 'CONFIRMED' || current == 'PREPARING') {
    if (currentIndex < 1) currentIndex = 1;
  }
  if (current == 'PREPARING') currentIndex = 2;

  return [
    for (var i = 0; i < steps.length; i++)
      PickupOrderTimelineStep(
        label: steps[i].$2,
        time: () {
          for (final key in steps[i].$1) {
            final t = history[key];
            if (t != null) return t;
          }
          return currentIndex >= 0 && i <= currentIndex ? null : '--';
        }(),
        completed: currentIndex >= 0 && i <= currentIndex,
      ),
  ];
}

String pickupDiscountLabelFromOrder(Map<String, dynamic> order) {
  final pctRaw = order['pickupDiscountPct'] ??
      (order['vendor'] is Map
          ? (order['vendor'] as Map)['pickupDiscountPct']
          : null);
  final pct = pctRaw is num
      ? pctRaw.toDouble()
      : double.tryParse(pctRaw?.toString() ?? '');
  if (pct != null && pct > 0) {
    final whole = pct == pct.roundToDouble()
        ? pct.toInt().toString()
        : pct.toStringAsFixed(0);
    return 'Pickup discount ($whole%)';
  }

  final amount = order['pickupDiscountAmount'];
  final subtotal = order['subtotal'];
  if (amount is num &&
      subtotal is num &&
      amount > 0 &&
      subtotal > 0) {
    final inferred = ((amount / subtotal) * 100).round();
    if (inferred > 0) return 'Pickup discount ($inferred%)';
  }
  return 'Pickup discount';
}

/// Pay / receipt bill: subtotal → pickup discount → service → total (no delivery).
List<BillLine> pickupBillFromOrderMoney(Map<String, dynamic>? money) {
  if (money == null) return const [];
  final pickupAmt = money['pickupDiscountAmount'];
  final discountAmt = money['discountAmount'];
  final pickupNum = pickupAmt is num ? pickupAmt.toDouble() : 0.0;
  final discountNum = discountAmt is num ? discountAmt.toDouble() : 0.0;
  final otherDiscount =
      discountNum > pickupNum ? discountNum - pickupNum : 0.0;

  return [
    BillLine(label: 'Subtotal', value: formatBhd(money['subtotal'])),
    if (pickupNum > 0)
      BillLine(
        label: money['pickupDiscountLabel'] as String? ??
            pickupDiscountLabelFromOrder(money),
        value: '− ${formatBhd(pickupNum)}',
        isDiscount: true,
      ),
    if (otherDiscount > 0.0005)
      BillLine(
        label: 'Discount',
        value: '− ${formatBhd(otherDiscount)}',
        isDiscount: true,
      ),
    BillLine(label: 'Service fee', value: formatBhd(money['serviceFee'])),
    BillLine(
      label: 'Total',
      value: formatBhd(money['totalAmount']),
      isBold: true,
    ),
  ];
}
