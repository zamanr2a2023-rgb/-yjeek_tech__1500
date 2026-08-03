import 'package:yjeek_app/routes/route_names.dart';

abstract final class ScheduledCartRoutes {
  static const checkout = RouteNames.scheduledCartCheckout;
  static const review = RouteNames.scheduledCartReview;

  static String checkoutWithDelivery(String methodId) =>
      '$checkout?delivery=$methodId';

  static String reviewWithDelivery(String methodId) =>
      '$review?delivery=$methodId';

  static String reviewFor({
    List<String>? orderIds,
    String? deliveryId,
  }) {
    final params = <String>[];
    if (orderIds != null && orderIds.isNotEmpty) {
      params.add('id=${orderIds.first}');
      if (orderIds.length > 1) {
        params.add('ids=${orderIds.join(',')}');
      }
    }
    if (deliveryId != null && deliveryId.isNotEmpty) {
      params.add('delivery=$deliveryId');
    }
    if (params.isEmpty) return review;
    return '$review?${params.join('&')}';
  }
}
