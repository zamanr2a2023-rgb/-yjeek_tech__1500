import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';

String formatBhd(dynamic value) {
  if (value is num) return 'BHD ${value.toStringAsFixed(3)}';
  if (value == null) return 'BHD 0.000';
  final parsed = num.tryParse(value.toString());
  if (parsed != null) return 'BHD ${parsed.toStringAsFixed(3)}';
  return 'BHD ${value.toString()}';
}

String formatPaymentMethod(String? raw) {
  if (raw == null || raw.isEmpty) return OrderFlowData.paymentMethod;
  return switch (raw.toUpperCase()) {
    'YJEEK_WALLET' || 'WALLET' => 'Yjeek Wallet',
    'CASH_ON_DELIVERY' || 'COD' || 'CASH' => 'Cash on delivery',
    'CARD' || 'CREDIT_CARD' || 'DEBIT_CARD' => 'Card',
    'APPLE_PAY' => 'Apple Pay',
    'BENEFIT' || 'BENEFITPAY' => 'BenefitPay',
    _ => raw.replaceAll('_', ' '),
  };
}

String formatStatusLabel(String? raw) {
  if (raw == null || raw.isEmpty) return OrderFlowStrings.preparingOrder;
  return raw
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

String formatOrderDate(dynamic value) {
  final dt = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (dt == null) return OrderFlowData.orderDate;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final tod =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  return '${dt.day} ${months[dt.month - 1]} ${dt.year} · $tod';
}

String formatClock(dynamic value) {
  final dt = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (dt == null) return '--';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String formatOrderType(String? orderType) {
  return switch ((orderType ?? '').toUpperCase()) {
    'PICKUP' => 'Pickup',
    'DINE_IN' => 'Dine-in',
    'SERVICE' => 'Service',
    _ => OrderFlowStrings.typeDelivery,
  };
}

String driverDisplayName(Map<String, dynamic>? driver) {
  if (driver == null) return '';
  return [
    driver['firstName'],
    driver['lastName'],
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
}

String champMetaFromTrack(Map<String, dynamic>? champ) {
  if (champ == null) return '___';
  final rating = champ['rating'];
  final ratingStr =
      rating is num && rating > 0 ? rating.toStringAsFixed(1) : null;
  final vehicle = champ['vehicle'];
  String? vehicleLabel;
  String? plate;
  if (vehicle is Map<String, dynamic>) {
    vehicleLabel = vehicle['vehicleType'] as String? ??
        vehicle['type'] as String? ??
        vehicle['model'] as String? ??
        vehicle['make'] as String?;
    plate = vehicle['plateNumber'] as String? ?? vehicle['plate'] as String?;
  }
  final parts = <String>[
    if (ratingStr != null) '★ $ratingStr',
    if (vehicleLabel != null && vehicleLabel.isNotEmpty) vehicleLabel,
    if (plate != null && plate.isNotEmpty) plate,
    if (champ['isIdVerified'] == true) 'ID-verified',
  ];
  return parts.isNotEmpty ? parts.join(' · ') : '___';
}

String displayOrDash(String? value) {
  if (value == null) return '___';
  final trimmed = value.trim();
  return trimmed.isEmpty ? '___' : trimmed;
}

/// Canonical delivery timeline filled from API `timeline` / statusHistory.
List<OrderTimelineStep> timelineFromTrack({
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
        'CONFIRMED',
      },
      'Order confirmed',
    ),
    ({'VENDOR_ACCEPTED'}, 'Vendor accepted'),
    (
      {
        'PREPARING',
        'SEARCHING_DRIVER',
        'AWAITING_DRIVER_CONFIRM',
        'DRIVER_ASSIGNED',
        'ARRIVED_AT_PICKUP',
        'READY_FOR_PICKUP',
        'READY_FOR_YOU',
        'READY',
      },
      'Preparing',
    ),
    ({'PICKED_UP'}, 'Picked up'),
    (
      {
        'IN_TRANSIT',
        'ON_THE_WAY',
        'ARRIVED_AT_CUSTOMER',
      },
      'On the way',
    ),
    (
      {
        'DELIVERED',
        'COLLECTED',
        'COMPLETED',
      },
      'Delivered',
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
  // If status not in canonical list, mark all history-matched steps done.
  if (currentIndex < 0 && history.isNotEmpty) {
    for (var i = 0; i < steps.length; i++) {
      if (steps[i].$1.any(history.containsKey)) currentIndex = i;
    }
  }

  return [
    for (var i = 0; i < steps.length; i++)
      OrderTimelineStep(
        label: steps[i].$2,
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

List<OrderReceiptItem> receiptItemsFromApi(List<dynamic>? items) {
  if (items == null || items.isEmpty) return OrderFlowData.receiptItems;
  final out = <OrderReceiptItem>[];
  for (final raw in items) {
    if (raw is! Map) continue;
    final qty = (raw['quantity'] as num?)?.toInt() ?? 1;
    final name = raw['name'] as String? ?? 'Item';
    final lineTotal = raw['lineTotal'];
    final unitPrice = raw['unitPrice'];
    final priceValue = lineTotal is num
        ? lineTotal.toDouble()
        : unitPrice is num
            ? unitPrice.toDouble() * qty
            : 0.0;
    out.add(
      OrderReceiptItem(
        name: qty > 1 ? '$qty× $name' : '1× $name',
        price: formatBhd(priceValue),
      ),
    );
  }
  return out.isNotEmpty ? out : OrderFlowData.receiptItems;
}

List<BillLine> receiptBillFromTotals(Map<String, dynamic>? totals) {
  if (totals == null) return OrderFlowData.receiptBillLines;
  final delivery = totals['deliveryFee'];
  final deliveryLabel = totals['deliveryLabel'] as String?;
  final deliveryValue = delivery is num && delivery == 0
      ? 'Free'
      : formatBhd(delivery);

  return [
    BillLine(label: 'Subtotal', value: formatBhd(totals['subtotal'])),
    if ((totals['discountAmount'] as num?) != null &&
        (totals['discountAmount'] as num) > 0)
      BillLine(
        label: 'Discount',
        value: '− ${formatBhd(totals['discountAmount'])}',
        isDiscount: true,
      ),
    if ((totals['pickupDiscountAmount'] as num?) != null &&
        (totals['pickupDiscountAmount'] as num) > 0)
      BillLine(
        label: totals['pickupDiscountLabel'] as String? ?? 'Pickup discount',
        value: '− ${formatBhd(totals['pickupDiscountAmount'])}',
        isDiscount: true,
      ),
    BillLine(
      label: deliveryLabel ?? 'Delivery',
      value: deliveryValue,
    ),
    BillLine(label: 'Service fee', value: formatBhd(totals['serviceFee'])),
    if ((totals['vatAmount'] as num?) != null &&
        (totals['vatAmount'] as num) > 0)
      BillLine(label: 'VAT', value: formatBhd(totals['vatAmount'])),
    if ((totals['tipAmount'] as num?) != null &&
        (totals['tipAmount'] as num) > 0)
      BillLine(label: 'Tip', value: formatBhd(totals['tipAmount'])),
    BillLine(
      label: 'Total',
      value: formatBhd(totals['totalAmount']),
      isBold: true,
    ),
  ];
}
