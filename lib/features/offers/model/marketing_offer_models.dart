import 'package:yjeek_app/core/utils/api_media_url.dart';

class MarketingOffersPage {
  const MarketingOffersPage({
    required this.page,
    required this.limit,
    required this.total,
    required this.items,
    required this.hasMore,
  });

  final int page;
  final int limit;
  final int total;
  final List<MarketingOfferItem> items;
  final bool hasMore;
}

class MarketingOfferItem {
  const MarketingOfferItem({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.discountedPrice,
    required this.onPromotion,
    this.promotionId,
    this.imageUrl,
    this.vendorName,
    this.vendorLogoUrl,
    this.vendorHasOffers = false,
    this.vendorOffersLabel,
  });

  final String id;
  final String vendorId;
  final String name;
  final double price;
  final double originalPrice;
  final double discountedPrice;
  final bool onPromotion;
  final String? promotionId;
  final String? imageUrl;
  final String? vendorName;
  final String? vendorLogoUrl;
  final bool vendorHasOffers;
  final String? vendorOffersLabel;

  bool get showStrike =>
      onPromotion && originalPrice > discountedPrice + 0.0001;

  factory MarketingOfferItem.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'];
    final vendorMap = vendor is Map<String, dynamic> ? vendor : null;
    final original = (json['originalPrice'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0;
    final discounted = (json['discountedPrice'] as num?)?.toDouble() ?? original;
    return MarketingOfferItem(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ??
          vendorMap?['id']?.toString() ??
          '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? original,
      originalPrice: original,
      discountedPrice: discounted,
      onPromotion: json['onPromotion'] == true,
      promotionId: json['promotionId']?.toString(),
      imageUrl: resolveApiMediaUrl(json['imageUrl'] as String?),
      vendorName: vendorMap?['name']?.toString(),
      vendorLogoUrl: resolveApiMediaUrl(vendorMap?['logoUrl'] as String?),
      vendorHasOffers: vendorMap?['hasOffers'] == true,
      vendorOffersLabel: vendorMap?['offersLabel']?.toString(),
    );
  }
}
