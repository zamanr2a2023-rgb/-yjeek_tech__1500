import 'package:yjeek_app/routes/route_names.dart';

abstract final class ScheduledCartRoutes {
  static const checkout = RouteNames.scheduledCartCheckout;
  static const review = RouteNames.scheduledCartReview;

  static String checkoutWithDelivery(String methodId) => '$checkout?delivery=$methodId';

  static String reviewWithDelivery(String methodId) => '$review?delivery=$methodId';
}
