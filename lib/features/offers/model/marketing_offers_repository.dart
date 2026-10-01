import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/offers/model/marketing_offer_models.dart';

class MarketingOffersRepository {
  const MarketingOffersRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  /// GET /customer/offers/items
  Future<MarketingOffersPage> fetchItems({
    required int page,
    int limit = 20,
    double? latitude,
    double? longitude,
    bool withinDeliveryRadius = true,
    bool recordOpened = false,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (withinDeliveryRadius) 'withinDeliveryRadius': 'true',
      if (recordOpened && _storage.hasSession) 'opened': 'true',
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    };
    final query =
        '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final response = await _apiClient.getJson(
      '/customer/offers/items$query',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return MarketingOffersPage(
        page: page,
        limit: limit,
        total: 0,
        items: const [],
        hasMore: false,
      );
    }

    final itemsRaw = data['items'];
    final items = <MarketingOfferItem>[];
    if (itemsRaw is List) {
      for (final raw in itemsRaw) {
        if (raw is Map<String, dynamic>) {
          items.add(MarketingOfferItem.fromJson(raw));
        }
      }
    }
    final total = (data['total'] as num?)?.toInt() ?? items.length;
    final currentPage = (data['page'] as num?)?.toInt() ?? page;
    final pageLimit = (data['limit'] as num?)?.toInt() ?? limit;
    return MarketingOffersPage(
      page: currentPage,
      limit: pageLimit,
      total: total,
      items: items,
      hasMore: currentPage * pageLimit < total,
    );
  }
}
