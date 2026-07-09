import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/routes/route_names.dart';

abstract final class HelpRoutes {
  static String orderHelp({
    String? orderId,
    int tab = 0,
  }) {
    final id = orderId ?? HelpData.defaultOrderId;
    final query = StringBuffer('orderId=$id');
    if (tab != 0) query.write('&tab=$tab');
    return '${RouteNames.orderHelp}?$query';
  }

  static String helpIssue({
    required HelpIssueType type,
    String? orderId,
    int tab = 0,
  }) {
    final id = orderId ?? HelpData.defaultOrderId;
    final query = StringBuffer('type=${type.routeValue}&orderId=$id');
    if (tab != 0) query.write('&tab=$tab');
    return '${RouteNames.helpIssue}?$query';
  }
}
