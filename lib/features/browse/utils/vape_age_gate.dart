import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/vape_cart/vape_cart_routes.dart';

/// Returns true if the signed-in user has completed ID / age verification.
bool isVapeAgeVerified(WidgetRef ref) {
  final me = ref.watch(userMeProvider).valueOrNull;
  return me?.verification.status.toUpperCase() == 'VERIFIED';
}

/// Opens the Verify ID intro sheet (then CPR flow). Returns true if verified after.
Future<bool> openVapeAgeVerificationFlow(
  BuildContext context,
  WidgetRef ref, {
  String? productName,
}) async {
  if (!await requireLogin(context, ref)) return false;

  ref.invalidate(userMeProvider);
  try {
    await ref.read(userMeProvider.future);
  } catch (_) {}
  if (!context.mounted) return false;
  if (isVapeAgeVerified(ref)) return true;

  await context.push(
    VapeCartRoutes.ageVerifyFor(productName: productName),
  );
  if (!context.mounted) return false;

  ref.invalidate(userMeProvider);
  try {
    await ref.read(userMeProvider.future);
  } catch (_) {}
  if (!context.mounted) return false;
  return isVapeAgeVerified(ref);
}

/// Ensures login + age verification before vape add-to-cart.
Future<bool> ensureVapeAgeVerifiedForPurchase(
  BuildContext context,
  WidgetRef ref, {
  String? productName,
}) {
  return openVapeAgeVerificationFlow(
    context,
    ref,
    productName: productName,
  );
}
