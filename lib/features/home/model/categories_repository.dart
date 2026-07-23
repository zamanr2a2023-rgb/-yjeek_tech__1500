import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

class CategoriesRepository {
  const CategoriesRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /categories — all published active categories.
  Future<List<CategoryItem>> fetchCategories({bool? featured}) async {
    final path = featured == true ? '/categories?featured=true' : '/categories';
    final response = await _apiClient.getJson(path);
    final data = response?['data'];
    if (data is! List) return HomeData.allCategories;

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
        ),
      );
    }
    return items.isNotEmpty ? items : HomeData.allCategories;
  }
}
