import 'package:yjeek_app/routes/route_names.dart';

abstract final class ScheduledOrderFlowRoutes {
  static const waiting = RouteNames.scheduledOrderWaiting;
  static const pay = RouteNames.scheduledOrderPay;
  static const confirmed = RouteNames.scheduledOrderConfirmed;
  static const status = RouteNames.scheduledOrderStatus;
  static const receipt = RouteNames.scheduledOrderReceipt;
}
