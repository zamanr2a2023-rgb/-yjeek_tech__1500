import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One sanitized native [BenefitPayDebug] event mirrored from Android.
class BenefitPayNativeDebugEvent {
  const BenefitPayNativeDebugEvent({
    required this.timestampMs,
    required this.event,
    required this.fields,
  });

  final int timestampMs;
  final String event;
  final Map<String, String> fields;

  factory BenefitPayNativeDebugEvent.fromMap(Map<dynamic, dynamic> raw) {
    final fieldsRaw = raw['fields'];
    final fields = <String, String>{};
    if (fieldsRaw is Map) {
      for (final entry in fieldsRaw.entries) {
        fields[entry.key.toString()] = entry.value?.toString() ?? '';
      }
    }
    return BenefitPayNativeDebugEvent(
      timestampMs: int.tryParse(raw['timestampMs']?.toString() ?? '') ??
          DateTime.now().millisecondsSinceEpoch,
      event: raw['event']?.toString() ?? 'unknown',
      fields: fields,
    );
  }

  String formatTime() {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  String formatBlock() {
    final lines = <String>['[${formatTime()}] $event'];
    for (final entry in fields.entries) {
      lines.add('${entry.key}: ${entry.value}');
    }
    return lines.join('\n');
  }
}

/// DEBUG Android-only bridge for native BenefitPay debug buffer.
abstract final class BenefitPayNativeDebugLogs {
  static const MethodChannel _channel =
      MethodChannel('bh.yjeek.customer/benefit_pay');

  static bool get isSupported =>
      kDebugMode && defaultTargetPlatform == TargetPlatform.android;

  static Future<List<BenefitPayNativeDebugEvent>> fetch() async {
    if (!isSupported) return const [];
    try {
      final raw =
          await _channel.invokeMethod<List<dynamic>>('getBenefitPayDebugLogs');
      if (raw == null) return const [];
      return raw
          .whereType<Map>()
          .map((e) => BenefitPayNativeDebugEvent.fromMap(e))
          .toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  static Future<void> clear() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('clearBenefitPayDebugLogs');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  static String? latestReferenceId(List<BenefitPayNativeDebugEvent> events) {
    for (var i = events.length - 1; i >= 0; i--) {
      final e = events[i];
      final ref = e.fields['referenceId'];
      if (ref != null && ref.isNotEmpty && ref != '—') return ref;
    }
    return null;
  }

  static String buildCopyReport({
    required String? orderId,
    required List<BenefitPayNativeDebugEvent> events,
  }) {
    final debugId = latestReferenceId(events) ?? '—';
    final buffer = StringBuffer()
      ..writeln('BenefitPay Debug Report')
      ..writeln('----------------')
      ..writeln('Order ID: ${orderId ?? '—'}')
      ..writeln('Debug ID: $debugId')
      ..writeln()
      ..writeln('Event timeline:');
    for (final event in events) {
      buffer.writeln(event.formatBlock());
      buffer.writeln();
    }
    return buffer.toString().trim();
  }
}
