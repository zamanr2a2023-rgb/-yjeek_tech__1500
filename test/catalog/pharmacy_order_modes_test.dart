import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/browse/model/pharmacy_order_modes.dart';

void main() {
  test('order modes use server fees and the outside banner', () {
    final modes = PharmacyOrderModes.fromJson({
      'dualMode': true,
      'customerInsideOnDemandRadius': false,
      'distanceKm': 12.4,
      'banner':
          "You are outside this pharmacy's instant delivery area, scheduled delivery only.",
      'deliverNow': {
        'enabled': false,
        'selected': false,
        'faded': true,
        'etaMin': 25,
        'deliveryFee': 0.5,
        'minOrderAmount': 3,
      },
      'scheduled': {
        'selected': true,
        'shippingFee': 1,
        'minOrderAmount': 5,
        'earliestSlotLabel': 'Tomorrow',
      },
    });

    expect(modes.deliverNow.enabled, isFalse);
    expect(modes.deliverNow.faded, isTrue);
    expect(modes.deliverNow.deliveryFee, 0.5);
    expect(modes.scheduled.shippingFee, 1);
    expect(modes.scheduled.minOrderAmount, 5);
    expect(modes.scheduled.earliestSlotLabel, 'Tomorrow');
    expect(modes.selectedMode, PharmacyDeliveryMode.scheduled);
    expect(modes.customerInsideOnDemandRadius, isFalse);
    expect(modes.banner, contains('scheduled delivery only'));
  });

  test('prescription price is hidden only for badge and zero price', () {
    expect(
      isPrescriptionWithoutPrice(
        badges: const ['PRESCRIPTION'],
        price: '0.000',
      ),
      isTrue,
    );
    expect(
      isPrescriptionWithoutPrice(
        badges: const ['PRESCRIPTION'],
        price: '1.500',
      ),
      isFalse,
    );
    expect(
      isPrescriptionWithoutPrice(
        badges: const [],
        price: '0.000',
      ),
      isFalse,
    );
  });
}
