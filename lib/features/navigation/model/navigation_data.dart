import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';

enum OfferCategory { all, food, groceries, fashion }

enum OrderTimeFilter { all, active, past }

enum OrderCategoryFilter { all, orders, services, dineIn, pickup }

enum OrderStatus { delivered, upcoming, inProgress, active }

enum CartTab { orders, dineIn, pickup, services }

extension CartTabX on CartTab {
  int get index => CartTab.values.indexOf(this);

  static CartTab fromIndex(int index) =>
      CartTab.values[index.clamp(0, CartTab.values.length - 1)];

  String get label => switch (this) {
        CartTab.orders => 'Orders',
        CartTab.dineIn => 'Dine-in',
        CartTab.pickup => 'Pickup',
        CartTab.services => 'Services',
      };

  IconData get emptyIcon => switch (this) {
        CartTab.orders => Icons.shopping_cart_outlined,
        CartTab.dineIn => Icons.restaurant_outlined,
        CartTab.pickup => Icons.storefront_outlined,
        CartTab.services => Icons.home_repair_service_outlined,
      };
}

class BrowseOffer {
  const BrowseOffer({
    required this.name,
    required this.vendor,
    required this.price,
    required this.imageColor,
    required this.category,
    this.originalPrice,
    this.badge,
  });

  final String name;
  final String vendor;
  final String price;
  final String? originalPrice;
  final String? badge;
  final Color imageColor;
  final OfferCategory category;
}

class ComboItem {
  const ComboItem({
    required this.name,
    required this.price,
    required this.imageColor,
  });

  final String name;
  final String price;
  final Color imageColor;
}

class OrderHistoryItem {
  const OrderHistoryItem({
    required this.id,
    required this.vendor,
    required this.subtitle,
    required this.price,
    required this.status,
    required this.category,
    required this.isActive,
    required this.actions,
    this.badge,
    this.arrivalText,
  });

  final String id;
  final String vendor;
  final String subtitle;
  final String price;
  final OrderStatus status;
  final OrderCategoryFilter category;
  final bool isActive;
  final List<String> actions;
  final String? badge;
  final String? arrivalText;
}

class BillLine {
  const BillLine({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isDiscount;
  final bool isBold;
}

class OrderItemLine {
  const OrderItemLine({required this.name, required this.price});

  final String name;
  final String price;
}

abstract final class NavigationData {
  static const String userName = 'Asmaa';
  static const String userPhone = '+973 3300 0000';
  static const String walletBalance = 'BHD 12.450';
  static const String cashbackBalance = 'BHD 3.200';
  static const String orderId = '#YJK-2026-00041';
  static const String cartVendor = 'The Green Kitchen';
  static const String cartItemName = 'Iced Americano + Choc Muffin';
  static const String cartItemSubtitle = 'Americano · Chocolate muffin';
  static const String cartItemPrice = 'BHD 3.700';

  static const List<BrowseOffer> browseOffers = [
    BrowseOffer(
      name: 'Beef Burger Combo',
      vendor: 'The Green Kitchen',
      price: 'BHD 2.450',
      originalPrice: 'BHD 3.500',
      badge: '30% OFF',
      imageColor: Color(0xFFE3F2EB),
      category: OfferCategory.food,
    ),
    BrowseOffer(
      name: 'Family Feast Box',
      vendor: 'The Green Kitchen',
      price: 'BHD 6.000',
      originalPrice: 'BHD 12.000',
      badge: 'B1G1',
      imageColor: Color(0xFFFFF0D9),
      category: OfferCategory.food,
    ),
    BrowseOffer(
      name: 'Sushi Platter',
      vendor: 'VEERA',
      price: 'BHD 9.300',
      originalPrice: 'BHD 12.400',
      badge: 'SAVE 28%',
      imageColor: Color(0xFFE8F4FC),
      category: OfferCategory.food,
    ),
    BrowseOffer(
      name: 'Fresh Fruit Basket',
      vendor: 'Lulu Express',
      price: 'BHD 5.000',
      originalPrice: 'BHD 6.500',
      badge: '20% OFF',
      imageColor: Color(0xFFE3F5E8),
      category: OfferCategory.groceries,
    ),
    BrowseOffer(
      name: 'Cold Brew Bundle',
      vendor: 'Brew & Bean',
      price: 'BHD 1.800',
      originalPrice: 'BHD 2.500',
      badge: '30% OFF',
      imageColor: Color(0xFFF5EDE3),
      category: OfferCategory.food,
    ),
    BrowseOffer(
      name: 'Designer Handbag',
      vendor: '1002 Collection',
      price: 'BHD 9.500',
      originalPrice: 'BHD 19.000',
      badge: '50% OFF',
      imageColor: Color(0xFFE8E4F8),
      category: OfferCategory.fashion,
    ),
  ];

  static const List<ComboItem> comboItems = [
    ComboItem(
      name: 'Brownie Bite',
      price: 'BHD 0.500',
      imageColor: Color(0xFFF5E6D3),
    ),
    ComboItem(
      name: 'Choc Croissant',
      price: 'BHD 0.600',
      imageColor: Color(0xFFFFF0D9),
    ),
    ComboItem(
      name: 'Iced Latte',
      price: 'BHD 0.800',
      imageColor: Color(0xFFE8F4FC),
    ),
  ];

  static const List<BillLine> cartBillLines = [
    BillLine(label: 'Subtotal', value: 'BHD 3.700'),
    BillLine(label: 'Discount', value: '- BHD 1.700', isDiscount: true),
    BillLine(label: 'Free delivery', value: 'BHD 0.000'),
    BillLine(label: 'Service fee', value: 'BHD 0.110'),
    BillLine(label: 'Order total', value: 'BHD 2.110', isBold: true),
  ];

  static const List<OrderHistoryItem> orders = [
    OrderHistoryItem(
      id: 'YJK-2026-00041',
      vendor: 'The Green Kitchen',
      subtitle: 'On-demand · Today 14:20 · 3 items',
      price: 'BHD 6.610',
      status: OrderStatus.delivered,
      category: OrderCategoryFilter.orders,
      isActive: false,
      actions: [
        NavigationStrings.receipt,
        NavigationStrings.rate,
        NavigationStrings.getHelp,
      ],
      badge: 'Delivered',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00038',
      vendor: 'Lulu Express',
      subtitle: 'Scheduled · Yesterday 18:00 · 8 items',
      price: 'BHD 12.300',
      status: OrderStatus.delivered,
      category: OrderCategoryFilter.orders,
      isActive: false,
      actions: [
        NavigationStrings.receipt,
        NavigationStrings.rate,
        NavigationStrings.getHelp,
      ],
      badge: 'Delivered',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00035',
      vendor: 'The Green Kitchen',
      subtitle: 'Delivery · Today 12:05',
      price: 'BHD 15.210',
      status: OrderStatus.active,
      category: OrderCategoryFilter.orders,
      isActive: true,
      actions: [
        NavigationStrings.trackOrder,
        NavigationStrings.getHelp,
      ],
      badge: 'DELIVERY',
      arrivalText: 'Arriving in 18 min',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00030',
      vendor: 'Sharaf DG',
      subtitle: 'Electronics · Mon 10:30 · 1 item',
      price: 'BHD 154.300',
      status: OrderStatus.upcoming,
      category: OrderCategoryFilter.orders,
      isActive: true,
      actions: [
        NavigationStrings.trackOrder,
        NavigationStrings.getHelp,
      ],
      badge: 'Upcoming',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00061',
      vendor: 'Vapeology',
      subtitle: 'Vape delivery · Today · Mango Ice Disposable',
      price: 'BHD 6.610',
      status: OrderStatus.active,
      category: OrderCategoryFilter.services,
      isActive: true,
      actions: [
        NavigationStrings.trackOrder,
        NavigationStrings.getHelp,
      ],
      badge: 'DELIVERY',
      arrivalText: 'Arriving in 30–45 min',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00028',
      vendor: 'Glow Beauty Lounge',
      subtitle: 'Haircut & styling · Wed 14 · 1:00 PM',
      price: 'BHD 14.355',
      status: OrderStatus.delivered,
      category: OrderCategoryFilter.services,
      isActive: false,
      actions: [
        NavigationStrings.receipt,
        NavigationStrings.rate,
        NavigationStrings.getHelp,
      ],
      badge: 'Completed',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00027',
      vendor: 'Velvet Nails & Spa',
      subtitle: 'Manicure · Sat 17 · 3:00 PM',
      price: 'BHD 12.000',
      status: OrderStatus.upcoming,
      category: OrderCategoryFilter.services,
      isActive: true,
      actions: [
        NavigationStrings.trackOrder,
        NavigationStrings.getHelp,
      ],
      badge: 'Upcoming',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00025',
      vendor: 'VEERA',
      subtitle: 'Dine-in · Mon 12 · 19:30 · table for 2',
      price: 'BHD 20.500',
      status: OrderStatus.upcoming,
      category: OrderCategoryFilter.dineIn,
      isActive: true,
      actions: [
        NavigationStrings.trackOrder,
        NavigationStrings.getHelp,
      ],
      badge: 'Upcoming',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00022',
      vendor: 'Brew & Bean',
      subtitle: 'Pickup · Wed 09:15 · 2 items',
      price: 'BHD 5.675',
      status: OrderStatus.delivered,
      category: OrderCategoryFilter.pickup,
      isActive: false,
      actions: [
        NavigationStrings.receipt,
        NavigationStrings.rate,
        NavigationStrings.getHelp,
      ],
      badge: 'Delivered',
    ),
    OrderHistoryItem(
      id: 'YJK-2026-00020',
      vendor: 'Brew & Bean',
      subtitle: 'Pickup · Today · ready in ~8 min',
      price: 'BHD 4.900',
      status: OrderStatus.inProgress,
      category: OrderCategoryFilter.pickup,
      isActive: true,
      actions: [
        NavigationStrings.trackOrder,
        NavigationStrings.getHelp,
      ],
      badge: 'In progress',
    ),
  ];

  static const List<OrderItemLine> orderDetailItems = [
    OrderItemLine(name: 'Mixed Grill Platter ×1', price: 'BHD 3.500'),
    OrderItemLine(name: 'Hummus Beiruti ×1', price: 'BHD 1.200'),
    OrderItemLine(name: 'Fresh Orange Juice ×2', price: 'BHD 1.800'),
  ];

  static const List<BillLine> orderDetailBillSummary = [
    BillLine(label: 'Subtotal', value: 'BHD 6.500'),
    BillLine(label: 'Delivery', value: 'BHD 0.450'),
    BillLine(label: 'Service fee', value: 'BHD 0.110'),
    BillLine(label: 'Discount', value: '− BHD 0.450', isDiscount: true),
    BillLine(label: 'Total', value: 'BHD 6.610', isBold: true),
  ];
}
