import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/rewards/model/wallet_ledger_models.dart';

class WalletLedgerRepository {
  const WalletLedgerRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// GET /customer/wallet/ledger
  Future<WalletLedgerPage> fetchLedger({
    String? status,
    String? type,
    String? cursor,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      if (status != null && status.isNotEmpty) 'status': status,
      if (type != null && type.isNotEmpty) 'type': type,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };
    final query =
        '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final response = await _apiClient.getJson(
      '/customer/wallet/ledger$query',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return const WalletLedgerPage(items: [], hasMore: false);
    }
    final itemsRaw = data['items'];
    final items = <WalletLedgerEntry>[];
    if (itemsRaw is List) {
      for (final raw in itemsRaw) {
        if (raw is Map<String, dynamic>) {
          items.add(WalletLedgerEntry.fromJson(raw));
        }
      }
    }
    return WalletLedgerPage(
      items: items,
      nextCursor: data['nextCursor']?.toString(),
      hasMore: data['hasMore'] == true,
    );
  }
}
