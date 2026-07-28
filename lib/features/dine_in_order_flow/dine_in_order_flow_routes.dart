import 'package:yjeek_app/routes/route_names.dart';

abstract final class DineInOrderFlowRoutes {
  static const waiting = RouteNames.dineInOrderWaiting;
  static const pay = RouteNames.dineInOrderPay;
  static const confirmed = RouteNames.dineInOrderConfirmed;
  static const status = RouteNames.dineInOrderStatus;
  static const complete = RouteNames.dineInOrderComplete;
  static const receipt = RouteNames.dineInOrderReceipt;

  static String _withId(String path, String? orderId) {
    if (orderId == null || orderId.isEmpty) return path;
    return '$path?id=$orderId';
  }

  static String waitingFor(String? orderId) => _withId(waiting, orderId);
  static String payFor(String? orderId) => _withId(pay, orderId);
  static String confirmedFor(String? orderId) => _withId(confirmed, orderId);
  static String statusFor(String? orderId) => _withId(status, orderId);
  static String completeFor(String? orderId) => _withId(complete, orderId);
  static String receiptFor(String? orderId) => _withId(receipt, orderId);
}
