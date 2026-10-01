class WalletLedgerPage {
  const WalletLedgerPage({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  final List<WalletLedgerEntry> items;
  final String? nextCursor;
  final bool hasMore;
}

class WalletLedgerEntry {
  const WalletLedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.withdrawable,
    this.expiresAt,
    this.orderId,
    this.createdAt,
    this.sourceRef,
  });

  final String id;
  final String type;
  final String amount;
  final String status;
  final bool withdrawable;
  final DateTime? expiresAt;
  final String? orderId;
  final DateTime? createdAt;
  final String? sourceRef;

  String get amountLabel => 'BHD $amount';

  String get typeLabel {
    final t = type.toLowerCase();
    if (t.contains('referral')) return 'Referral bonus';
    if (t.contains('cashback')) return 'Cashback';
    return type;
  }

  factory WalletLedgerEntry.fromJson(Map<String, dynamic> json) {
    return WalletLedgerEntry(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: _money(json['amount']),
      status: json['status']?.toString() ?? '',
      withdrawable: json['withdrawable'] == true,
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      orderId: json['orderId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      sourceRef: json['sourceRef']?.toString(),
    );
  }
}

String _money(dynamic raw) {
  if (raw is num) return raw.toStringAsFixed(3);
  final parsed = double.tryParse(raw?.toString() ?? '');
  return parsed == null ? '0.000' : parsed.toStringAsFixed(3);
}
