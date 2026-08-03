import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';

String servicesServiceNameFromOrder(Map<String, dynamic>? order) {
  if (order == null) return ServicesOrderFlowData.serviceName;
  final booking = order['serviceBooking'];
  if (booking is Map) {
    final category = booking['categoryName']?.toString();
    if (category != null && category.isNotEmpty) return category;
  }
  final items = order['items'];
  if (items is List && items.isNotEmpty) {
    final first = items.first;
    if (first is Map) {
      final name = first['name']?.toString();
      if (name != null && name.isNotEmpty) {
        if (items.length > 1) return '$name +${items.length - 1}';
        return name;
      }
    }
  }
  return ServicesOrderFlowData.serviceName;
}

String servicesWhenFromOrder(Map<String, dynamic>? order, {bool short = false}) {
  if (order == null) {
    return short
        ? ServicesOrderFlowData.appointmentWhenShort
        : ServicesOrderFlowData.appointmentWhen;
  }
  final label = order['serviceTimeLabel']?.toString();
  if (label != null && label.isNotEmpty) {
    if (!short) return label;
    // "Wed, 14 Jun, 01:00 PM" → keep weekday + day + time roughly
    return label.replaceAll(',', '');
  }
  final raw = order['scheduledAt']?.toString();
  final at = DateTime.tryParse(raw ?? '')?.toLocal();
  if (at == null) {
    return short
        ? ServicesOrderFlowData.appointmentWhenShort
        : ServicesOrderFlowData.appointmentWhen;
  }
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final wd = weekdays[at.weekday - 1];
  final mon = months[at.month - 1];
  final h = at.hour;
  final m = at.minute.toString().padLeft(2, '0');
  final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  final ampm = h >= 12 ? 'PM' : 'AM';
  if (short) return '$wd ${at.day} · $hour12:$m $ampm';
  return '$wd ${at.day} $mon · $hour12:$m $ampm';
}

String servicesLocationFromOrder(Map<String, dynamic>? order) {
  if (order == null) return ServicesOrderFlowData.locationLabel;
  final booking = order['serviceBooking'];
  final mode = booking is Map
      ? booking['fulfillmentMode']?.toString()
      : order['serviceMode']?.toString();
  if (mode == 'AT_HOME') return 'At home';
  final loc = order['vendorLocation'] ?? order['venue'];
  final area = loc is Map
      ? (loc['area']?.toString() ?? loc['name']?.toString())
      : null;
  final vendor = order['vendor'];
  final vendorArea = vendor is Map ? vendor['area']?.toString() : null;
  final place = (area != null && area.isNotEmpty) ? area : vendorArea;
  if (place != null && place.isNotEmpty) return 'At venue · $place';
  return 'At venue';
}

int? servicesPeopleCount(Map<String, dynamic>? order) {
  if (order == null) return null;
  final booking = order['serviceBooking'];
  if (booking is Map) {
    final n = booking['peopleCount'];
    if (n is num) return n.toInt();
  }
  final n = order['partySize'] ?? order['servicePeopleCount'];
  if (n is num) return n.toInt();
  return null;
}

List<BillLine> servicesReceiptBillFromTotals(Map<String, dynamic>? totals) {
  if (totals == null) return const [];
  return [
    BillLine(label: 'Service', value: formatBhd(totals['subtotal'])),
    BillLine(label: 'Service fee', value: formatBhd(totals['serviceFee'] ?? 0)),
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
        label: 'Specialist tip',
        value: formatBhd(totals['staffTipAmount']),
      ),
    BillLine(
      label: 'Total',
      value: formatBhd(totals['totalAmount']),
      isBold: true,
    ),
  ];
}

/// Services timeline: Requested → Confirmed → In progress → Completed.
List<ServicesOrderTimelineStep> servicesTimelineFromTrack({
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
        'VENDOR_ACCEPTED',
      },
      'Requested',
    ),
    (
      {'CONFIRMED', 'VENDOR_ACCEPTED', 'AUTHORIZED'},
      'Confirmed',
    ),
    (
      {'IN_PROGRESS', 'PREPARING', 'READY_FOR_YOU', 'READY'},
      'In progress',
    ),
    (
      {'COMPLETED', 'COLLECTED', 'DELIVERED'},
      'Completed',
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
  if (current == 'CONFIRMED' && currentIndex < 1) currentIndex = 1;
  if (const {'IN_PROGRESS', 'PREPARING'}.contains(current)) {
    currentIndex = 2;
  }
  if (const {'COMPLETED', 'COLLECTED'}.contains(current)) {
    currentIndex = 3;
  }

  return [
    for (var i = 0; i < steps.length; i++)
      ServicesOrderTimelineStep(
        label: steps[i].$2,
        time: () {
          for (final key in steps[i].$1) {
            final t = history[key];
            if (t != null) return t;
          }
          return null;
        }(),
        completed: currentIndex >= 0 && i <= currentIndex,
      ),
  ];
}
