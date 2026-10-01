/// HTTP headers for remote images (menu items, covers, avatars).
///
/// Do not ask for AVIF — many CDNs (Webflow) prefer it, but Flutter cannot
/// decode AVIF on all Android builds, which shows as a broken image.
Map<String, String> networkImageHttpHeaders(String url) {
  final headers = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Accept':
        'image/webp,image/apng,image/png,image/jpeg,image/gif,image/*,*/*;q=0.8',
  };
  final lower = url.toLowerCase();
  if (lower.contains('website-files.com')) {
    headers['Referer'] = 'https://cdn.prod.website-files.com/';
  }
  return headers;
}
