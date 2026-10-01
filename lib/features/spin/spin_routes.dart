import 'package:yjeek_app/routes/route_names.dart';

abstract final class SpinRoutes {
  static String wheel({required String campaignId}) =>
      '${RouteNames.spinWheel}?campaignId=${Uri.encodeQueryComponent(campaignId)}';
}
