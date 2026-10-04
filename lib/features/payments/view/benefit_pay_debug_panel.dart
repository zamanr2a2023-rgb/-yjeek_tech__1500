import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/features/payments/benefit_pay_native_debug_logs.dart';
import 'package:yjeek_app/features/payments/pay_now_helper.dart';

/// Temporary DEBUG-only Android panel mirroring native [BenefitPayDebug] events.
class BenefitPayDebugPanel extends StatefulWidget {
  const BenefitPayDebugPanel({
    super.key,
    required this.orderId,
    required this.methodApi,
  });

  final String? orderId;
  final String methodApi;

  @override
  State<BenefitPayDebugPanel> createState() => _BenefitPayDebugPanelState();
}

class _BenefitPayDebugPanelState extends State<BenefitPayDebugPanel> {
  Timer? _pollTimer;
  bool _expanded = false;
  List<BenefitPayNativeDebugEvent> _events = const [];
  bool _loading = false;

  bool get _visible =>
      BenefitPayNativeDebugLogs.isSupported &&
      PayNowHelper.isBenefitPayNative(widget.methodApi);

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      unawaited(_refresh(silent: true));
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _refresh({bool silent = false}) async {
    if (!_visible) return;
    if (!silent && mounted) setState(() => _loading = true);
    final events = await BenefitPayNativeDebugLogs.fetch();
    if (!mounted) return;
    setState(() {
      _events = events;
      if (!silent) _loading = false;
    });
  }

  Future<void> _clear() async {
    await BenefitPayNativeDebugLogs.clear();
    if (!mounted) return;
    setState(() => _events = const []);
  }

  Future<void> _copy() async {
    final text = BenefitPayNativeDebugLogs.buildCopyReport(
      orderId: widget.orderId,
      events: _events,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('BenefitPay debug report copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onExpansionChanged(bool expanded) {
    setState(() => _expanded = expanded);
    if (expanded) {
      unawaited(_refresh());
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final debugId =
        BenefitPayNativeDebugLogs.latestReferenceId(_events) ?? '—';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: const Color(0xFFF4F6F8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _expanded,
          onExpansionChanged: _onExpansionChanged,
          title: const Text(
            'BenefitPay Debug',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF344054),
            ),
          ),
          subtitle: Text(
            _expanded
                ? '${_events.length} event(s) — expand after Pay to capture failure'
                : 'Tap to open native event log (debug build)',
            style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Order ID: ${widget.orderId ?? '—'}\nDebug ID: $debugId',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475467),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _events.isEmpty ? null : _copy,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                      ),
                      TextButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear'),
                      ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                    ),
                    child: _events.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'No native events yet.\nTap Pay, then return here after BenefitPay fails.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF667085),
                              ),
                            ),
                          )
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    event.formatBlock(),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      height: 1.35,
                                      color: Color(0xFF101828),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
