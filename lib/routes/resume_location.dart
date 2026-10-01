import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Path plus query, without a host. This is what [GoRouter.go] expects.
String resumeLocationFromUri(Uri uri) {
  final path = uri.path.isEmpty ? '/' : uri.path;
  final query = uri.query;
  return query.isEmpty ? path : '$path?$query';
}

/// Splash, welcome, and login are launch screens. Saving them would send the
/// customer back through startup instead of the page they were using.
bool isResumableLocation(String location) {
  final path = Uri.parse(location).path;
  if (path.isEmpty || path == RouteNames.splash) return false;
  if (path == RouteNames.welcome) return false;
  if (path == RouteNames.phoneLogin) return false;
  if (path == RouteNames.otpVerify) return false;
  return path.startsWith('/');
}

/// Writes the current route whenever navigation changes.
class ResumeLocationBinder extends ConsumerStatefulWidget {
  const ResumeLocationBinder({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<ResumeLocationBinder> createState() =>
      _ResumeLocationBinderState();
}

class _ResumeLocationBinderState extends ConsumerState<ResumeLocationBinder> {
  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_persist);
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_persist);
    super.dispose();
  }

  void _persist() {
    final location = resumeLocationFromUri(widget.router.state.uri);
    if (!isResumableLocation(location)) return;
    unawaited(
      ref.read(storageServiceProvider).setResumeLocation(location),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
