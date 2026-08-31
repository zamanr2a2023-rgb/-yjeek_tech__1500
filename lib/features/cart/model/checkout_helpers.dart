import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/pending_checkout.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

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

String? dropOffApiValue(int index) {
  if (index < 0 || index >= kDropOffApiValues.length) return null;
  return kDropOffApiValues[index];
}

/// Map saved address drop-off prefs → chip index (first known pref wins).
int dropOffIndexFromPrefs(List<String>? prefs, {int fallback = 0}) {
  if (prefs == null || prefs.isEmpty) return fallback;
  for (final pref in prefs) {
    final i = kDropOffApiValues.indexOf(pref);
    if (i >= 0) return i;
  }
  return fallback;
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

double tipAmountFrom(List<TipOption> options, int index) {
  if (index < 0 || index >= options.length) return 0;
  return options[index].amount ?? 0;
}

List<BillLine> billLinesWithTip(CartSnapshot cart, double tipAmount) {
  final lines = List<BillLine>.from(cart.billLines);
  lines.removeWhere((l) => l.isBold);
  if (tipAmount > 0) {
    lines.add(
      BillLine(
        label: 'Tip',
        value: 'BHD ${tipAmount.toStringAsFixed(3)}',
      ),
    );
  }
  final total = cart.totalAmount + tipAmount;
  lines.add(
    BillLine(
      label: 'Order total',
      value: 'BHD ${total.toStringAsFixed(3)}',
      isBold: true,
    ),
  );
  return lines;
}

String formatCheckoutTotal(CartSnapshot cart, double tipAmount) {
  return 'BHD ${(cart.totalAmount + tipAmount).toStringAsFixed(3)}';
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

void showEmptyCartSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(NavigationStrings.cartEmptyTitle)),
  );
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
