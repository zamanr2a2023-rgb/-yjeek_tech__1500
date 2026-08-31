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
  if (raw == null || raw.isEmpty) return '—';
  return switch (raw.toUpperCase()) {
    'YJEEK_WALLET' || 'WALLET' => 'Yjeek Wallet',
    'CASH_ON_DELIVERY' || 'COD' || 'CASH' => 'Cash on delivery',
    'CARD' || 'CREDIT_CARD' || 'DEBIT_CARD' => 'Card',
    'APPLE_PAY' => 'Apple Pay',
    'GOOGLE_PAY' => 'Google Pay',
    'BENEFIT_PAY' || 'BENEFITPAY' => 'BenefitPay',
    'BENEFIT' => 'Benefit',
    _ => raw.replaceAll('_', ' '),
  };
}

String formatStatusLabel(String? raw) {
  if (raw == null || raw.isEmpty) return OrderFlowStrings.preparingOrder;
  final key = raw.toUpperCase();
  // Figma track badge copy for active kitchen / delivery stages.
  return switch (key) {
    'PLACED' ||
    'PENDING_VENDOR_ACCEPT' ||
    'PENDING_CONFIRMATION' ||
    'AWAITING_PAYMENT' =>
      'Sent to vendor',
    'CONFIRMED' || 'VENDOR_ACCEPTED' => 'Vendor accepted',
    'PREPARING' ||
    'SEARCHING_DRIVER' ||
    'AWAITING_DRIVER_CONFIRM' ||
    'DRIVER_ASSIGNED' ||
    'ARRIVED_AT_PICKUP' ||
    'READY_FOR_PICKUP' ||
    'READY_FOR_YOU' ||
    'READY' =>
      OrderFlowStrings.preparingOrder,
    'PICKED_UP' => 'Picked up',
    'IN_TRANSIT' || 'ON_THE_WAY' => 'On the way',
    'ARRIVED_AT_CUSTOMER' => 'Champ has arrived',
    'DELIVERED' || 'COLLECTED' || 'COMPLETED' => 'Delivered',
    'CANCELLED' || 'REJECTED' => 'Cancelled',
    _ => raw
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' '),
  };
}

String formatOrderDate(dynamic value) {
  final dt = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (dt == null) return '—';
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
  final full = driver['name']?.toString().trim();
  if (full != null && full.isNotEmpty) return full;
  return [
    driver['firstName'],
    driver['lastName'],
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
}

/// Lat/lng from track payload: champ live location → delivery address → venue.
({double lat, double lng})? trackMapCoords(Map<String, dynamic> data) {
  double? asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  ({double lat, double lng})? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final lat = asDouble(raw['latitude'] ?? raw['lat']);
    final lng = asDouble(raw['longitude'] ?? raw['lng']);
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  return fromMap(data['champ']) ??
      fromMap(data['address']) ??
      fromMap(data['deliveryAddress']) ??
      fromMap(data['venue']);
}

/// Drop-off coords only (for live map destination pin).
({double lat, double lng})? trackDropoffCoords(Map<String, dynamic> data) {
  double? asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  ({double lat, double lng})? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final lat = asDouble(raw['latitude'] ?? raw['lat']);
    final lng = asDouble(raw['longitude'] ?? raw['lng']);
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  return fromMap(data['address']) ??
      fromMap(data['deliveryAddress']) ??
      fromMap(data['venue']);
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
  return parts.isNotEmpty ? parts.join(' · ') : '—';
}

String displayOrDash(String? value) {
  if (value == null) return '—';
  final trimmed = value.trim();
  return trimmed.isEmpty ? '—' : trimmed;
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
  if (items == null || items.isEmpty) return const [];
  final out = <OrderReceiptItem>[];
  for (final raw in items) {
    if (raw is! Map) continue;
    final qty = (raw['quantity'] as num?)?.toInt() ?? 1;
    final name = raw['name'] as String? ?? 'Item';
    final priceValue = linePriceFromApiItem(raw);
    out.add(
      OrderReceiptItem(
        name: qty > 1 ? '$qty× $name' : '1× $name',
        price: formatBhd(priceValue),
      ),
    );
  }
  return out;
}

/// Line price for an order item: prefers lineTotal, else unitPrice × qty.
double linePriceFromApiItem(Map raw) {
  final qty = (raw['quantity'] as num?)?.toInt() ?? 1;
  final lineTotal = raw['lineTotal'] ?? raw['totalPrice'] ?? raw['total'];
  if (lineTotal is num) return lineTotal.toDouble();
  if (lineTotal is String) {
    final parsed = num.tryParse(lineTotal);
    if (parsed != null) return parsed.toDouble();
  }
  final unitPrice = raw['unitPrice'] ?? raw['price'];
  if (unitPrice is num) return unitPrice.toDouble() * qty;
  if (unitPrice is String) {
    final parsed = num.tryParse(unitPrice);
    if (parsed != null) return parsed.toDouble() * qty;
  }
  return 0;
}

String? deliverToFromOrderApi(Map<String, dynamic> order) {
  final label = order['deliverToLabel']?.toString();
  if (label != null && label.trim().isNotEmpty) return label.trim();

  final address = order['deliveryAddress'] ?? order['address'];
  if (address is! Map) return null;

  final parts = <String>[
    if ((address['label']?.toString() ?? '').isNotEmpty)
      address['label'].toString(),
    if ((address['area']?.toString() ?? '').isNotEmpty)
      address['area'].toString(),
    if ((address['road']?.toString() ?? '').isNotEmpty)
      'Road ${address['road']}',
    if ((address['building']?.toString() ?? '').isNotEmpty)
      'Bldg ${address['building']}',
    if ((address['block']?.toString() ?? '').isNotEmpty)
      'Block ${address['block']}',
  ];
  if (parts.isNotEmpty) return parts.join(' · ');

  final formatted = address['formatted']?.toString() ??
      address['line1']?.toString() ??
      address['formattedLine']?.toString();
  if (formatted != null && formatted.trim().isNotEmpty) return formatted.trim();
  return null;
}

List<({String qty, String name, String price})> reviewLinesFromApi(
  List<dynamic>? items,
) {
  if (items == null || items.isEmpty) return const [];
  final out = <({String qty, String name, String price})>[];
  for (final raw in items) {
    if (raw is! Map) continue;
    final qty = (raw['quantity'] as num?)?.toInt() ?? 1;
    final name = raw['name']?.toString() ??
        raw['productName']?.toString() ??
        'Item';
    out.add((
      qty: '$qty×',
      name: name,
      price: formatBhd(linePriceFromApiItem(raw)),
    ));
  }
  return out;
}

List<BillLine> receiptBillFromTotals(Map<String, dynamic>? totals) {
  if (totals == null) return const [];
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

const _rateableStatuses = {'DELIVERED', 'COLLECTED', 'COMPLETED'};

/// Whether the customer can still submit a rating for this order.
bool orderCanRate(Map<String, dynamic> order) {
  if (order.containsKey('canRate')) return order['canRate'] == true;
  final status = order['status']?.toString().toUpperCase() ?? '';
  if (!_rateableStatuses.contains(status)) return false;
  return order['review'] == null;
}

/// Parsed review from GET /orders/:id (null when not yet rated).
SubmittedReview? submittedReviewFromOrder(Map<String, dynamic>? order) {
  if (order == null) return null;
  final review = order['review'];
  if (review is! Map) return null;
  final map = Map<String, dynamic>.from(review);
  int? rating(dynamic value) => value is num ? value.round().clamp(1, 5) : null;
  final comment = map['comment']?.toString();
  return SubmittedReview(
    orderRating: rating(map['orderRating']),
    driverRating: rating(map['driverRating']),
    foodRating: rating(map['foodRating']),
    experienceRating: rating(map['experienceRating']),
    comment: comment != null && comment.isNotEmpty ? comment : null,
  );
}

class SubmittedReview {
  const SubmittedReview({
    this.orderRating,
    this.driverRating,
    this.foodRating,
    this.experienceRating,
    this.comment,
  });

  final int? orderRating;
  final int? driverRating;
  final int? foodRating;
  final int? experienceRating;
  final String? comment;
}

/// Receipt badge from fulfillment status (matches orders list), not paymentStatus.
String? receiptBadgeLabel(Map<String, dynamic>? receipt) {
  if (receipt == null) return null;
  final status = receipt['status']?.toString();
  if (status != null && status.trim().isNotEmpty) {
    return formatStatusLabel(status).toUpperCase();
  }
  final badgeRaw = receipt['statusBadge']?.toString();
  if (badgeRaw == null || badgeRaw.isEmpty) return null;
  return badgeRaw.replaceAll('_', ' ').toUpperCase();
}
