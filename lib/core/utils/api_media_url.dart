import 'package:yjeek_app/core/constants/api_constants.dart';

/// Normalizes admin/API media paths to a loadable absolute URL.
String? resolveApiMediaUrl(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
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
    final resolved = resolveApiMediaUrl(item?.toString());
    if (resolved != null) return resolved;
  }
  return null;
}
