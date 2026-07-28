import 'package:url_launcher/url_launcher.dart';

/// Opens the device dialer with [phone] (`tel:`), falling back to false on failure.
Future<bool> launchPhoneCall(String? phone) async {
  if (phone == null) return false;
  final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (digits.isEmpty) return false;
  final uri = Uri(scheme: 'tel', path: digits);
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri);
}
