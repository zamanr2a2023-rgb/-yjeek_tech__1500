import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';

class WalletSnapshot {
  const WalletSnapshot({
    required this.balanceLabel,
    required this.cashbackLabel,
    required this.refundsLabel,
    this.balance,
    this.cashback,
    this.refundBalance,
    this.currency = 'BHD',
  });

  final String balanceLabel;
  final String cashbackLabel;
  final String refundsLabel;
  final num? balance;
  final num? cashback;
  final num? refundBalance;
  final String currency;

  static const empty = WalletSnapshot(
    balanceLabel: '___',
    cashbackLabel: '___',
    refundsLabel: '___',
  );
}

class WalletRepository {
  const WalletRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /wallet
  Future<WalletSnapshot> fetchWallet() async {
    final response = await _apiClient.getJson(
      '/wallet',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return WalletSnapshot.empty;

    final currency = data['currency'] as String? ?? 'BHD';
    return WalletSnapshot(
      balance: data['balance'] as num?,
      cashback: data['cashback'] as num?,
      refundBalance: data['refundBalance'] as num?,
      currency: currency,
      balanceLabel: _moneyLabel(data['balance'], currency),
      cashbackLabel: _moneyLabel(data['cashback'], currency),
      refundsLabel: _moneyLabel(data['refundBalance'], currency),
    );
  }

  /// GET /wallet/transactions?ledger=
  Future<List<WalletTransaction>> fetchTransactions({String? ledger}) async {
    final qs = <String, String>{
      'page': '1',
      'limit': '50',
      if (ledger != null && ledger.isNotEmpty) 'ledger': ledger,
    };
    final query = qs.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}='
              '${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');

    final response = await _apiClient.getJson(
      '/wallet/transactions?$query',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const [];
    final rows = data['transactions'];
    if (rows is! List) return const [];

    final items = <WalletTransaction>[];
    for (final raw in rows) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = _txFromJson(raw);
      if (mapped != null) items.add(mapped);
    }
    return items;
  }

  static String _moneyLabel(dynamic value, String currency) {
    if (value == null) return '___';
    if (value is! num) {
      final parsed = num.tryParse(value.toString());
      if (parsed == null) return '___';
      return '$currency ${parsed.toStringAsFixed(3)}';
    }
    return '$currency ${value.toStringAsFixed(3)}';
  }

  static WalletTransaction? _txFromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    if (amount is! num) return null;
    final positive = amount >= 0;
    final abs = amount.abs();
    final description = json['description'] as String? ??
        (json['type'] as String?)?.replaceAll('_', ' ') ??
        'Transaction';
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final subtitle = createdAt != null ? _relativeWhen(createdAt) : '___';

    return WalletTransaction(
      title: description,
      subtitle: subtitle,
      amount: '${positive ? '+ ' : '− '}BHD ${abs.toStringAsFixed(3)}',
      positive: positive,
      iconBg: positive ? const Color(0xFFE6F1FB) : const Color(0xFFF4EBD0),
    );
  }

  static String _relativeWhen(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final tod =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return 'Today · $tod';
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Yesterday · $tod';
    }
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
    return '${local.day} ${months[local.month - 1]} · $tod';
  }
}
