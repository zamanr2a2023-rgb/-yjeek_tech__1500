import 'package:yjeek_app/routes/route_names.dart';

abstract final class ServicesOrderFlowRoutes {
  static const waiting = RouteNames.servicesOrderWaiting;
  static const pay = RouteNames.servicesOrderPay;
  static const confirmed = RouteNames.servicesOrderConfirmed;
  static const status = RouteNames.servicesOrderStatus;
  static const complete = RouteNames.servicesOrderComplete;
  static const receipt = RouteNames.servicesOrderReceipt;
}
