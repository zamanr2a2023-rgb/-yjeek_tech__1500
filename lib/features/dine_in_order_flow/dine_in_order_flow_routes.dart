import 'package:yjeek_app/routes/route_names.dart';

abstract final class DineInOrderFlowRoutes {
  static const waiting = RouteNames.dineInOrderWaiting;
  static const pay = RouteNames.dineInOrderPay;
  static const confirmed = RouteNames.dineInOrderConfirmed;
  static const status = RouteNames.dineInOrderStatus;
  static const complete = RouteNames.dineInOrderComplete;
  static const receipt = RouteNames.dineInOrderReceipt;
}
