import 'package:intl/intl.dart';
import 'package:yjeek_app/features/cart/model/addresses_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/delivery_quote.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/checkout_pricing.dart';
import 'package:yjeek_app/features/cart/model/pending_checkout.dart';
import 'package:yjeek_app/features/geofence/model/active_geofence_order_context.dart';
import 'package:yjeek_app/features/geofence/service/geofence_session_controller.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/scheduled_cart/model/scheduled_cart_data.dart';

export 'package:yjeek_app/features/cart/model/checkout_pricing.dart';

/// UI delivery tier id (`same-day`, …) chosen on the cart for scheduled retail.
final scheduledDeliveryUiSpeedProvider = StateProvider<String>(
  (ref) => 'next-day',
);

/// Store types that may offer cash on delivery: on-demand hot food only.
const hotFoodOnDemandSlugs = {'food', 'cafe', 'restaurant', 'coffee'};

const _kVendorNotAcceptingCash =
    'This vendor is not accepting cash orders';
const _kCodOnDemandFoodOnly =
    'Cash on delivery is only available for on-demand hot food delivery';

bool _legacyAllowsCashOnDelivery(CartSnapshot cart) {
  if (cart.isVape || cart.orderType != CartOrderType.delivery) return false;
  final slug = cart.storeTypeSlug?.trim().toLowerCase() ?? '';
  return hotFoodOnDemandSlugs.contains(slug);
}

/// Prefer GET /cart `payment.cashOnDeliveryAvailable`; fallback for mocks.
bool allowsCashOnDelivery(CartSnapshot cart) {
  final payment = cart.payment;
  if (payment != null) return payment.cashOnDeliveryAvailable;
  return _legacyAllowsCashOnDelivery(cart);
}

/// User-facing note when COD is hidden (localized when server sends known copy).
String? localizedCodUnavailableReason(CartSnapshot cart) {
  if (allowsCashOnDelivery(cart)) return null;
  final raw = cart.payment?.cashOnDeliveryUnavailableReason;
  if (raw == null || raw.isEmpty) {
    if (cart.payment != null && !cart.payment!.acceptsCashOrders) {
      return L10n.tr(_kVendorNotAcceptingCash);
    }
    return null;
  }
  if (raw == _kVendorNotAcceptingCash) {
    return L10n.tr(_kVendorNotAcceptingCash);
  }
  if (raw == _kCodOnDemandFoodOnly) {
    return L10n.tr(_kCodOnDemandFoodOnly);
  }
  return raw;
}

/// Localize checkout 400 copy when CASH is rejected.
String localizeCodServerMessage(String message) {
  final trimmed = message.trim();
  if (trimmed.isEmpty) return L10n.tr(_kVendorNotAcceptingCash);
  if (trimmed == _kVendorNotAcceptingCash ||
      trimmed.toLowerCase().contains('not accepting cash')) {
    return L10n.tr(_kVendorNotAcceptingCash);
  }
  if (trimmed == _kCodOnDemandFoodOnly ||
      trimmed.toLowerCase().contains('only available for on-demand')) {
    return L10n.tr(_kCodOnDemandFoodOnly);
  }
  return trimmed;
}

/// Maps UI payment option ids → backend PaymentMethod enum values.
String paymentMethodApiValue(String paymentId) {
  return switch (paymentId) {
    'wallet' => 'YJEEK_WALLET',
    'benefitpay' => 'BENEFIT_PAY',
    'benefit' => 'BENEFIT',
    'apple' => 'APPLE_PAY',
    'google' => 'GOOGLE_PAY',
    'new-card' => 'CARD',
    'cod' => 'CASH',
    _ => paymentId.startsWith('saved-') ? 'CARD' : 'BENEFIT_PAY',
  };
}

String deliverySpeedApiValue(String deliveryId) {
  return switch (deliveryId) {
    'same-day' => 'SAME_DAY',
    'next-day' => 'NEXT_DAY',
    'standard' => 'STANDARD',
    'economy' => 'ECONOMY',
    _ => 'SAME_DAY',
  };
}

/// Drop-off chip index → API enum (order matches [CartFlowData.dropOffOptions]).
const List<String> kDropOffApiValues = [
  'CALL_ON_ARRIVAL',
  'DONT_RING_BELL',
  'LEAVE_AT_RECEPTION',
  'RING_DOORBELL',
  'DONT_CALL_ON_ARRIVAL',
  'RING_BELL',
  'MESSAGE_ON_ARRIVAL',
  'LEAVE_AT_DOOR',
];

/// Mutual-exclusion groups (indices into [kDropOffApiValues]).
/// Within a group only one preference may be selected at a time.
const List<Set<int>> kDropOffConflictGroups = [
  {0, 4, 6}, // Call / Don't call / Message on arrival
  {1, 3, 5}, // Don't ring / Ring doorbell / Ring bell
  {2, 7}, // Leave at reception / Leave at door
];

String? dropOffApiValue(int index) {
  if (index < 0 || index >= kDropOffApiValues.length) return null;
  return kDropOffApiValues[index];
}

List<String> dropOffApiValues(Iterable<int> indices) {
  final values = <String>[];
  for (final index in indices) {
    final value = dropOffApiValue(index);
    if (value != null) values.add(value);
  }
  return values;
}

/// Indices that conflict with [index] (same group, excluding itself).
Set<int> dropOffConflictPeers(int index) {
  for (final group in kDropOffConflictGroups) {
    if (group.contains(index)) {
      return {...group}..remove(index);
    }
  }
  return {};
}

bool dropOffConflicts(int a, int b) {
  if (a == b) return false;
  for (final group in kDropOffConflictGroups) {
    if (group.contains(a) && group.contains(b)) return true;
  }
  return false;
}

/// Toggle [tapped] into selection.
/// Options in the same [kDropOffConflictGroups] entry stay mutually exclusive;
/// options from different groups can be combined (e.g. Don't ring + Call on arrival).
Set<int> applyDropOffSelection(Set<int> current, int tapped) {
  final next = Set<int>.from(current);
  if (next.contains(tapped)) {
    next.remove(tapped);
    return next;
  }
  next.removeAll(dropOffConflictPeers(tapped));
  next.add(tapped);
  return next;
}

/// Map saved address drop-off prefs → chip indices (multi-select; conflicts resolved).
Set<int> dropOffIndicesFromPrefs(List<String>? prefs, {Set<int>? fallback}) {
  final defaults = fallback ?? {0};
  if (prefs == null || prefs.isEmpty) return Set<int>.from(defaults);

  var next = <int>{};
  for (final pref in prefs) {
    final i = kDropOffApiValues.indexOf(pref);
    if (i >= 0) next = applyDropOffSelection(next, i);
  }
  if (next.isEmpty) return Set<int>.from(defaults);
  return next;
}

/// Legacy single-index helper (first known pref wins).
int dropOffIndexFromPrefs(List<String>? prefs, {int fallback = 0}) {
  final set = dropOffIndicesFromPrefs(prefs, fallback: {fallback});
  if (set.isEmpty) return fallback;
  return set.first;
}

/// Parse delivery fee from cart bill lines (API summary).
double? deliveryFeeFromBillLines(List<BillLine> lines) {
  for (final line in lines) {
    final label = line.label.toLowerCase();
    if (!label.contains('delivery')) continue;
    if (label.contains('free')) return 0;
    final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(line.value);
    if (match != null) return double.tryParse(match.group(1)!);
  }
  return null;
}

double tipAmountFrom(
  List<TipOption> options,
  int index, {
  double customAmount = 0,
}) {
  if (index < 0 || index >= options.length) return 0;
  final fixed = options[index].amount;
  if (fixed != null) return fixed;
  if (!customAmount.isFinite || customAmount <= 0) return 0;
  // Backend checkout allows tipAmount max 50 BHD.
  if (customAmount > 50) return 50;
  return double.parse(customAmount.toStringAsFixed(3));
}

bool isCustomTipOption(TipOption option) => option.amount == null;

double? parseTipInput(String raw) {
  final cleaned = raw.trim().replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

/// Rebuilds the checkout bill from server VAT and grand total, then adds tip.
///
/// Existing VAT and bold total rows are replaced with [CartSnapshot.vatAmount]
/// and [CartSnapshot.grandTotal]. Nothing is multiplied by a tax rate.
List<BillLine> billLinesWithTip(
  CartSnapshot cart,
  double tipAmount, {
  String totalLabel = 'Order total',
}) {
  final lines = List<BillLine>.from(cart.billLines);
  lines.removeWhere((line) {
    if (line.isBold) return true;
    final label = line.label.toLowerCase();
    return label.contains('vat') || label == 'tip';
  });
  final vat = cart.vatAmount;
  if (vat != null && vat > 0) {
    lines.add(
      BillLine(label: 'VAT', value: 'BHD ${vat.toStringAsFixed(3)}'),
    );
  }
  if (tipAmount > 0) {
    lines.add(
      BillLine(
        label: 'Tip',
        value: 'BHD ${tipAmount.toStringAsFixed(3)}',
      ),
    );
  }
  final total = payableWithTip(cart.grandTotal ?? cart.totalAmount, tipAmount);
  lines.add(
    BillLine(
      label: totalLabel,
      value: 'BHD ${total.toStringAsFixed(3)}',
      isBold: true,
    ),
  );
  return lines;
}

String formatCheckoutTotal(CartSnapshot cart, double tipAmount) {
  final total = payableWithTip(cart.grandTotal ?? cart.totalAmount, tipAmount);
  return 'BHD ${total.toStringAsFixed(3)}';
}

/// Bahrain wall clock for dine-in slots (matches backend `Asia/Bahrain`).
DateTime _bahrainWallClock(DateTime instant) {
  final utc = instant.toUtc();
  final shifted = utc.add(const Duration(hours: 3));
  return DateTime(
    shifted.year,
    shifted.month,
    shifted.day,
    shifted.hour,
    shifted.minute,
  );
}

/// Dine-in arrival slot label — uses Bahrain calendar day, not device timezone.
String formatDineInScheduledTimeLabel(
  DateTime? scheduledAt, {
  String? slotLabel,
}) {
  if (slotLabel != null && slotLabel.trim().isNotEmpty) return slotLabel;
  if (scheduledAt == null) return 'Select time';
  final bh = _bahrainWallClock(scheduledAt);
  final nowBh = _bahrainWallClock(DateTime.now());
  final today = DateTime(nowBh.year, nowBh.month, nowBh.day);
  final day = DateTime(bh.year, bh.month, bh.day);
  final hh = bh.hour.toString().padLeft(2, '0');
  final mm = bh.minute.toString().padLeft(2, '0');
  if (day == today) return 'Today · $hh:$mm';
  if (day == today.add(const Duration(days: 1))) return 'Tomorrow · $hh:$mm';
  return '${bh.day}/${bh.month} · $hh:$mm';
}

/// Formats a pickup slot datetime for the time card.
String formatPickupTimeLabel(DateTime? scheduledAt, {String? readyLabel}) {
  if (scheduledAt == null) {
    return readyLabel?.isNotEmpty == true
        ? 'ASAP · ${readyLabel!}'
        : 'ASAP';
  }
  final local = scheduledAt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  if (day == today) return 'Today · $hh:$mm';
  if (day == today.add(const Duration(days: 1))) return 'Tomorrow · $hh:$mm';
  return '${local.day}/${local.month} · $hh:$mm';
}

/// Service checkout appointment time (12-hour, matches booking slot labels).
String formatServiceAppointmentWhen(DateTime? scheduledAt) {
  if (scheduledAt == null) return 'Choose a time';
  final local = scheduledAt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final time = DateFormat('h:mm a').format(local);
  if (day == today) return 'Today · $time';
  if (day == today.add(const Duration(days: 1))) return 'Tomorrow · $time';
  final date = DateFormat('EEE, d MMM').format(local);
  return '$date · $time';
}

/// All booked services for checkout summary (supports multiple lines).
String summarizeServiceCheckoutItems(List<CartLineItem> items) {
  if (items.isEmpty) return 'Service';
  final parts = <String>[];
  final seen = <String>{};
  for (final item in items) {
    final name = item.name.trim();
    if (name.isEmpty) continue;
    final key = item.productId.isNotEmpty ? item.productId : name;
    if (seen.contains(key)) continue;
    seen.add(key);
    parts.add(item.quantity > 1 ? '$name (×${item.quantity})' : name);
  }
  if (parts.isEmpty) return 'Service';
  return parts.join('\n');
}

String? formatSavedAddressLine(DeliveryAddressSnapshot? address) {
  if (address == null) return null;
  final subtitle = address.subtitle.trim();
  if (subtitle.isNotEmpty) return subtitle;
  final parts = [address.area, address.city]
      .whereType<String>()
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty);
  final line = parts.join(', ');
  return line.isEmpty ? null : line;
}

/// Service checkout location line (home address vs vendor branch).
String? serviceCheckoutLocationAddress({
  required CartSnapshot? cart,
  DeliveryAddressSnapshot? homeAddress,
}) {
  if (cart == null) return null;
  if (cart.serviceMode == 'AT_HOME') {
    return formatSavedAddressLine(homeAddress);
  }
  final venue = cart.serviceVenueAddress?.trim();
  if (venue != null && venue.isNotEmpty) return venue;
  return null;
}

/// Review screen: title line + optional address (At home / At venue).
String formatServiceReviewLocation({
  required String? serviceMode,
  required String vendorName,
  String? venueAddress,
  DeliveryAddressSnapshot? homeAddress,
}) {
  final vendor = vendorName.trim().isNotEmpty ? vendorName.trim() : '—';
  if (serviceMode == 'AT_HOME') {
    final addr = formatSavedAddressLine(homeAddress);
    if (addr != null && addr.isNotEmpty) return 'At home\n$addr';
    return 'At home';
  }
  final venue = venueAddress?.trim();
  if (venue != null && venue.isNotEmpty) {
    return 'At venue · $vendor\n$venue';
  }
  return 'At venue · $vendor';
}

/// Food / vape delivery card: "Arrives in 15–25 mins".
String formatArrivesLabel(CartDeliveryEta? eta, {String fallback = 'Arrives in 15–25 mins'}) {
  if (eta == null) return fallback;
  if (eta.etaMin > 0 && eta.etaMax > 0) {
    final maxLabel = eta.etaMax == eta.etaMin
        ? '${eta.etaMin} mins'
        : '${eta.etaMin}–${eta.etaMax} mins';
    return 'Arrives in $maxLabel';
  }
  final label = eta.etaLabel.trim();
  if (label.isEmpty) return fallback;
  if (label.toLowerCase().startsWith('arrives')) return label;
  return 'Arrives in $label';
}

/// ETA window only (no delivery-type suffix), e.g. "45–60 mins".
String formatEtaWindow(
  int? etaMin,
  int? etaMax, {
  String? etaLabel,
  String fallback = '15–25 mins',
}) {
  final min = etaMin;
  final max = etaMax;
  if (min != null && min > 0) {
    final end = (max != null && max > 0) ? max : min;
    if (end == min) return '$min mins';
    return '$min–$end mins';
  }
  final label = etaLabel?.trim() ?? '';
  if (label.isEmpty) return fallback;
  // Strip legacy "· Standard" / delivery-type suffixes.
  final cleaned = label
      .replaceAll(RegExp(r'\s*·\s*Standard\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'^Arrives in\s+', caseSensitive: false), '')
      .trim();
  return cleaned.isEmpty ? fallback : cleaned;
}

String formatEtaWindowFromCart(CartDeliveryEta? eta, {String fallback = '15–25 mins'}) {
  if (eta == null) return fallback;
  return formatEtaWindow(
    eta.etaMin,
    eta.etaMax,
    etaLabel: eta.etaLabel,
    fallback: fallback,
  );
}

/// Human-readable dine-in ready window, e.g. "in ~1 hour" / "in ~45 min".
String formatDineInReadyLabel({
  CartDineInInfo? dineIn,
  CartDeliveryEta? eta,
  String fallback = 'in ~1 hour',
}) {
  final fromDineIn = dineIn?.readyLabel.trim();
  if (fromDineIn != null && fromDineIn.isNotEmpty) return fromDineIn;
  final fromEta = eta?.etaLabel.trim();
  if (fromEta != null && fromEta.isNotEmpty) {
    if (fromEta.toLowerCase().startsWith('in ')) return fromEta;
    return 'in ~$fromEta';
  }
  final minutes = dineIn?.readyInMin ?? eta?.etaMin;
  if (minutes == null) return fallback;
  if (minutes >= 60) {
    final hours = (minutes / 60).round();
    return 'in ~$hours hour${hours == 1 ? '' : 's'}';
  }
  return 'in ~$minutes min';
}

String formatDineInPrepareNowHint(String readyLabel) {
  return 'Kitchen starts now. Table ready $readyLabel.';
}

String formatDineInPrepareNowBanner(String readyLabel) {
  final cleaned = readyLabel.replaceFirst(RegExp(r'^in\s+', caseSensitive: false), '');
  return 'Your table will be ready about $cleaned after you pay.';
}

/// Bahrain is UTC+3; matches backend scheduled drop-off ceiling (22:00 BH).
DateTime _fitScheduledWindowStart(DateTime candidateUtc) {
  final utc = candidateUtc.toUtc();
  final bahrain = utc.add(const Duration(hours: 3));
  if (bahrain.hour < 22) return utc;
  final nextMorningBh = DateTime.utc(
    bahrain.year,
    bahrain.month,
    bahrain.day + 1,
    10,
  );
  return nextMorningBh.subtract(const Duration(hours: 3));
}

/// Next window start for scheduled / vape delivery speeds.
DateTime windowStartForDelivery(String deliveryId) {
  final now = DateTime.now().toUtc();
  final raw = switch (deliveryId) {
    'same-day' => now.add(const Duration(hours: 4)),
    'next-day' => DateTime.utc(now.year, now.month, now.day + 1, 12),
    'standard' => now.add(const Duration(days: 2)),
    'economy' => now.add(const Duration(days: 5)),
    _ => now.add(const Duration(hours: 4)),
  };
  return _fitScheduledWindowStart(raw);
}

/// Human label for a scheduled window, e.g. "Tomorrow · 12:00pm–2:00pm".
String formatDeliveryWindowLabel(DateTime start, {DateTime? end}) {
  final local = start.toLocal();
  final endLocal = (end ?? start.add(const Duration(hours: 2))).toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startDay = DateTime(local.year, local.month, local.day);
  final dayDiff = startDay.difference(today).inDays;
  final dayLabel = switch (dayDiff) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ => '${local.day}/${local.month}',
  };
  String clock(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    final suffix = h >= 12 ? 'pm' : 'am';
    return m == '00' ? '$hour12$suffix' : '$hour12:$m$suffix';
  }
  return '$dayLabel · ${clock(local)}–${clock(endLocal)}';
}

/// Same-day is disabled after 12:00 local (Bahrain noon approximation on device).
bool isSameDayDeliveryAvailable({DateTime? now}) {
  final n = now ?? DateTime.now();
  return n.hour < 12;
}

String deliveryUiIdFromApi(String? speed) {
  return switch ((speed ?? '').toUpperCase()) {
    'NEXT_DAY' => 'next-day',
    'STANDARD' => 'standard',
    'ECONOMY' => 'economy',
    _ => 'same-day',
  };
}

/// Delivery speed + window from GET /cart `deliveryOptions` for checkout.
class ScheduledCheckoutDelivery {
  const ScheduledCheckoutDelivery({
    required this.speed,
    required this.windowStart,
    required this.windowEnd,
  });

  final String speed;
  final DateTime windowStart;
  final DateTime windowEnd;
}

/// Uses server `earliestWindowStartAt` so checkout matches tier rules (BH time).
ScheduledCheckoutDelivery? scheduledCheckoutDeliveryFor({
  required List<Map<String, dynamic>> deliveryOptions,
  required String uiSpeedId,
}) {
  ScheduledCheckoutDelivery? pick(String speed) {
    for (final o in deliveryOptions) {
      if ((o['id']?.toString() ?? '').toUpperCase() != speed) continue;
      if (!scheduledDeliveryOptionAvailable(o)) return null;
      final raw = o['earliestWindowStartAt']?.toString();
      final start = DateTime.tryParse(raw ?? '');
      if (start == null) return null;
      final utc = start.toUtc();
      return ScheduledCheckoutDelivery(
        speed: speed,
        windowStart: utc,
        windowEnd: utc.add(const Duration(hours: 2)),
      );
    }
    return null;
  }

  return pick(deliverySpeedApiValue(uiSpeedId));
}

/// If the selected tier is unavailable, move to the first open tier from API.
String? syncScheduledDeliveryUiSpeed(
  WidgetRef ref,
  List<Map<String, dynamic>> deliveryOptions,
) {
  if (deliveryOptions.isEmpty) return null;
  final methods = scheduledDeliveryMethodsFromApi(deliveryOptions);
  var uiId = ref.read(scheduledDeliveryUiSpeedProvider);
  ScheduledDeliveryMethod? current;
  for (final method in methods) {
    if (method.id == uiId) {
      current = method;
      break;
    }
  }
  if (current != null && current.available) return uiId;
  for (final method in methods) {
    if (method.available) {
      ref.read(scheduledDeliveryUiSpeedProvider.notifier).state = method.id;
      return method.id;
    }
  }
  return null;
}

DateTime _bahrainLocalFromUtc(DateTime utc) {
  return utc.toUtc().add(const Duration(hours: 3));
}

DateTime _bahrainServiceDate(DateTime utc) {
  final bh = _bahrainLocalFromUtc(utc);
  return DateTime.utc(bh.year, bh.month, bh.day);
}

/// Mirrors backend scheduled tier calendar rules (Bahrain service date).
bool clientScheduledTierValid(String speed, DateTime windowStartUtc) {
  final now = DateTime.now().toUtc();
  final dayDiff = _bahrainServiceDate(windowStartUtc)
      .difference(_bahrainServiceDate(now))
      .inDays;
  switch (speed.toUpperCase()) {
    case 'SAME_DAY':
      if (_bahrainLocalFromUtc(now).hour >= 12) return false;
      return dayDiff == 0;
    case 'NEXT_DAY':
      return dayDiff == 1;
    case 'STANDARD':
      return dayDiff >= 1 && dayDiff <= 3;
    case 'ECONOMY':
      return dayDiff >= 5 && dayDiff <= 7;
    default:
      return false;
  }
}

bool scheduledDeliveryOptionAvailable(Map<String, dynamic> o) {
  if (o['available'] == false) return false;
  final reason = o['unavailableReason']?.toString().trim();
  if (reason != null && reason.isNotEmpty) return false;
  if (o['available'] == true) return true;
  final speed = (o['id']?.toString() ?? '').toUpperCase();
  final raw = o['earliestWindowStartAt']?.toString();
  final start = DateTime.tryParse(raw ?? '');
  if (start != null) {
    return clientScheduledTierValid(speed, start.toUtc());
  }
  if (speed == 'SAME_DAY') {
    return _bahrainLocalFromUtc(DateTime.now().toUtc()).hour < 12;
  }
  return o['available'] == true;
}

List<ScheduledDeliveryMethod> scheduledDeliveryMethodsFromApi(
  List<Map<String, dynamic>> raw,
) {
  if (raw.isEmpty) return const [];
  return [
    for (final o in raw)
      ScheduledDeliveryMethod(
        id: deliveryUiIdFromApi(o['id']?.toString()),
        label: o['label']?.toString() ?? 'Delivery',
        subtitle: o['windowLabel']?.toString() ??
            o['subtitle']?.toString() ??
            o['note']?.toString(),
        priceValue: parseApiMoney(o['fee']) ?? 0,
        price: formatBhdAmount(o['fee']),
        available: scheduledDeliveryOptionAvailable(o),
        unavailableNote: o['note']?.toString() ??
            (o['unavailableReason'] == 'CUTOFF_PASSED'
                ? 'Available until 12 PM only'
                : o['unavailableReason'] == 'NO_VALID_DATE'
                    ? 'Not available at this time'
                    : null),
      ),
  ];
}

void showEmptyCartSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(NavigationStrings.cartEmptyTitle)),
  );
}

/// Clears geofence cart context and syncs active unlocks after a placed order.
Future<void> completeGeofenceAfterSuccessfulOrder(WidgetRef ref) async {
  clearGeofenceOrderContext(ref);
  final notifier = ref.read(activeGeofenceOffersProvider.notifier);
  notifier.state = const [];
  await notifier.refresh();
}

/// Pop checkout/review or return to the cart tab when the live cart has no items.
bool leaveCheckoutIfCartEmpty(
  BuildContext context, {
  required CartSnapshot cart,
  WidgetRef? ref,
  bool clearPendingCheckout = false,
}) {
  if (cart.hasItems) return false;
  if (clearPendingCheckout && ref != null) {
    ref.read(pendingCheckoutProvider.notifier).state = null;
  }
  showEmptyCartSnackBar(context);
  if (context.canPop()) {
    context.pop();
  } else {
    context.goHome(tab: 2, emptyCart: true);
  }
  return true;
}

/// Prefer a live `GET /addresses/check-range` result over a stale cart quote.
bool deliveryQuoteShowsOutOfRange(
  DeliveryQuote? quote, {
  DeliveryRangeCheck? liveRange,
}) {
  if (liveRange != null) {
    if (liveRange.allowsDelivery) return false;
    if (liveRange.isOutOfRange) return true;
  }
  return quote?.outOfRange == true;
}

bool checkoutPlaceOrderBlocked(
  DeliveryQuote? quote, {
  DeliveryRangeCheck? liveRange,
}) {
  if (liveRange != null && liveRange.allowsDelivery) {
    return quote?.blocksCheckout == true;
  }
  if (liveRange != null && liveRange.isOutOfRange) return true;
  return deliveryQuoteBlocksPlaceOrder(quote);
}

/// Server prompt copy. Free-delivery text does not block. Min-order text is
/// shown beside a disabled place-order action. Out of range opens the
/// delivery address screen instead of a line under the bill.
Widget deliveryQuoteNotices(
  DeliveryQuote? quote, {
  bool hideOutOfRange = false,
  DeliveryRangeCheck? liveRange,
}) {
  if (quote == null) return const SizedBox.shrink();
  final showOutOfRange = !hideOutOfRange &&
      deliveryQuoteShowsOutOfRange(quote, liveRange: liveRange);
  final lines = <String>[
    if (showOutOfRange) kOutOfDeliveryRangeMessage,
    if (quote.minOrderMessage != null) quote.minOrderMessage!,
    if (quote.freeDeliveryMessage != null) quote.freeDeliveryMessage!,
  ];
  if (lines.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: line == quote.freeDeliveryMessage
                    ? const Color(0xFF6B756E)
                    : const Color(0xFF8A3B2A),
              ),
            ),
          ),
      ],
    ),
  );
}

bool deliveryQuoteBlocksPlaceOrder(DeliveryQuote? quote) {
  if (quote == null) return false;
  return quote.blocksCheckout || quote.outOfRange;
}
