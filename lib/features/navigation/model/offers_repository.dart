import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/home/model/exclusive_offers_section.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class ExclusiveOffersPage {
  const ExclusiveOffersPage({
    required this.section,
    required this.offers,
  });

  final ExclusiveOffersSection section;
  final List<BrowseOffer> offers;
}

/// Curated Super Exclusive offers from `GET /home/exclusive-offers`.
class OffersRepository {
  const OffersRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  Future<ExclusiveOffersPage> fetchExclusiveOffersPage({
    String? categorySlug,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    final slug = categorySlug?.trim();
    if (slug != null && slug.isNotEmpty) {
      params['category'] = slug;
    }

    final query =
        '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final response = await _apiClient.getJson(
      '/home/exclusive-offers$query',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) {
      return ExclusiveOffersPage(
        section: ExclusiveOffersSection.fallback(),
        offers: const [],
      );
    }

    final section = ExclusiveOffersSection.fromJson(data);
    final rawItems = data['items'] ?? data['exclusiveOffers'];
    final offers = _parseOffers(rawItems);

    return ExclusiveOffersPage(section: section, offers: offers);
  }

  /// Backward-compatible list fetch for callers that only need items.
  Future<List<BrowseOffer>> fetchOffers({
    String? categorySlug,
    bool exclusiveOnly = true,
  }) async {
    if (!exclusiveOnly) {
      return _fetchLegacyOffers(categorySlug: categorySlug);
    }
    final page = await fetchExclusiveOffersPage(categorySlug: categorySlug);
    return page.offers;
  }

  Future<List<BrowseOffer>> _fetchLegacyOffers({String? categorySlug}) async {
    final params = <String, String>{};
    final slug = categorySlug?.trim();
    if (slug != null && slug.isNotEmpty) {
      params['category'] = slug;
    }

    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final response = await _apiClient.getJson(
      '/offers$query',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is List) {
      return _parseOffers(data);
    }
    if (data is Map<String, dynamic>) {
      final rawItems = data['items'] ?? data['exclusiveOffers'];
      return _parseOffers(rawItems);
    }
    return const [];
  }

  static List<BrowseOffer> _parseOffers(Object? raw) {
    if (raw is! List) return const [];
    final out = <BrowseOffer>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final mapped = _fromJson(item);
      if (mapped != null) out.add(mapped);
    }
    return out;
  }

  static BrowseOffer? _fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final vendor = json['vendor'];
    final category = json['category'];

    final productMap = product is Map<String, dynamic> ? product : null;
    final vendorMap = vendor is Map<String, dynamic> ? vendor : null;
    final categoryMap = category is Map<String, dynamic> ? category : null;

    final title = json['title']?.toString().trim() ?? '';
    final productName = productMap?['name']?.toString().trim();
    final name = (productName != null && productName.isNotEmpty)
        ? productName
        : title;
    if (name.isEmpty) return null;

    final vendorName = vendorMap?['name']?.toString().trim() ?? 'Vendor';
    final offerPrice = (json['offerPrice'] as num?)?.toDouble() ?? 0;
    final originalPrice = (json['originalPrice'] as num?)?.toDouble();
    final badge = json['badgeLabel']?.toString().trim();
    final categorySlug =
        categoryMap?['slug']?.toString().trim().toLowerCase() ?? '';
    final imageUrl = json['imageUrl']?.toString() ??
        productMap?['imageUrl']?.toString();

    return BrowseOffer(
      name: name,
      vendor: vendorName,
      price: HomeOfferStyle.formatPrice(offerPrice),
      originalPrice: originalPrice != null && originalPrice > offerPrice
          ? HomeOfferStyle.formatPrice(originalPrice)
          : null,
      badge: (badge != null && badge.isNotEmpty) ? badge : null,
      imageColor: HomeOfferStyle.forName(name),
      category: _categoryFromSlug(categorySlug),
      productId: json['productId']?.toString() ?? productMap?['id']?.toString(),
      vendorId: json['vendorId']?.toString() ?? vendorMap?['id']?.toString(),
      imageUrl: imageUrl,
    );
  }

  static OfferCategory _categoryFromSlug(String slug) {
    if (slug.contains('grocery') || slug.contains('grocer')) {
      return OfferCategory.groceries;
    }
    if (slug.contains('fashion') || slug.contains('apparel')) {
      return OfferCategory.fashion;
    }
    if (slug.contains('food') || slug.contains('restaurant')) {
      return OfferCategory.food;
    }
    return OfferCategory.food;
  }
}
