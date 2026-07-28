import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';

/// Dine-in receipt bill lines matching Figma (subtotal / discount / VAT / total).
List<BillLine> dineInReceiptBillFromTotals(Map<String, dynamic>? totals) {
  if (totals == null) return const [];
  return [
    BillLine(label: 'Subtotal', value: formatBhd(totals['subtotal'])),
    if ((totals['discountAmount'] as num?) != null &&
        (totals['discountAmount'] as num) > 0)
      BillLine(
        label: 'Discount',
        value: '− ${formatBhd(totals['discountAmount'])}',
        isDiscount: true,
      ),
    BillLine(
      label: 'VAT (10%)',
      value: formatBhd(totals['vatAmount'] ?? 0),
    ),
    if ((totals['staffTipAmount'] as num?) != null &&
        (totals['staffTipAmount'] as num) > 0)
      BillLine(
        label: 'Staff tip',
        value: formatBhd(totals['staffTipAmount']),
      ),
    BillLine(
      label: 'Total',
      value: formatBhd(totals['totalAmount']),
      isBold: true,
    ),
  ];
}

/// Dine-in status timeline from track `timeline` / statusHistory.
List<DineInOrderTimelineStep> dineInTimelineFromTrack({
  required List<dynamic>? timeline,
  required String? currentStatus,
}) {
  const steps = <(Set<String>, String, String?)>[
    (
      {
        'PLACED',
        'PENDING_VENDOR_ACCEPT',
        'AWAITING_PAYMENT',
        'PENDING_CONFIRMATION',
        'VENDOR_ACCEPTED',
        'CONFIRMED',
      },
      'Placed & paid',
      null,
    ),
    ({'VENDOR_ACCEPTED', 'CONFIRMED'}, 'Vendor confirmed', null),
    (
      {'PREPARING'},
      'Preparing',
      DineInOrderFlowStrings.kitchenOnIt,
    ),
    (
      {'READY_FOR_YOU', 'READY_FOR_PICKUP', 'READY'},
      'Ready for you',
      'We will notify you',
    ),
    ({'CUSTOMER_ARRIVED'}, 'You arrived', 'Show your order number'),
    (
      {'COMPLETED', 'COLLECTED', 'DELIVERED'},
      'Completed',
      DineInOrderFlowStrings.enjoyYourMeal,
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

  // Vendor confirmed step: treat CONFIRMED as completing first two.
  if (current == 'CONFIRMED' || current == 'PREPARING') {
    if (currentIndex < 1) currentIndex = 1;
  }
  if (current == 'PREPARING') currentIndex = 2;

  return [
    for (var i = 0; i < steps.length; i++)
      DineInOrderTimelineStep(
        label: steps[i].$2,
        subtitle: () {
          final base = steps[i].$3;
          if (base == null) return null;
          final past = currentIndex >= 0 && i < currentIndex;
          // Hide pending helper copy once the step is already done.
          if (past &&
              (base == 'We will notify you' ||
                  base == 'Show your order number')) {
            return null;
          }
          return base;
        }(),
        time: () {
          for (final key in steps[i].$1) {
            final t = history[key];
            if (t != null) return t;
          }
          return null;
        }(),
        completed: currentIndex >= 0 && i <= currentIndex,
        active: currentIndex >= 0 && i == currentIndex,
      ),
  ];
}
