import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/payments/model/benefit_pay_models.dart';

class WalletSnapshot {
  const WalletSnapshot({
    required this.balanceLabel,
    required this.cashbackLabel,
    required this.refundsLabel,
    this.balance,
    this.cashback,
    this.refundBalance,
    this.currency = 'BHD',
    this.withdrawalEligible = false,
    this.withdrawalMinimum = 10,
    this.payoutRate = 0.7,
    this.kycVerified = false,
  });

  final String balanceLabel;
  final String cashbackLabel;
  final String refundsLabel;
  final num? balance;
  final num? cashback;
  final num? refundBalance;
  final String currency;
  final bool withdrawalEligible;
  final num withdrawalMinimum;
  final num payoutRate;
  final bool kycVerified;

  static const empty = WalletSnapshot(
    balanceLabel: '___',
    cashbackLabel: '___',
    refundsLabel: '___',
  );
}

class WithdrawalQuote {
  const WithdrawalQuote({
    required this.amountRequested,
    required this.amountPayable,
    required this.feeAmount,
    required this.payoutRate,
    required this.balance,
    required this.eligible,
    required this.reasons,
    required this.currency,
    required this.processingSla,
  });

  final num amountRequested;
  final num amountPayable;
  final num feeAmount;
  final num payoutRate;
  final num balance;
  final bool eligible;
  final List<String> reasons;
  final String currency;
  final String processingSla;

  String money(num value) =>
      '$currency ${value.toDouble().toStringAsFixed(3)}';

  int get receivePercent => (payoutRate * 100).round();
  int get feePercent => 100 - receivePercent;

  String get splitTitle => '$receivePercent / $feePercent pay-out split';
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
    final withdrawal = data['withdrawal'];
    final w = withdrawal is Map<String, dynamic> ? withdrawal : null;

    return WalletSnapshot(
      balance: parseMoney(data['balance']),
      cashback: parseMoney(data['cashback']),
      refundBalance: parseMoney(data['refundBalance']),
      currency: currency,
      balanceLabel: _moneyLabel(data['balance'], currency),
      cashbackLabel: _moneyLabel(data['cashback'], currency),
      refundsLabel: _moneyLabel(data['refundBalance'], currency),
      withdrawalEligible: w?['eligible'] == true,
      withdrawalMinimum: parseMoney(w?['minimumAmount']) ?? 10,
      payoutRate: parseMoney(w?['payoutRate']) ?? 0.7,
      kycVerified: w?['kycVerified'] == true,
    );
  }

  /// GET /wallet/withdrawals/quote?amount=
  Future<WithdrawalQuote?> fetchWithdrawalQuote(num amount) async {
    final response = await _apiClient.getJson(
      '/wallet/withdrawals/quote?amount=${amount.toString()}',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;

    final reasonsRaw = data['reasons'];
    final reasons = <String>[];
    if (reasonsRaw is List) {
      for (final r in reasonsRaw) {
        if (r is String && r.isNotEmpty) reasons.add(r);
      }
    }

    return WithdrawalQuote(
      amountRequested: (data['amountRequested'] as num?) ?? amount,
      amountPayable: (data['amountPayable'] as num?) ?? 0,
      feeAmount: (data['feeAmount'] as num?) ?? 0,
      payoutRate: (data['payoutRate'] as num?) ?? 0.7,
      balance: (data['balance'] as num?) ?? 0,
      eligible: data['eligible'] == true,
      reasons: reasons,
      currency: data['currency'] as String? ?? 'BHD',
      processingSla: data['processingSla'] as String? ??
          'Review ≤ 2 working days · bank transfer 3–7 working days after approval',
    );
  }

  /// POST /wallet/withdrawals
  Future<ApiResponse> requestWithdrawal({
    required num amount,
    String? iban,
    String? accountName,
  }) {
    return _apiClient.postJson(
      '/wallet/withdrawals',
      {
        'amount': amount,
        if (iban != null && iban.isNotEmpty) 'iban': iban,
        if (accountName != null && accountName.isNotEmpty)
          'accountName': accountName,
      },
      bearerToken: _token,
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
