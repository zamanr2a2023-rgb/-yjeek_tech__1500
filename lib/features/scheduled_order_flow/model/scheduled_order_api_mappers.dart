import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';
import 'package:yjeek_app/features/scheduled_order_flow/model/scheduled_order_flow_data.dart';

String scheduledDeliverySpeedLabel(String? speed) {
  final id = deliveryUiIdFromApi(speed);
  return ScheduledCartData.deliveryMethods
      .firstWhere(
        (m) => m.id == id,
        orElse: () => ScheduledCartData.deliveryMethods.first,
      )
      .label;
}

String scheduledDeliveryFeeLabel(String? speed) {
  return '${scheduledDeliverySpeedLabel(speed)} delivery';
}

String itemsSummaryFromOrderApi(Map<String, dynamic> order) {
  final items = order['items'];
  if (items is! List || items.isEmpty) {
    final count = (order['itemCount'] as num?)?.toInt();
    if (count == null) return '—';
    return '$count ${count == 1 ? 'item' : 'items'}';
  }
  final names = <String>[];
  var totalQty = 0;
  for (final raw in items) {
    if (raw is! Map) continue;
    final qty = (raw['quantity'] as num?)?.toInt() ?? 1;
    totalQty += qty;
    final name = raw['name']?.toString() ??
        raw['productName']?.toString() ??
        'Item';
    names.add(name);
  }
  if (names.isEmpty) return '—';
  if (names.length == 1 && totalQty == 1) return names.first;
  if (names.length == 1) return '${names.first} ×$totalQty';
  return '${names.first} + ${names.length - 1} more';
}

String deliveryWindowFromOrderApi(Map<String, dynamic> order) {
  final labeled = order['deliveryWindowLabel']?.toString();
  if (labeled != null && labeled.trim().isNotEmpty) return labeled.trim();

  final start = DateTime.tryParse(
        order['windowStartAt']?.toString() ??
            order['scheduledAt']?.toString() ??
            '',
      )
      ?.toLocal();
  if (start == null) {
    final eta = order['etaLabel']?.toString();
    if (eta != null && eta.trim().isNotEmpty) return eta.trim();
    return '—';
  }
  final end = DateTime.tryParse(order['windowEndAt']?.toString() ?? '')
          ?.toLocal() ??
      start.add(const Duration(hours: 2));

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startDay = DateTime(start.year, start.month, start.day);
  final dayDiff = startDay.difference(today).inDays;
  final dayLabel = switch (dayDiff) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ =>
      '${start.day} ${_monthShort(start.month)}',
  };
  return '$dayLabel · ${_clockAmPm(start)}–${_clockAmPm(end)}';
}

String packedBannerFromTrack(Map<String, dynamic> data) {
  final status = (data['status']?.toString() ?? '').toUpperCase();
  final window = deliveryWindowFromOrderApi(data);
  final speed = scheduledDeliverySpeedLabel(data['deliverySpeed']?.toString());

  if (status == 'DELIVERED' || status == 'COMPLETED' || status == 'COLLECTED') {
    return '✓ Delivered · $window';
  }
  if (status == 'PICKED_UP' ||
      status == 'IN_TRANSIT' ||
      status == 'ON_THE_WAY' ||
      status == 'ARRIVED_AT_CUSTOMER') {
    return '🚚 On the way · arrives $window';
  }
  if (status == 'PREPARING' ||
      status == 'SEARCHING_DRIVER' ||
      status == 'DRIVER_ASSIGNED' ||
      status == 'ARRIVED_AT_PICKUP' ||
      status == 'READY' ||
      status == 'READY_FOR_PICKUP') {
    return '📦 Packed · $speed · arrives $window';
  }
  return '📦 Confirmed · $speed · arrives $window';
}

List<ScheduledOrderTimelineStep> scheduledTimelineFromTrack({
  required List<dynamic>? timeline,
  required String? currentStatus,
}) {
  return timelineFromTrack(timeline: timeline, currentStatus: currentStatus)
      .map(
        (s) => ScheduledOrderTimelineStep(
          label: s.label,
          time: s.time,
          completed: s.completed,
        ),
      )
      .toList();
}

List<ScheduledReceiptLine> scheduledReceiptItemsFromApi(List<dynamic>? items) {
  return receiptItemsFromApi(items)
      .map((e) => ScheduledReceiptLine(name: e.name, price: e.price))
      .toList();
}

String _monthShort(int month) {
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
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}

String _clockAmPm(DateTime dt) {
  final h = dt.hour;
  final m = dt.minute.toString().padLeft(2, '0');
  final hour12 = h % 12 == 0 ? 12 : h % 12;
  final suffix = h >= 12 ? 'pm' : 'am';
  return m == '00' ? '$hour12$suffix' : '$hour12:$m$suffix';
}
