import 'package:flutter/material.dart';

class ServiceCategoryItem {
  const ServiceCategoryItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.iconBackground,
  });

  final String id;
  final String name;
  final String emoji;
  final Color iconBackground;
}

class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.tags,
    required this.priceFrom,
    required this.atVenue,
    required this.atHome,
    required this.gradientStart,
    required this.gradientEnd,
    this.emoji = '💇‍♀',
    this.openHoursTitle = 'Open · 9–9',
    this.openHoursSubtitle = 'Today',
    this.bookingModeLabel = 'Walk-in / book',
  });

  final String id;
  final String name;
  final String category;
  final String categoryId;
  final double rating;
  final int reviewCount;
  final String distance;
  final String tags;
  final String priceFrom;
  final bool atVenue;
  final bool atHome;
  final Color gradientStart;
  final Color gradientEnd;
  final String emoji;
  final String openHoursTitle;
  final String openHoursSubtitle;
  final String bookingModeLabel;
}

class ServiceMenuItem {
  const ServiceMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.section,
    required this.duration,
  });

  final String id;
  final String name;
  final String description;
  final String price;
  final String section;
  final String duration;
}

class ServiceOption {
  const ServiceOption({
    required this.name,
    required this.subtitle,
    this.extraPrice,
    this.id,
  });

  final String? id;
  final String name;
  final String subtitle;
  final String? extraPrice;
}

class ServiceAddon {
  const ServiceAddon({
    required this.name,
    required this.price,
    this.id,
  });

  final String? id;
  final String name;
  final String price;
}

abstract final class ServicesData {
  static const String homeTitle = 'Services';
  static const String searchHint = 'Search services or providers…';
  static const String popularNearYou = 'Popular near you';
  static const String seeAll = 'See all';

  static const List<ServiceCategoryItem> categories = [
    ServiceCategoryItem(
      id: 'salon-beauty',
      name: 'Salon & Beauty',
      emoji: '✂',
      iconBackground: Color(0xFFE3F2EB),
    ),
    ServiceCategoryItem(
      id: 'spa-massage',
      name: 'Spa & Massage',
      emoji: '☯',
      iconBackground: Color(0xFFE6F0FF),
    ),
    ServiceCategoryItem(
      id: 'photoshoot',
      name: 'Photoshoot',
      emoji: '📷',
      iconBackground: Color(0xFFEDE3FA),
    ),
    ServiceCategoryItem(
      id: 'home-services',
      name: 'Home services',
      emoji: '🧹',
      iconBackground: Color(0xFFFFF0D9),
    ),
  ];

  static const venueFilters = ['All', 'At venue', 'At home'];

  static const List<ServiceProvider> popularProviders = [
    ServiceProvider(
      id: 'glow-beauty-lounge',
      name: 'Glow Beauty Lounge',
      category: 'Salon & Beauty',
      categoryId: 'salon-beauty',
      rating: 4.9,
      reviewCount: 320,
      distance: '1.2 km',
      tags: 'Haircut · Color · Bridal',
      priceFrom: '8',
      atVenue: true,
      atHome: true,
      gradientStart: Color(0xFFE3F2EB),
      gradientEnd: Color(0xFFDBE8DE),
    ),
    ServiceProvider(
      id: 'serenity-spa',
      name: 'Serenity Spa',
      category: 'Spa & Massage',
      categoryId: 'spa-massage',
      rating: 4.8,
      reviewCount: 210,
      distance: '2.1 km',
      tags: 'Massage · Facial · Hammam',
      priceFrom: '18',
      atVenue: true,
      atHome: false,
      gradientStart: Color(0xFFEDE3FA),
      gradientEnd: Color(0xFFE3D8F5),
      emoji: '☯',
    ),
  ];

  static const List<ServiceProvider> salonBeautyProviders = [
    ServiceProvider(
      id: 'glow-beauty-lounge',
      name: 'Glow Beauty Lounge',
      category: 'Salon & Beauty',
      categoryId: 'salon-beauty',
      rating: 4.9,
      reviewCount: 320,
      distance: '1.2 km',
      tags: 'Haircut · Color · Bridal',
      priceFrom: '8',
      atVenue: true,
      atHome: true,
      gradientStart: Color(0xFFE3F2EB),
      gradientEnd: Color(0xFFDBE8DE),
    ),
    ServiceProvider(
      id: 'velvet-nails-spa',
      name: 'Velvet Nails & Spa',
      category: 'Salon & Beauty',
      categoryId: 'salon-beauty',
      rating: 4.7,
      reviewCount: 180,
      distance: '2.0 km',
      tags: 'Manicure · Pedicure · Waxing',
      priceFrom: '10',
      atVenue: true,
      atHome: false,
      gradientStart: Color(0xFFFBE8F3),
      gradientEnd: Color(0xFFF5DCE8),
      emoji: '💅',
    ),
    ServiceProvider(
      id: 'lumiere-makeup',
      name: 'Lumière Makeup Studio',
      category: 'Salon & Beauty',
      categoryId: 'salon-beauty',
      rating: 4.8,
      reviewCount: 142,
      distance: '2.6 km',
      tags: 'Makeup · Bridal · Skincare',
      priceFrom: '15',
      atVenue: true,
      atHome: true,
      gradientStart: Color(0xFFFFF0D9),
      gradientEnd: Color(0xFFFFE8C8),
      emoji: '💄',
    ),
    ServiceProvider(
      id: 'adliya-hair-co',
      name: 'Adliya Hair Co.',
      category: 'Salon & Beauty',
      categoryId: 'salon-beauty',
      rating: 4.6,
      reviewCount: 140,
      distance: '0.8 km',
      tags: 'Haircut · Styling · Kids',
      priceFrom: '7',
      atVenue: true,
      atHome: false,
      gradientStart: Color(0xFFE3F2EB),
      gradientEnd: Color(0xFFDBE8DE),
    ),
  ];

  static const List<String> glowBeautySections = ['Hair', 'Nails', 'Makeup', 'Skincare'];

  static const List<ServiceMenuItem> glowBeautyMenu = [
    ServiceMenuItem(
      id: 'haircut-styling',
      name: 'Haircut & styling',
      description: 'Wash, cut & blow-dry · 45 min',
      price: '8.000',
      section: 'Hair',
      duration: '45 min',
    ),
    ServiceMenuItem(
      id: 'hair-color',
      name: 'Hair color',
      description: 'Full color & gloss · 90 min',
      price: '25.000',
      section: 'Hair',
      duration: '90 min',
    ),
    ServiceMenuItem(
      id: 'blow-dry-style',
      name: 'Blow dry & style',
      description: 'Wash & styling · 30 min',
      price: '6.000',
      section: 'Hair',
      duration: '30 min',
    ),
    ServiceMenuItem(
      id: 'gel-manicure',
      name: 'Gel manicure',
      description: 'Shape, cuticle care & gel · 45 min',
      price: '12.000',
      section: 'Nails',
      duration: '45 min',
    ),
    ServiceMenuItem(
      id: 'bridal-makeup',
      name: 'Bridal makeup',
      description: 'Trial & day-of look · 90 min',
      price: '45.000',
      section: 'Makeup',
      duration: '90 min',
    ),
    ServiceMenuItem(
      id: 'facial-glow',
      name: 'Glow facial',
      description: 'Deep cleanse & hydration · 60 min',
      price: '18.000',
      section: 'Skincare',
      duration: '60 min',
    ),
  ];

  static const String haircutDescription =
      'Wash, precision cut and blow-dry tailored to your hair type. Includes a quick consultation and finishing style.';

  static const List<ServiceOption> haircutOptions = [
    ServiceOption(name: 'Standard cut', subtitle: 'Included'),
    ServiceOption(name: 'With deep-conditioning', subtitle: '+ BHD 4.000', extraPrice: '4.000'),
  ];

  static const List<String> specialists = ['Any', 'Sara', 'Lina', 'Maya'];

  static const List<ServiceAddon> haircutAddons = [
    ServiceAddon(name: 'Scalp massage (10 min)', price: '2.000'),
    ServiceAddon(name: 'Hair treatment mask', price: '5.000'),
  ];

  static ServiceCategoryItem categoryById(String id) {
    return categories.firstWhere((c) => c.id == id, orElse: () => categories.first);
  }

  static ServiceProvider providerById(String id) {
    return salonBeautyProviders.firstWhere(
      (p) => p.id == id,
      orElse: () => salonBeautyProviders.first,
    );
  }

  static ServiceMenuItem menuItemById(String id) {
    return glowBeautyMenu.firstWhere(
      (item) => item.id == id,
      orElse: () => glowBeautyMenu.first,
    );
  }

  static List<ServiceProvider> providersForCategory(String categoryId, {String? venueFilter}) {
    var list = categoryId == 'salon-beauty'
        ? salonBeautyProviders
        : popularProviders.where((p) => p.categoryId == categoryId).toList();

    if (list.isEmpty) list = salonBeautyProviders;

    if (venueFilter == 'At venue') {
      list = list.where((p) => p.atVenue).toList();
    } else if (venueFilter == 'At home') {
      list = list.where((p) => p.atHome).toList();
    }
    return list;
  }
}
