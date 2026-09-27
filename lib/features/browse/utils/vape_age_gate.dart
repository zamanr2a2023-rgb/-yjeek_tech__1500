import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';

/// Purchase is allowed only when GET /users/me/age-verification says so.
Future<bool> customerCanPurchaseAgeRestricted(WidgetRef ref) async {
  ref.invalidate(ageVerificationStatusProvider);
  try {
    final status = await ref.read(ageVerificationStatusProvider.future);
    return status.canPurchaseAgeRestricted;
  } catch (_) {
    return false;
  }
}

/// Opens the age-verification sheet when the customer cannot purchase 18+ items.
/// Returns true only after the age API reports `canPurchaseAgeRestricted`.
Future<bool> openVapeAgeVerificationFlow(
  BuildContext context,
  WidgetRef ref, {
  String? productName,
}) async {
  if (!await requireLogin(context, ref)) return false;
  if (!context.mounted) return false;
  if (await customerCanPurchaseAgeRestricted(ref)) return true;
  if (!context.mounted) return false;

  await context.push(VapeCartRoutes.ageVerifyFor(productName: productName));
  if (!context.mounted) return false;
  return customerCanPurchaseAgeRestricted(ref);
}

/// Ensures login + age verification before a vape purchase.
Future<bool> ensureVapeAgeVerifiedForPurchase(
  BuildContext context,
  WidgetRef ref, {
  String? productName,
}) {
  return openVapeAgeVerificationFlow(context, ref, productName: productName);
}
