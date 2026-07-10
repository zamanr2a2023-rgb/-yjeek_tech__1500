import 'package:yjeek_app/routes/route_names.dart';

abstract final class PickupOrderFlowRoutes {
  static const waiting = RouteNames.pickupOrderWaiting;
  static const pay = RouteNames.pickupOrderPay;
  static const confirmed = RouteNames.pickupOrderConfirmed;
  static const status = RouteNames.pickupOrderStatus;
  static const receipt = RouteNames.pickupOrderReceipt;
}
