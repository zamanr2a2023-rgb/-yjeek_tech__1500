import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/routes/resume_location.dart';
import 'package:yjeek_app/routes/route_names.dart';

/// Holds the customer on an unpaid (non-COD) payment page.
///
/// Pay, cancel, and payment-timer expiry are the only ways off that page.
class PaymentPageLock extends ChangeNotifier {
  PaymentPageLock._();

  static final PaymentPageLock instance = PaymentPageLock._();

  String? _location;

  String? get location => _location;

  bool get isLocked => _location != null;

  void engage(String location) {
    if (_location == location) return;
    _location = location;
    notifyListeners();
  }

  void release() {
    if (_location == null) return;
    _location = null;
    notifyListeners();
  }

  /// True when [location] is the locked payment route.
  bool allows(String location) {
    final locked = _location;
    if (locked == null) return true;
    return locked == location;
  }
}

void engagePaymentPageLock(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    PaymentPageLock.instance.engage(
      resumeLocationFromUri(GoRouterState.of(context).uri),
    );
  });
}

void leaveLockedPayment(BuildContext context, String location) {
  PaymentPageLock.instance.release();
  if (!context.mounted) return;
  context.pushReplacement(location);
}

void leaveLockedPaymentToOrders(BuildContext context) {
  PaymentPageLock.instance.release();
  if (!context.mounted) return;
  context.go('${RouteNames.home}?tab=1');
}

Future<bool> cancelLockedPaymentOrders(
  WidgetRef ref,
  List<String> orderIds,
) async {
  final repo = ref.read(ordersRepositoryProvider);
  for (final id in orderIds) {
    if (id.isEmpty) continue;
    final ok = await repo.cancel(id, reason: 'Cancelled during payment');
    if (!ok) return false;
  }
  return true;
}
