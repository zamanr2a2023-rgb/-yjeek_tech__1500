import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/browse/model/services_data.dart';
import 'package:yjeek_app/features/browse/model/services_vendors_repository.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

void main() {
  test('booking slots keep duration, modes, call-out, and empty reason', () {
    final page = serviceBookingAvailabilityFromJson({
      'reason': 'BLOCKED_DATE',
      'durationMin': 180,
      'coveredAreas': [
        {'key': 'seef', 'label': 'Seef', 'callOutFee': 0},
        {'key': 'juffair', 'label': 'Juffair', 'callOutFee': 2},
      ],
      'slots': [
        {
          'id': 'slot-1',
          'startAt': '2026-09-28T03:00:00.000Z',
          'endAt': '2026-09-28T06:00:00.000Z',
          'label': '9:00',
          'available': true,
          'remainingCapacity': 2,
          'durationMin': 180,
          'fulfillmentModes': ['AT_HOME'],
        },
      ],
    });

    expect(page.reason, 'BLOCKED_DATE');
    expect(page.durationMin, 180);
    expect(page.coveredAreas, hasLength(2));
    expect(page.slots.single.endAt, isNotNull);
    expect(page.slots.single.remainingCapacity, 2);
    expect(page.slots.single.durationMin, 180);
    expect(page.slots.single.fulfillmentModes, ['AT_HOME']);
    expect(page.slots.single.coveredAreas.singleWhere((a) => a.key == 'juffair').callOutFee, 2);

    final blocked = serviceBookingAvailabilityFromJson({
      'reason': 'OUTSIDE_BOOKING_WINDOW',
      'slots': [],
    });
    expect(blocked.slots, isEmpty);
    expect(blocked.reason, 'OUTSIDE_BOOKING_WINDOW');
  });

  test('duration is prep time plus option duration changes', () {
    final cleaning = serviceLineDuration(
      const {'options': <String, dynamic>{}},
      const {'prepTimeMin': 180},
      1,
    );
    expect(cleaning.minutes, 180);
    expect(cleaning.label, '180 min');

    final withOption = serviceLineDuration(
      {
        'options': {
          'optionIds': ['long'],
        },
      },
      {
        'prepTimeMin': 60,
        'optionGroups': [
          {
            'options': [
              {'id': 'short', 'durationDelta': 0},
              {'id': 'long', 'durationDelta': 30},
            ],
          },
        ],
      },
      1,
    );
    expect(withOption.minutes, 90);

    final cartMinutes = serviceCartDurationMin([
      CartLineItem(
        id: '1',
        productId: 'p',
        name: 'Clean',
        subtitle: '',
        quantity: 1,
        unitPriceLabel: '15.000',
        durationMinutes: cleaning.minutes,
      ),
    ]);
    expect(cartMinutes, 180);

    final menu = serviceMenuItemFromProductJson(
      {'id': 'clean', 'name': 'Home clean', 'price': 15, 'prepTimeMin': 180},
      section: 'Cleaning',
    );
    expect(menu?.duration, '180 min');
    expect(menu?.durationMinutes, 180);
    final unnamed = serviceMenuItemFromProductJson(
      {'id': 'x', 'name': 'Visit', 'price': 1},
      section: 'Cleaning',
    );
    expect(unnamed?.duration, '');
    expect(unnamed?.duration, isNot('45 min'));
  });

  test('fulfillment modes come from the slot payload', () {
    expect(serviceModeAllowed({'AT_HOME'}, 'AT_HOME'), isTrue);
    expect(serviceModeAllowed({'AT_HOME'}, 'IN_SALON'), isFalse);
    expect(serviceModeAllowed({'IN_SALON', 'AT_HOME'}, 'IN_SALON'), isTrue);
    expect(serviceModeAllowed(const {}, 'IN_SALON'), isTrue);

    final provider = serviceProviderFromVendorJson({
      'id': 'glow',
      'name': 'Glow',
      'fulfillmentModes': ['IN_SALON'],
      'supportsDelivery': true,
      'supportsPickup': false,
    });
    expect(provider?.atVenue, isTrue);
    expect(provider?.atHome, isFalse);
  });

  test('checkout payload sends schedule, home address, and selected staff', () {
    final at = DateTime.utc(2026, 9, 28, 3);
    final salon = serviceCheckoutExtras(
      serviceFulfillmentMode: 'IN_SALON',
      scheduledAt: at,
      addressId: 'addr-1',
      serviceDurationMin: 60,
    );
    expect(salon['orderType'], 'SERVICE');
    expect(salon['serviceFulfillmentMode'], 'IN_SALON');
    expect(salon['scheduledAt'], at.toUtc().toIso8601String());
    expect(salon.containsKey('addressId'), isFalse);
    expect(salon.containsKey('serviceStaffId'), isFalse);
    expect(salon['serviceDurationMin'], 60);

    final home = serviceCheckoutExtras(
      serviceFulfillmentMode: 'AT_HOME',
      scheduledAt: at,
      addressId: 'addr-1',
      serviceStaffId: 'staff-sara',
      serviceDurationMin: 180,
    );
    expect(home['addressId'], 'addr-1');
    expect(home['serviceStaffId'], 'staff-sara');
    expect(home['serviceDurationMin'], 180);
    expect(home.containsKey('serviceDurationMin'), isTrue);
    expect(home['serviceDurationMin'], isNot(45));
  });

  test('call-out fee is added to the existing bill from the matched area', () {
    const areas = [
      ServiceCoveredArea(key: 'seef', label: 'Seef', callOutFee: 0),
      ServiceCoveredArea(key: 'juffair', label: 'Juffair', callOutFee: 2),
    ];
    expect(
      matchedCallOutFee(areas: areas, area: 'Juffair', city: 'Manama'),
      2,
    );
    expect(
      matchedCallOutFee(areas: areas, area: 'Seef', city: 'Manama'),
      isNull,
    );

    final lines = applyServiceCallOutFee(
      const [
        BillLine(label: 'Subtotal', value: 'BHD 15.000'),
        BillLine(label: 'Order total', value: 'BHD 16.500', isBold: true),
      ],
      2,
    );
    expect(lines[1].label, 'Delivery fee');
    expect(lines[1].value, 'BHD 2.000');
    expect(lines.last.value, 'BHD 18.500');

    final alreadyCharged = applyServiceCallOutFee(lines, 2, summaryDeliveryFee: 2);
    expect(alreadyCharged, lines);
  });

  test('providers with nextAvailableAt sort by that time', () {
    final later = _provider('later', DateTime.utc(2026, 9, 28, 12), rating: 5);
    final sooner = _provider('sooner', DateTime.utc(2026, 9, 28, 6), rating: 3);
    final unknown = _provider('unknown', null, openStatus: 'OPEN', rating: 5);
    final sorted = [later, unknown, sooner]..sort(compareServiceProviders);
    expect(sorted.map((p) => p.id).toList(), ['sooner', 'later', 'unknown']);
  });
}

ServiceProvider _provider(
  String id,
  DateTime? next, {
  double rating = 4,
  String openStatus = 'UNKNOWN',
}) {
  return ServiceProvider(
    id: id,
    name: id,
    category: 'Cleaning',
    categoryId: 'cleaning',
    rating: rating,
    reviewCount: 1,
    distance: '1 km',
    tags: 'Clean',
    priceFrom: '10',
    atVenue: true,
    atHome: true,
    gradientStart: const Color(0xFF15302B),
    gradientEnd: const Color(0xFF15302B),
    nextAvailableAt: next,
    openStatus: openStatus,
  );
}
