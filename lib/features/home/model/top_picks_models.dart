import 'package:yjeek_app/core/utils/api_media_url.dart';

/// Flat Top Pick row for Home — from `items[]` or nested `branches[].items[]`.
class HomeTopPickItem {
  const HomeTopPickItem({
    required this.branchId,
    required this.vendorId,
    required this.vendorName,
    required this.productId,
    required this.name,
    this.vendorLogoUrl,
    this.imageUrl,
    this.price,
    this.distanceKm,
    this.isAvailable = true,
    this.sortOrder = 0,
  });

  final String branchId;
  final String vendorId;
  final String vendorName;
  final String? vendorLogoUrl;
  final String productId;
  final String name;
  final String? imageUrl;
  final double? price;
  final double? distanceKm;
  final bool isAvailable;
  final int sortOrder;

  static List<HomeTopPickItem> parseTopPicksData(Map<String, dynamic> data) {
    final flat = data['items'];
    if (flat is List && flat.isNotEmpty) {
      return flat
          .whereType<Map>()
          .map((e) => _fromFlatJson(Map<String, dynamic>.from(e)))
          .where((e) => e != null)
          .cast<HomeTopPickItem>()
          .toList(growable: false);
    }

    final branches = data['branches'];
    if (branches is! List) return const [];

    final out = <HomeTopPickItem>[];
    for (final branchRaw in branches) {
      if (branchRaw is! Map<String, dynamic>) continue;
      final branchId = branchRaw['branchId']?.toString() ?? '';
      final vendorId = branchRaw['vendorId']?.toString() ?? '';
      final vendorName = branchRaw['vendorName']?.toString() ?? '';
      final vendorLogoUrl =
          resolveApiMediaUrl(branchRaw['vendorLogoUrl'] as String?);
      final distanceKm = (branchRaw['distanceKm'] as num?)?.toDouble();
      final items = branchRaw['items'];
      if (branchId.isEmpty || vendorId.isEmpty || items is! List) continue;
      for (final itemRaw in items) {
        if (itemRaw is! Map<String, dynamic>) continue;
        final mapped = _fromBranchItemJson(
          itemRaw,
          branchId: branchId,
          vendorId: vendorId,
          vendorName: vendorName,
          vendorLogoUrl: vendorLogoUrl,
          distanceKm: distanceKm,
        );
        if (mapped != null) out.add(mapped);
      }
    }
    out.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return out;
  }

  static HomeTopPickItem? _fromFlatJson(Map<String, dynamic> json) {
    final productId =
        json['productId']?.toString() ?? json['id']?.toString() ?? '';
    final branchId = json['branchId']?.toString() ?? '';
    final vendorId = json['vendorId']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    if (productId.isEmpty || vendorId.isEmpty || name.isEmpty) return null;
    final priceRaw = json['price'];
    return HomeTopPickItem(
      branchId: branchId,
      vendorId: vendorId,
      vendorName: json['vendorName']?.toString() ?? '',
      vendorLogoUrl: resolveApiMediaUrl(json['vendorLogoUrl'] as String?),
      productId: productId,
      name: name,
      imageUrl: resolveApiMediaUrl(json['imageUrl'] as String?),
      price: priceRaw is num ? priceRaw.toDouble() : null,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] != false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  static HomeTopPickItem? _fromBranchItemJson(
    Map<String, dynamic> json, {
    required String branchId,
    required String vendorId,
    required String vendorName,
    String? vendorLogoUrl,
    double? distanceKm,
  }) {
    final productId = json['productId']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    if (productId.isEmpty || name.isEmpty) return null;
    final priceRaw = json['price'];
    return HomeTopPickItem(
      branchId: branchId,
      vendorId: vendorId,
      vendorName: vendorName,
      vendorLogoUrl: vendorLogoUrl,
      productId: productId,
      name: name,
      imageUrl: resolveApiMediaUrl(json['imageUrl'] as String?),
      price: priceRaw is num ? priceRaw.toDouble() : null,
      distanceKm: distanceKm,
      isAvailable: json['isAvailable'] != false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
