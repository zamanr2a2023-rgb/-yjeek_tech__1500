import 'package:flutter/material.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

class HelpOrder {
  const HelpOrder({
    required this.vendorName,
    required this.orderId,
    required this.shortId,
    required this.statusLabel,
    required this.itemCount,
    required this.totalBhd,
    required this.deliveredAt,
    required this.compactSubtitle,
  });

  final String vendorName;
  final String orderId;
  final String shortId;
  final String statusLabel;
  final int itemCount;
  final String totalBhd;
  final String deliveredAt;
  final String compactSubtitle;

  String get subtitle => compactSubtitle;
  String get detailSubtitle => '$orderId · $itemCount items · BHD $totalBhd';
}

class HelpOrderItem {
  const HelpOrderItem({
    required this.label,
    required this.price,
    this.selected = false,
  });

  final String label;
  final String price;
  final bool selected;
}

enum HelpIssueType {
  trackOrder,
  orderLate,
  damagedSpilled,
  wrongOrder,
  missingItems,
  notReceived,
  foodQuality,
  cancelOrder,
  champComplaint,
  paymentIssue,
  serviceNoShow,
  serviceQualityDispute,
  propertyDamage,
  dineInReservation,
  dineInBillQuality,
  pickUpNotReady,
  cashbackNotCredited,
  modifyRequest,
  cashOut,
}

extension HelpIssueTypeX on HelpIssueType {
  static HelpIssueType fromQuery(String? value) => switch (value) {
        'order_late' => HelpIssueType.orderLate,
        'damaged_spilled' => HelpIssueType.damagedSpilled,
        'wrong_order' => HelpIssueType.wrongOrder,
        'missing_items' => HelpIssueType.missingItems,
        'not_received' => HelpIssueType.notReceived,
        'food_quality' => HelpIssueType.foodQuality,
        'cancel_order' => HelpIssueType.cancelOrder,
        'champ_complaint' => HelpIssueType.champComplaint,
        'payment_issue' => HelpIssueType.paymentIssue,
        'service_no_show' => HelpIssueType.serviceNoShow,
        'service_quality' => HelpIssueType.serviceQualityDispute,
        'property_damage' => HelpIssueType.propertyDamage,
        'dine_in_reservation' => HelpIssueType.dineInReservation,
        'dine_in_bill' => HelpIssueType.dineInBillQuality,
        'pickup_not_ready' => HelpIssueType.pickUpNotReady,
        'cashback_not_credited' => HelpIssueType.cashbackNotCredited,
        'modify_request' => HelpIssueType.modifyRequest,
        'cash_out' => HelpIssueType.cashOut,
        'track_order' => HelpIssueType.trackOrder,
        _ => HelpIssueType.orderLate,
      };

  String get routeValue => switch (this) {
        HelpIssueType.orderLate => 'order_late',
        HelpIssueType.damagedSpilled => 'damaged_spilled',
        HelpIssueType.wrongOrder => 'wrong_order',
        HelpIssueType.missingItems => 'missing_items',
        HelpIssueType.notReceived => 'not_received',
        HelpIssueType.foodQuality => 'food_quality',
        HelpIssueType.cancelOrder => 'cancel_order',
        HelpIssueType.champComplaint => 'champ_complaint',
        HelpIssueType.paymentIssue => 'payment_issue',
        HelpIssueType.serviceNoShow => 'service_no_show',
        HelpIssueType.serviceQualityDispute => 'service_quality',
        HelpIssueType.propertyDamage => 'property_damage',
        HelpIssueType.dineInReservation => 'dine_in_reservation',
        HelpIssueType.dineInBillQuality => 'dine_in_bill',
        HelpIssueType.pickUpNotReady => 'pickup_not_ready',
        HelpIssueType.cashbackNotCredited => 'cashback_not_credited',
        HelpIssueType.modifyRequest => 'modify_request',
        HelpIssueType.cashOut => 'cash_out',
        HelpIssueType.trackOrder => 'track_order',
      };

  bool get hasDedicatedForm => switch (this) {
        HelpIssueType.trackOrder => false,
        _ => true,
      };
}

class HelpIssueOption {
  const HelpIssueOption({
    required this.type,
    required this.title,
    required this.icon,
    required this.image,
    required this.iconBg,
    required this.iconColor,
    this.showForScheduled = false,
    this.showForServices = false,
    this.showForDineIn = false,
    this.showForPickUp = false,
  
  });

  final HelpIssueType type;
  final String title;
  final IconData icon;
  final String image;
  final Color iconBg;
  final Color iconColor;
  final bool showForScheduled;
  final bool showForServices;
  final bool showForDineIn;
  final bool showForPickUp;
}


class HelpOrderContext {
  const HelpOrderContext({
    required this.order,
    required this.category,
    required this.isScheduled,
  });

  final HelpOrder order;
  final OrderCategoryFilter category;
  final bool isScheduled;
}

abstract final class HelpData {
  static const defaultOrderId = 'YJK-2026-00041';

  static HelpOrderContext contextForOrderId(String? orderId) {
    final id = orderId ?? defaultOrderId;
    final match = NavigationData.orders.where((item) => item.id == id);
    if (match.isEmpty) return defaultContext;
    return fromHistoryItem(match.first);
  }

  static HelpOrderContext get defaultContext =>
      fromHistoryItem(NavigationData.orders.first);

  static HelpOrderContext fromHistoryItem(OrderHistoryItem item) {
    final isScheduled = item.subtitle.toLowerCase().contains('scheduled');
    final shortId = '#YJK-…${item.id.split('-').last}';
    final statusLabel = item.badge ?? item.subtitle.split('·').first.trim();
    final itemCount = _itemCountFromSubtitle(item.subtitle);

    return HelpOrderContext(
      category: item.category,
      isScheduled: isScheduled,
      order: HelpOrder(
        vendorName: item.vendor,
        orderId: '#${item.id}',
        shortId: shortId,
        statusLabel: statusLabel,
        itemCount: itemCount,
        totalBhd: item.price.replaceFirst('BHD ', ''),
        deliveredAt: _deliveredLabel(item),
        compactSubtitle: _compactSubtitle(item, shortId),
      ),
    );
  }

  static String _compactSubtitle(OrderHistoryItem item, String shortId) {
    if (item.id == defaultOrderId) {
      return '$shortId · Delivered today 13:48';
    }
    if (item.badge != null) {
      final parts = item.subtitle.split('·').map((part) => part.trim()).toList();
      if (parts.length >= 2) {
        return '$shortId · ${item.badge} · ${parts[1]}';
      }
      return '$shortId · ${item.badge}';
    }
    return '$shortId · ${item.subtitle}';
  }

  static int _itemCountFromSubtitle(String subtitle) {
    final match = RegExp(r'(\d+)\s*items?', caseSensitive: false).firstMatch(subtitle);
    return int.tryParse(match?.group(1) ?? '') ?? 1;
  }

  static String _deliveredLabel(OrderHistoryItem item) {
    if (item.badge != null && item.badge!.toLowerCase().contains('deliver')) {
      return item.subtitle.contains('·')
          ? item.subtitle.split('·').last.trim()
          : item.badge!;
    }
    if (item.badge != null) return '${item.badge} · ${item.subtitle.split('·').last.trim()}';
    return item.subtitle;
  }

  static const sampleOrder = HelpOrder(
    vendorName: 'The Green Kitchen',
    orderId: '#YJK-2026-00041',
    shortId: '#YJK-…41',
    statusLabel: 'Delivered today 13:48',
    itemCount: 3,
    totalBhd: '35.800',
    deliveredAt: 'Delivered · today 13:48',
    compactSubtitle: '#YJK-…41 · Delivered today 13:48',
  );

  static const reportWindowBanner =
      'Report window open · 24 min left (30 min post-delivery)';

  static const popularTopics = [
    'How do I request a refund?',
    'How do I withdraw my Wallet balance?',
    'What if my order is delayed?',
    'What payment methods are accepted?',
  ];

  static const orderItems = [
    HelpOrderItem(label: '1× Gourmet Mezze Platter', price: 'BHD 28.000'),
    HelpOrderItem(label: '1× Lamb Ouzi', price: 'BHD 5.000', selected: true),
    HelpOrderItem(label: '1× Fresh Juice — Large', price: 'BHD 2.000'),
  ];

  static const foodQualityOptions = [
    'Cold',
    'Undercooked',
    'Stale',
    'Too salty',
    'Portion size',
    'Wrong taste',
  ];

  static const cancelReasons = [
    'Ordered by mistake',
    'Changed my mind',
    'Wrong address',
    'Taking too long',
    'Other',
  ];

  static const orderHelpOptions = [
    HelpIssueOption(
      type: HelpIssueType.trackOrder,
      title: 'Track this order',
      image: 'assets/Frame (12).png',
      icon: Icons.local_shipping_outlined,
      iconBg: Color(0xFFEAF3DE),
      iconColor: Color(0xFF2E7D32),
    ),
    HelpIssueOption(
      type: HelpIssueType.orderLate,
      title: 'Order is late',
      icon: Icons.schedule,
          image: 'assets/watch.png',
      iconBg: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
    ),
    HelpIssueOption(
      type: HelpIssueType.damagedSpilled,
      title: 'Damaged or spilled',
      icon: Icons.broken_image_outlined,
          image: 'assets/Frame (60).png',
      iconBg: Color(0xFFFBEAEC),
      iconColor: Color(0xFFC0392B),
    ),
    HelpIssueOption(
      type: HelpIssueType.wrongOrder,
      title: 'Wrong order',
      icon: Icons.swap_horiz,
          image: 'assets/Frame (41).png',
      iconBg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
    ),
    HelpIssueOption(
      type: HelpIssueType.missingItems,
      title: 'Missing items',
      icon: Icons.inventory_2_outlined,
          image: 'assets/Frame (40).png',
      iconBg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
    ),
    HelpIssueOption(
      type: HelpIssueType.notReceived,
      title: 'Order not received',
      icon: Icons.location_on_outlined,
          image: 'assets/Frame (57).png',
      iconBg: Color(0xFFEAF1F8),
      iconColor: Color(0xFF2A6FB0),
    ),
    HelpIssueOption(
      type: HelpIssueType.foodQuality,
      title: 'Food quality',
      icon: Icons.restaurant_outlined,
          image: 'assets/Frame (56).png',
      iconBg: Color(0xFFEAF3DE),
      iconColor: Color(0xFF2E7D32),
    ),
    HelpIssueOption(
      type: HelpIssueType.cancelOrder,
      title: 'Cancel order',
      icon: Icons.cancel_outlined,
          image: 'assets/Frame (37).png',
      iconBg: Color(0xFFFBEAEC),
      iconColor: Color(0xFFC0392B),
    ),
    HelpIssueOption(
      type: HelpIssueType.champComplaint,
      title: 'Champ Behavior Complaint',
      icon: Icons.person_outline,
          image: 'assets/Frame (54).png',
      iconBg: Color(0xFFEDE7F6),
      iconColor: Color(0xFF6A3AA0),
    ),
    HelpIssueOption(
      type: HelpIssueType.paymentIssue,
      title: 'Payment Issue',
      icon: Icons.credit_card_outlined,
          image: 'assets/Frame (53).png',
      iconBg: Color(0xFFE9F0FA),
      iconColor: Color(0xFF1565C0),
    ),
    HelpIssueOption(
      type: HelpIssueType.serviceNoShow,
      title: 'Service Provider No-Show',
      icon: Icons.event_busy_outlined,
          image: 'assets/Frame (52).png',
      iconBg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
      showForServices: true,
    ),
    HelpIssueOption(
      type: HelpIssueType.serviceQualityDispute,
      title: 'Service Quality Dispute',
      icon: Icons.build_outlined,
          image: 'assets/Frame (51).png',
      iconBg: Color(0xFFEAF1F8),
      iconColor: Color(0xFF2A6FB0),
      showForServices: true,
    ),
    HelpIssueOption(
      type: HelpIssueType.propertyDamage,
      title: 'Property Damage During Service',
      icon: Icons.home_outlined,
          image: 'assets/Frame (32).png',
      iconBg: Color(0xFFFBEAEC),
      iconColor: Color(0xFFC62828),
      showForServices: true,
    ),
    HelpIssueOption(
      type: HelpIssueType.dineInReservation,
      title: 'Dine-In Reservation Not Honored',
      icon: Icons.table_restaurant_outlined,
          image: 'assets/Frame (30).png',
      iconBg: Color(0xFFFBEAEC),
      iconColor: Color(0xFFC62828),
      showForDineIn: true,
    ),
    HelpIssueOption(
      type: HelpIssueType.dineInBillQuality,
      title: 'Dine-In Bill or Food Quality',
      icon: Icons.receipt_long_outlined,
          image: 'assets/Frame (29).png',
      iconBg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
      showForDineIn: true,
    ),
    HelpIssueOption(
      type: HelpIssueType.pickUpNotReady,
      title: 'Pick-Up Order Not Ready',
      icon: Icons.shopping_bag_outlined,
          image: 'assets/Frame (46).png',
      iconBg: Color(0xFFEAF3DE),
      iconColor: Color(0xFF2E7D32),
      showForPickUp: true,
    ),
    HelpIssueOption(
      type: HelpIssueType.cashbackNotCredited,
      title: 'Cashback Not Credited',
      icon: Icons.account_balance_wallet_outlined,
          image: 'assets/Frame (45).png',
      iconBg: Color(0xFFEAF3DE),
      iconColor: Color(0xFF2E7D32),
    ),
    HelpIssueOption(
      type: HelpIssueType.modifyRequest,
      title: 'Modify Request',
      icon: Icons.edit_calendar_outlined,
          image: 'assets/Frame (44).png',
      iconBg: Color(0xFFEAF1F8),
      iconColor: Color(0xFF2A6FB0),
      showForScheduled: true,
    ),
    HelpIssueOption(
      type: HelpIssueType.cashOut,
      title: 'Wallet Cash-Out Issue',
      icon: Icons.account_balance_outlined,
      image: 'assets/Frame (26).png',
      iconBg: Color(0xFFEAF1F8),
      iconColor: Color(0xFF2A6FB0),
    ),
  ];

  static List<HelpIssueOption> visibleOrderHelpOptionsFor(HelpOrderContext context) {
    return orderHelpOptions.where((option) {
      if (option.showForScheduled && !context.isScheduled) return false;
      if (option.showForServices &&
          context.category != OrderCategoryFilter.services) {
        return false;
      }
      if (option.showForDineIn && context.category != OrderCategoryFilter.dineIn) {
        return false;
      }
      if (option.showForPickUp && context.category != OrderCategoryFilter.pickup) {
        return false;
      }
      return true;
    }).toList();
  }
}
