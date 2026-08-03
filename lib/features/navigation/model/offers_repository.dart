import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

/// GET /offers — optional category slug filter (food / groceries / fashion).
class OffersRepository {
  const OffersRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  Future<List<BrowseOffer>> fetchOffers({
    String? categorySlug,
    bool exclusiveOnly = true,
  }) async {
    final params = <String, String>{};
    final slug = categorySlug?.trim();
    if (slug != null && slug.isNotEmpty) {
      params['category'] = slug;
    }
    if (exclusiveOnly) {
      params['exclusive'] = 'true';
    }

    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final response = await _apiClient.getJson(
      '/offers$query',
      bearerToken: _storage.token,
    );
    final data = response?['data'];
    if (data is! List) return const [];

    final out = <BrowseOffer>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = _fromJson(raw);
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
      imageUrl: productMap?['imageUrl']?.toString(),
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
