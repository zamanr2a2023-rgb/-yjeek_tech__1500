import 'package:yjeek_app/core/constants/api_constants.dart';

String? _coerceMediaString(Object? raw) {
  if (raw == null) return null;
  if (raw is String) return raw.trim();
  if (raw is Map) {
    for (final key in const ['url', 'imageUrl', 'src', 'href']) {
      final nested = raw[key];
      if (nested is String && nested.trim().isNotEmpty) {
        return nested.trim();
      }
    }
  }
  final text = raw.toString().trim();
  return text.isEmpty ? null : text;
}

/// Normalizes admin/API media paths to a loadable absolute URL.
String? resolveApiMediaUrl(Object? raw) {
  var value = _coerceMediaString(raw);
  if (value == null || value.isEmpty) return null;

  if ((value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))) {
    value = value.substring(1, value.length - 1).trim();
  }
  if (value.startsWith('//')) {
    value = 'https:$value';
  }
  if (value.startsWith('http://') || value.startsWith('https://')) {
    final absolute = Uri.tryParse(value)?.toString() ?? value;
    return _flutterDecodableImageUrl(absolute);
  }
  if (value.startsWith('/')) {
    final api = Uri.parse(ApiConstants.baseUrl);
    final origin = Uri(
      scheme: api.scheme,
      host: api.host,
      port: api.hasPort ? api.port : null,
    );
    return origin.replace(path: value).toString();
  }
  return value;
}

String? resolveApiMediaUrlFromList(Object? raw) {
  if (raw is! List || raw.isEmpty) return null;
  for (final item in raw) {
    final resolved = resolveApiMediaUrl(item);
    if (resolved != null) return resolved;
  }
  return null;
}

/// Primary product image from vendor menu / product detail payloads.
String? resolveProductImageUrl(Map<String, dynamic> json) {
  return resolveApiMediaUrl(json['imageUrl']) ??
      resolveApiMediaUrlFromList(json['imageUrls']);
}

/// All product images for manual swipe gallery (deduped, order preserved).
List<String> resolveProductImageUrls(Map<String, dynamic> json) {
  final seen = <String>{};
  final urls = <String>[];

  void add(Object? raw) {
    final resolved = resolveApiMediaUrl(raw);
    if (resolved == null || resolved.isEmpty) return;
    if (seen.add(resolved)) urls.add(resolved);
  }

  add(json['imageUrl']);
  final list = json['imageUrls'];
  if (list is List) {
    for (final item in list) {
      add(item);
    }
  }
  return urls;
}

/// Flutter cannot decode AVIF on all Android/iOS builds. Webflow CDN serves the
/// same asset as JPEG when `.avif` in the path is replaced with `.jpg`.
String _flutterDecodableImageUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return url;
  final path = uri.path;
  if (!path.toLowerCase().endsWith('.avif')) return url;
  final jpgPath = '${path.substring(0, path.length - 5)}.jpg';
  return uri.replace(path: jpgPath).toString();
}
