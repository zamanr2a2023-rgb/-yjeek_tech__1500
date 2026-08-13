import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/home/model/category_item.dart';
import 'package:yjeek_app/features/home/model/category_navigation.dart';
import 'package:yjeek_app/features/ui_content/model/banner_models.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Safe tap router — invalid targets are ignored (no crash).
Future<void> handleUiBannerTap(BuildContext context, UiBanner banner) async {
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
        openHomeCategory(
          context,
          CategoryItem(
            id: target,
            name: target,
            slug: target,
            icon: Icons.category_outlined,
            backgroundColor: const Color(0xFFE8F5E9),
          ),
        );
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
