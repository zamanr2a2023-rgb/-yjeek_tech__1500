import 'package:yjeek_app/routes/route_names.dart';

abstract final class VapeCartRoutes {
  static const checkout = RouteNames.vapeCartCheckout;
  static const review = RouteNames.vapeCartReview;
  static const ageVerify = RouteNames.vapeCartAgeVerify;

  static String reviewWithDelivery(String methodId) => '$review?delivery=$methodId';
}
