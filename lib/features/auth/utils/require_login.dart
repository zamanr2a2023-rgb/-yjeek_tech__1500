import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/cart/model/delivery_range.dart';
import 'package:yjeek_app/features/cart/model/pending_add_to_cart.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Current GoRouter location (path + query) for post-login restore.
String currentReturnPath(BuildContext context) {
  final uri = GoRouterState.of(context).uri;
  final q = uri.query;
  return q.isEmpty ? uri.path : '${uri.path}?$q';
}

/// Returns `true` when the user already has a session.
///
/// Otherwise navigates to phone login. After the login route pops (or is
/// replaced by OTP → post-login navigation), returns whether a session exists.
Future<bool> requireLogin(
  BuildContext context,
  WidgetRef ref, {
  String? returnPath,
}) async {
  if (ref.read(storageServiceProvider).hasSession) return true;
  if (!context.mounted) return false;

  final path = (returnPath ?? currentReturnPath(context)).trim();
  if (path.isNotEmpty) {
    ref.read(postLoginReturnPathProvider.notifier).state = path;
  }

  await context.push(RouteNames.phoneLogin);
  if (!context.mounted) {
    return ref.read(storageServiceProvider).hasSession;
  }

  final loggedIn = ref.read(storageServiceProvider).hasSession;
  if (!loggedIn) {
    // User cancelled login — drop resume path so a later cold login goes home.
    clearPostLoginReturnPath(ref);
    final pending = ref.read(pendingAddToCartProvider);
    if (pending?.returnPath != null) {
      clearPendingAddToCart(ref);
    }
  }
  return loggedIn;
}

/// True when an API error is an auth/guest failure (should open login, not snackbar).
bool isAuthRequiredMessage(String? message) {
  final m = (message ?? '').toLowerCase();
  if (m.isEmpty) return false;
  return m.contains('authorization') ||
      m.contains('unauthorized') ||
      m.contains('unauthenticated') ||
      m.contains('not authenticated') ||
      m.contains('authentication required') ||
      m.contains('please log in') ||
      m.contains('please login') ||
      m.contains('invalid token') ||
      m.contains('jwt');
}

/// If [message] is an auth error, open login and return `true` (caller should stop).
Future<bool> redirectToLoginIfAuthError(
  BuildContext context,
  WidgetRef ref,
  String? message,
) async {
  if (!isAuthRequiredMessage(message)) return false;
  await requireLogin(context, ref);
  return true;
}

/// After OTP / social login: restore the prior browse page and retry pending add,
/// or fall back to home when login was not gated from add-to-cart.
Future<void> navigateAfterLogin(BuildContext context, WidgetRef ref) async {
  final pending = ref.read(pendingAddToCartProvider);
  final resume =
      (ref.read(postLoginReturnPathProvider) ?? pending?.returnPath)?.trim();
  clearPostLoginReturnPath(ref);

  if (resume != null && resume.isNotEmpty) {
    context.go(resume);
    if (pending == null) return;
    // Vape requires age verification on the restored screen before add.
    if (pending.vertical == PendingCartVertical.vape) return;

    final result = await retryPendingAddToCart(ref);
    if (!context.mounted) return;

    if (result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added to cart'),
          duration: Duration(seconds: 1),
        ),
      );
      if (pending.vertical == PendingCartVertical.services) {
        context.push(ServicesBookingRoutes.booking);
      }
      return;
    }

    if (result.outOfRange) {
      await pushOutOfDelivery(context);
      return;
    }

    if (result.message != null && result.message!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
    }
    return;
  }

  context.goHome();
}
