import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/utils/api_media_url.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

class RetailCategoryDetail {
  const RetailCategoryDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.tiles,
  });

  final String id;
  final String name;
  final String slug;
  final List<RetailCategoryTile> tiles;
}

enum RetailTileKind { subcategory, vendor }

class RetailCategoryTile {
  const RetailCategoryTile({
    required this.id,
    required this.name,
    required this.kind,
    this.imageUrl,
    this.slug,
  });

  final String id;
  final String name;
  final RetailTileKind kind;
  final String? imageUrl;
  final String? slug;
}

class CategoriesRepository {
  const CategoriesRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /categories — all published active categories.
  Future<List<CategoryItem>> fetchCategories({bool? featured}) async {
    final path = featured == true ? '/categories?featured=true' : '/categories';
    final response = await _apiClient.getJson(path);
    final data = response?['data'];
    if (data is! List) return const [];

    final items = <CategoryItem>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final name = item['name'] as String?;
      if (name == null || name.isEmpty) continue;
      items.add(
        categoryItemFromApi(
          id: item['id'] as String?,
          name: name,
          slug: item['slug'] as String?,
          iconUrl: item['iconUrl'] as String?,
        ),
      );
    }
    return items;
  }

  /// GET /categories/:slug — detail + menuCategories / subTypes / vendors.
  Future<RetailCategoryDetail?> fetchRetailCategory(String slug) async {
    final response = await _apiClient.getJson('/categories/$slug');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;

    final id = data['id']?.toString() ?? slug;
    final name = (data['name'] as String?)?.trim().isNotEmpty == true
        ? data['name'] as String
        : slug;
    final resolvedSlug = (data['slug'] as String?)?.trim().isNotEmpty == true
        ? data['slug'] as String
        : slug;

    final tiles = <RetailCategoryTile>[];

    void addNode(Map<String, dynamic> node) {
      final nodeId = node['id']?.toString();
      final nodeName = (node['name'] as String?)?.trim();
      if (nodeId == null ||
          nodeId.isEmpty ||
          nodeName == null ||
          nodeName.isEmpty) {
        return;
      }
      tiles.add(
        RetailCategoryTile(
          id: nodeId,
          name: nodeName,
          kind: RetailTileKind.subcategory,
          slug: node['slug']?.toString(),
          imageUrl: resolveApiMediaUrl(node['iconUrl'] as String?) ??
              resolveApiMediaUrl(node['imageUrl'] as String?),
        ),
      );
      final children = node['children'];
      if (children is List) {
        for (final child in children) {
          if (child is Map<String, dynamic>) addNode(child);
        }
      }
    }

    final menu = data['menuCategories'];
    if (menu is List) {
      for (final raw in menu) {
        if (raw is Map<String, dynamic>) addNode(raw);
      }
    }

    final subTypes = data['subTypes'];
    if (tiles.isEmpty && subTypes is List) {
      for (final raw in subTypes) {
        if (raw is! Map<String, dynamic>) continue;
        final nodeId = raw['id']?.toString();
        final nodeName = (raw['name'] as String?)?.trim();
        if (nodeId == null || nodeName == null || nodeName.isEmpty) continue;
        tiles.add(
          RetailCategoryTile(
            id: nodeId,
            name: nodeName,
            kind: RetailTileKind.subcategory,
            slug: raw['slug']?.toString(),
            imageUrl: resolveApiMediaUrl(raw['iconUrl'] as String?),
          ),
        );
      }
    }

    if (tiles.isEmpty) {
      final vendorsRes = await _apiClient.getJson(
        '/vendors?category=${Uri.encodeQueryComponent(resolvedSlug)}',
      );
      final vendorsData = vendorsRes?['data'];
      final vendors = vendorsData is List
          ? vendorsData
          : (vendorsData is Map ? vendorsData['items'] : null);
      if (vendors is List) {
        for (final raw in vendors) {
          if (raw is! Map<String, dynamic>) continue;
          final vid = raw['id']?.toString();
          final vname = (raw['name'] as String?)?.trim();
          if (vid == null || vname == null || vname.isEmpty) continue;
          tiles.add(
            RetailCategoryTile(
              id: vid,
              name: vname,
              kind: RetailTileKind.vendor,
              imageUrl: resolveApiMediaUrl(raw['logoUrl'] as String?) ??
                  resolveApiMediaUrl(raw['coverUrl'] as String?),
            ),
          );
        }
      }
    }

    return RetailCategoryDetail(
      id: id,
      name: name,
      slug: resolvedSlug,
      tiles: tiles,
    );
  }
}
