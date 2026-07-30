import 'package:yjeek_app/routes/route_names.dart';

abstract final class PickupOrderFlowRoutes {
  static const waiting = RouteNames.pickupOrderWaiting;
  static const pay = RouteNames.pickupOrderPay;
  static const confirmed = RouteNames.pickupOrderConfirmed;
  static const status = RouteNames.pickupOrderStatus;
  static const receipt = RouteNames.pickupOrderReceipt;

  static String _withId(String path, String? orderId) {
    if (orderId == null || orderId.isEmpty) return path;
    return '$path?id=$orderId';
  }

  static String waitingFor(String? orderId) => _withId(waiting, orderId);
  static String payFor(String? orderId) => _withId(pay, orderId);
  static String confirmedFor(String? orderId) => _withId(confirmed, orderId);
  static String statusFor(String? orderId) => _withId(status, orderId);
  static String receiptFor(String? orderId) => _withId(receipt, orderId);
}
