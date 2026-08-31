import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Returns `true` when the user already has a session.
/// Otherwise navigates to phone login and returns `false`.
Future<bool> requireLogin(BuildContext context, WidgetRef ref) async {
  if (ref.read(storageServiceProvider).hasSession) return true;
  if (!context.mounted) return false;
  await context.push(RouteNames.phoneLogin);
  return false;
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
