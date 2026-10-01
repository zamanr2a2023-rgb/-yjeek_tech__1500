class CashbackPreview {
  const CashbackPreview({
    required this.amount,
    required this.rate,
    required this.paidOwn,
    required this.message,
  });

  final String amount;
  final String rate;
  final String paidOwn;
  final String message;

  String get amountLabel => '+ BHD $amount';

  bool get hasMessage => message.trim().isNotEmpty;

  factory CashbackPreview.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CashbackPreview(
        amount: '0.000',
        rate: '0.000',
        paidOwn: '0.000',
        message: '',
      );
    }
    return CashbackPreview(
      amount: _money(json['amount']),
      rate: _money(json['rate']),
      paidOwn: _money(json['paidOwn']),
      message: json['message']?.toString() ?? '',
    );
  }

  static CashbackPreview? tryParse(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final preview = CashbackPreview.fromJson(raw);
    if (!preview.hasMessage && preview.amount == '0.000') return preview;
    return preview;
  }
}

String _money(dynamic raw) {
  if (raw is num) return raw.toStringAsFixed(3);
  final parsed = double.tryParse(raw?.toString() ?? '');
  return parsed == null ? '0.000' : parsed.toStringAsFixed(3);
}
