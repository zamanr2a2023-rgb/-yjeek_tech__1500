import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/order_flow/order_flow_routes.dart';
import 'package:yjeek_app/features/spin/spin_routes.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Parsed `yjeek://` target.
class YjeekDeepLink {
  const YjeekDeepLink._(this.path, {this.query = const {}});

  final String path;
  final Map<String, String> query;

  static YjeekDeepLink? tryParse(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    Uri? uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    if (uri.scheme.isEmpty && trimmed.startsWith('yjeek://')) {
      uri = Uri.tryParse(trimmed.replaceFirst('yjeek://', 'yjeek:/'));
    }
    if (uri == null) return null;
    if (uri.scheme != 'yjeek') return null;

    final host = uri.host;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final parts = <String>[
      if (host.isNotEmpty) host,
      ...segments,
    ];
    if (parts.isEmpty) return null;

    return YjeekDeepLink._(
      '/${parts.join('/')}',
      query: uri.queryParameters,
    );
  }
}

/// Routes marketing / transactional deep links through go_router.
void openYjeekDeepLink(GoRouter router, String deepLink) {
  final parsed = YjeekDeepLink.tryParse(deepLink);
  if (parsed == null) return;
  _openParsed(router, parsed);
}

void _openParsed(GoRouter router, YjeekDeepLink link) {
  final parts = link.path.split('/').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return;

  switch (parts.first) {
    case 'rewards':
      router.push(RouteNames.rewards);
      return;
    case 'offers':
      router.push(RouteNames.marketingOffers);
      return;
    case 'referral':
      router.push(RouteNames.referral);
      return;
    case 'vouchers':
      if (parts.length >= 2) {
        router.push('${RouteNames.voucherDetail}?id=${parts[1]}');
      } else {
        router.push(RouteNames.vouchers);
      }
      return;
    case 'spin':
      final id = parts.length >= 2 ? parts[1] : link.query['campaignId'];
      if (id != null && id.isNotEmpty) {
        router.push(SpinRoutes.wheel(campaignId: id));
      } else {
        router.push(RouteNames.rewards);
      }
      return;
    case 'vendor':
      if (parts.length >= 2) {
        router.push(
          BrowseRoutes.vendorMenu(vendorId: parts[1], returnTo: RouteNames.home),
        );
      }
      return;
    case 'category':
      if (parts.length >= 2) {
        final id = parts[1];
        router.push(BrowseRoutes.electronicsBrowse(category: id, title: id));
      }
      return;
    case 'orders':
      if (parts.length >= 2) {
        final orderId = parts[1];
        if (parts.length >= 3 && parts[2] == 'chat') {
          router.push(OrderFlowRoutes.chatFor(orderId));
        } else {
          router.push(OrderFlowRoutes.statusFor(orderId));
        }
      }
      return;
    default:
      return;
  }
}

Map<String, String> _mergeMetadata(Map<String, String> data) {
  final out = Map<String, String>.from(data);
  final metaRaw = data['metadata'];
  if (metaRaw != null && metaRaw.isNotEmpty) {
    try {
      final decoded = jsonDecode(metaRaw);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          final key = entry.key.toString();
          final value = entry.value?.toString() ?? '';
          if (value.isNotEmpty) out[key] = value;
        }
      }
    } catch (_) {}
  }
  return out;
}

/// Push / notification payload routing (FCM data + inbox metadata).
void openFromMarketingPushData(GoRouter router, Map<String, String> data) {
  final merged = _mergeMetadata(data);

  final deepLink = merged['deepLink']?.trim();
  if (deepLink != null && deepLink.isNotEmpty) {
    openYjeekDeepLink(router, deepLink);
    return;
  }

  final kind = (merged['kind'] ?? '').toLowerCase();
  final trigger = (merged['trigger'] ?? '').toLowerCase();

  if (kind == 'rider_chat') {
    final orderId = merged['orderId']?.trim();
    if (orderId != null && orderId.isNotEmpty) {
      router.push(OrderFlowRoutes.chatFor(orderId));
      return;
    }
  }

  if (kind == 'order_tracking') {
    final orderId = merged['orderId']?.trim();
    if (orderId != null && orderId.isNotEmpty) {
      final eta = merged['etaWindow']?.trim();
      if (eta != null && eta.isNotEmpty) {
        router.push(
          '${OrderFlowRoutes.statusFor(orderId)}&etaWindow=${Uri.encodeComponent(eta)}',
        );
      } else {
        router.push(OrderFlowRoutes.statusFor(orderId));
      }
      return;
    }
  }

  if (kind == 'cart_abandon') {
    router.go('${RouteNames.home}?tab=2');
    return;
  }

  if (kind == 'win_back_inactive_14d') {
    router.push(RouteNames.marketingOffers);
    return;
  }

  if (kind == 'birthday') {
    final voucherId = merged['voucherId']?.trim();
    if (voucherId != null && voucherId.isNotEmpty) {
      router.push('${RouteNames.voucherDetail}?id=$voucherId');
      return;
    }
    router.push(RouteNames.rewards);
    return;
  }

  if (kind.startsWith('voucher_expiry_reminder')) {
    final voucherId = merged['voucherId']?.trim();
    if (voucherId != null && voucherId.isNotEmpty) {
      router.push('${RouteNames.voucherDetail}?id=$voucherId');
      return;
    }
    router.push(RouteNames.vouchers);
    return;
  }

  if (kind.startsWith('cashback_expiry_reminder') ||
      kind.startsWith('referral_expiry_reminder')) {
    router.push(RouteNames.rewards);
    return;
  }

  if (trigger == 'cashback_credited' || trigger == 'referral_rewarded') {
    router.push(RouteNames.rewards);
    return;
  }

  final type = (merged['type'] ?? merged['screen'] ?? '').toUpperCase();
  if (type == 'GEOFENCE_OFFER' || merged['screen']?.toLowerCase() == 'geofence_offer') {
    return; // handled by caller with geofence route
  }
  if (type == 'PROMO' || type == 'OFFERS') {
    router.push(RouteNames.marketingOffers);
    return;
  }

  final orderId = merged['orderId']?.trim();
  if (orderId != null && orderId.isNotEmpty && kind.isEmpty && trigger.isEmpty) {
    router.push('${RouteNames.orderDetails}?id=$orderId');
    return;
  }
  router.push(RouteNames.notifications);
}
