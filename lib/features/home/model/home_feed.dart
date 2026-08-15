import 'package:yjeek_app/core/constants/home_strings.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

class HomeDeliverTo {
  const HomeDeliverTo({
    required this.addressId,
    required this.label,
    this.area,
    this.city,
    this.line1,
  });

  final String addressId;
  final String label;
  final String? area;
  final String? city;
  final String? line1;

  factory HomeDeliverTo.fromJson(Map<String, dynamic> json) {
    return HomeDeliverTo(
      addressId: json['addressId'] as String? ?? '',
      label: json['label'] as String? ?? '',
      area: json['area'] as String?,
      city: json['city'] as String?,
      line1: json['line1'] as String?,
    );
  }
}

class HomeActiveOrder {
  const HomeActiveOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.vendorName,
    this.etaLabel,
    this.totalAmount,
  });

  final String id;
  final String orderNumber;
  final String status;
  final String vendorName;
  final String? etaLabel;
  final num? totalAmount;

  factory HomeActiveOrder.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'];
    final vendorName = vendor is Map<String, dynamic>
        ? (vendor['name'] as String? ?? 'Vendor')
        : 'Vendor';

    return HomeActiveOrder(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? '',
      vendorName: vendorName,
      etaLabel: json['etaLabel'] as String?,
      totalAmount: json['totalAmount'] as num?,
    );
  }

  String get title {
    switch (status) {
      case 'PLACED':
      case 'CONFIRMED':
        return HomeStrings.orderConfirmedStatus;
      case 'PREPARING':
      case 'READY':
        return HomeStrings.preparingOrder;
      case 'SEARCHING_DRIVER':
      case 'DRIVER_ASSIGNED':
        return HomeStrings.findingChamp;
      case 'PICKED_UP':
      case 'IN_TRANSIT':
      case 'ON_THE_WAY':
        return HomeStrings.onTheWay;
      default:
        return HomeStrings.orderInProgress;
    }
  }

  String get subtitle {
    final eta = etaLabel;
    if (eta != null && eta.isNotEmpty) {
      return '$vendorName · arrives $eta';
    }
    return vendorName;
  }
}

class HomeSpotlight {
  const HomeSpotlight({
    required this.id,
    required this.title,
    this.subtitle,
    this.vendorId,
    this.imageUrl,
    this.ctaLabel,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? vendorId;
  final String? imageUrl;
  final String? ctaLabel;

  factory HomeSpotlight.fromJson(Map<String, dynamic> json) {
    return HomeSpotlight(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      vendorId: json['vendorId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      ctaLabel: json['ctaLabel'] as String?,
    );
  }
}

/// Parsed `GET /home` payload, mapped to existing home UI models.
class HomeFeed {
  const HomeFeed({
    required this.greeting,
    required this.deliverToLabel,
    required this.categories,
    required this.reorderVendors,
    required this.exclusiveOffers,
    this.deliverTo,
    this.activeOrder,
    this.spotlight,
  });

  final String greeting;
  final String deliverToLabel;
  final HomeDeliverTo? deliverTo;
  final HomeActiveOrder? activeOrder;
  final List<CategoryItem> categories;
  final List<BrandItem> reorderVendors;
  final List<OfferItem> exclusiveOffers;
  final HomeSpotlight? spotlight;

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    final deliverToJson = json['deliverTo'];
    final deliverTo = deliverToJson is Map<String, dynamic>
        ? HomeDeliverTo.fromJson(deliverToJson)
        : null;

    final activeOrderJson = json['activeOrder'];
    final activeOrder = activeOrderJson is Map<String, dynamic>
        ? HomeActiveOrder.fromJson(activeOrderJson)
        : null;

    final spotlightJson = json['spotlight'];
    final spotlight = spotlightJson is Map<String, dynamic>
        ? HomeSpotlight.fromJson(spotlightJson)
        : null;

    final categoriesJson = json['featuredCategories'];
    final categories = <CategoryItem>[];
    if (categoriesJson is List) {
      for (final item in categoriesJson) {
        if (item is! Map<String, dynamic>) continue;
        final name = item['name'] as String?;
        if (name == null || name.isEmpty) continue;
        categories.add(
          categoryItemFromApi(
            id: item['id'] as String?,
            name: name,
            slug: item['slug'] as String?,
          ),
        );
      }
    }

    final vendorsJson = json['reorderVendors'];
    final vendors = <BrandItem>[];
    if (vendorsJson is List) {
      for (final item in vendorsJson) {
        if (item is! Map<String, dynamic>) continue;
        final name = item['name'] as String?;
        if (name == null || name.isEmpty) continue;
        vendors.add(
          brandItemFromApi(
            id: item['id'] as String?,
            name: name,
            logoUrl: item['logoUrl'] as String?,
          ),
        );
      }
    }

    final offersJson = json['exclusiveOffers'];
    final offers = <OfferItem>[];
    if (offersJson is List) {
      for (final item in offersJson) {
        if (item is! Map<String, dynamic>) continue;
        final title = item['title'] as String? ?? '';
        final product = item['product'];
        final productName = product is Map<String, dynamic>
            ? product['name'] as String?
            : null;
        final imageUrl = product is Map<String, dynamic>
            ? product['imageUrl'] as String?
            : null;
        final name = (productName != null && productName.isNotEmpty)
            ? productName
            : title;
        if (name.isEmpty) continue;
        final price = item['offerPrice'];
        final productId = item['productId']?.toString() ??
            (product is Map<String, dynamic>
                ? product['id']?.toString()
                : null);
        final category = item['category'];
        final categorySlug = category is Map<String, dynamic>
            ? category['slug']?.toString()
            : null;
        offers.add(
          offerItemFromApi(
            name: name,
            offerPrice: price is num ? price : 0,
            imageUrl: imageUrl,
            badgeLabel: item['badgeLabel'] as String?,
            productId: productId,
            categorySlug: categorySlug,
          ),
        );
      }
    }

    final rawGreeting = json['greeting'] as String? ?? 'Welcome to Yjeek';
    final greeting = rawGreeting.contains('👋') ? rawGreeting : '$rawGreeting 👋';

    return HomeFeed(
      greeting: greeting,
      deliverTo: deliverTo,
      deliverToLabel: (deliverTo?.label.isNotEmpty ?? false)
          ? deliverTo!.label
          : HomeStrings.chooseLocation,
      activeOrder: activeOrder,
      categories: categories.isNotEmpty ? categories : HomeData.homeCategories,
      reorderVendors: vendors,
      exclusiveOffers:
          offers.isNotEmpty ? offers : HomeData.exclusiveOffers,
      spotlight: spotlight,
    );
  }

  /// Offline / error fallback — no fake logged-in identity.
  factory HomeFeed.fallback() {
    return HomeFeed(
      greeting: HomeStrings.hello,
      deliverToLabel: HomeStrings.chooseLocation,
      categories: HomeData.homeCategories,
      reorderVendors: const [],
      exclusiveOffers: HomeData.exclusiveOffers,
    );
  }
}
