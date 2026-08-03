import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/routes/route_names.dart';

abstract final class HelpRoutes {
  static String helpSupport({
    String? orderId,
    int tab = 0,
  }) {
    final query = StringBuffer();
    if (orderId != null && orderId.isNotEmpty) {
      query.write('orderId=$orderId');
    }
    if (tab != 0) {
      if (query.isNotEmpty) query.write('&');
      query.write('tab=$tab');
    }
    if (query.isEmpty) return RouteNames.helpSupport;
    return '${RouteNames.helpSupport}?$query';
  }

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

  static String helpChat({
    HelpChatVariant variant = HelpChatVariant.support,
    String? ticketId,
    int tab = 0,
  }) {
    final query = StringBuffer('variant=${variant.routeValue}');
    if (ticketId != null && ticketId.isNotEmpty) {
      query.write('&ticketId=$ticketId');
    }
    if (tab != 0) query.write('&tab=$tab');
    return '${RouteNames.helpChat}?$query';
  }

  static String helpFaq({int tab = 0}) {
    if (tab == 0) return RouteNames.helpFaq;
    return '${RouteNames.helpFaq}?tab=$tab';
  }

  static String helpPoliciesLegal({int tab = 0}) {
    if (tab == 0) return RouteNames.helpPoliciesLegal;
    return '${RouteNames.helpPoliciesLegal}?tab=$tab';
  }

  static String helpFlow({
    HelpFlowType flow = HelpFlowType.scheduledCancelFree,
    String? orderId,
    int tab = 0,
  }) {
    final query = StringBuffer('flow=${flow.routeValue}');
    if (orderId != null && orderId.isNotEmpty) {
      query.write('&orderId=$orderId');
    }
    if (tab != 0) query.write('&tab=$tab');
    return '${RouteNames.helpFlow}?$query';
  }
}
