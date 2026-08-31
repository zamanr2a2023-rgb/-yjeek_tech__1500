import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/category_navigation.dart';
import 'package:yjeek_app/features/home/model/home_data.dart';
import 'package:yjeek_app/features/ui_content/model/banner_models.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Safe tap router — invalid targets are ignored (no crash).
Future<void> handleUiBannerTap(
  BuildContext context,
  UiBanner banner, {
  List<CategoryItem>? categories,
  Future<List<CategoryItem>> Function()? loadCategories,
}) async {
  try {
    final action = (banner.tapAction ?? 'NONE').toUpperCase().trim();
    if (action.isEmpty || action == 'NONE') return;

    final target = banner.targetId?.trim();
    switch (action) {
      case 'OPEN_STORE':
        if (target == null || target.isEmpty) return;
        context.push(BrowseRoutes.vendorMenu(vendorId: target));
        return;
      case 'OPEN_CATEGORY':
        if (target == null || target.isEmpty) return;
        final category = await _resolveCategory(
          target,
          categories: categories,
          loadCategories: loadCategories,
        );
        if (!context.mounted) return;
        openHomeCategory(context, category);
        return;
      case 'OPEN_URL':
        if (target == null || target.isEmpty) return;
        final uri = Uri.tryParse(target);
        if (uri == null) return;
        if (uri.scheme != 'http' && uri.scheme != 'https') return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      case 'OPEN_OFFER':
        context.push(RouteNames.exclusiveOffers);
        return;
      default:
        return;
    }
  } catch (_) {
    // Safe no-op on any navigation / URL failure.
  }
}

CategoryItem? _matchCategory(String target, List<CategoryItem> categories) {
  final key = target.toLowerCase().trim();
  for (final category in categories) {
    final id = category.id?.trim();
    if (id != null && id.isNotEmpty && id == target) return category;
    final slug = (category.slug ?? '').toLowerCase().trim();
    if (slug.isNotEmpty && slug == key) return category;
    if (category.name.toLowerCase().trim() == key) return category;
  }
  return null;
}

Future<CategoryItem> _resolveCategory(
  String target, {
  List<CategoryItem>? categories,
  Future<List<CategoryItem>> Function()? loadCategories,
}) async {
  final fromProvided = _matchCategory(target, categories ?? const []);
  if (fromProvided != null) return fromProvided;

  if (loadCategories != null) {
    try {
      final remote = await loadCategories();
      final fromRemote = _matchCategory(target, remote);
      if (fromRemote != null) return fromRemote;
    } catch (_) {}
  }

  final fromLocal = _matchCategory(target, [
    ...HomeData.allCategories,
    ...HomeData.homeCategories,
  ]);
  if (fromLocal != null) return fromLocal;

  return CategoryItem(
    id: target,
    name: target,
    slug: target,
    icon: Icons.category_outlined,
    backgroundColor: const Color(0xFFE8F5E9),
  );
}
