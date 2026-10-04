import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/l10n/l10n.dart';

CartSnapshot _deliveryCart({
  CartPaymentEligibility? payment,
  String storeTypeSlug = 'food',
}) {
  return CartSnapshot(
    orderType: CartOrderType.delivery,
    vendorName: 'Green Kitchen',
    items: const [],
    billLines: const [],
    upsell: const [],
    upsellTitle: 'Combo',
    includeCutlery: false,
    totalLabel: 'BHD 1.000',
    cashbackLabel: '+ BHD 0.000',
    storeTypeSlug: storeTypeSlug,
    payment: payment,
  );
}

void main() {
  setUp(() => L10n.load('en'));

  test('allowsCashOnDelivery uses API payment block when present', () {
    final blocked = _deliveryCart(
      payment: const CartPaymentEligibility(
        acceptsCashOrders: false,
        cashOnDeliveryAvailable: false,
        cashOnDeliveryUnavailableReason:
            'This vendor is not accepting cash orders',
      ),
    );
    expect(allowsCashOnDelivery(blocked), isFalse);

    final allowed = _deliveryCart(
      payment: const CartPaymentEligibility(
        acceptsCashOrders: true,
        cashOnDeliveryAvailable: true,
      ),
    );
    expect(allowsCashOnDelivery(allowed), isTrue);
  });

  test('allowsCashOnDelivery falls back to store slug without payment block', () {
    expect(allowsCashOnDelivery(_deliveryCart()), isTrue);
    expect(
      allowsCashOnDelivery(_deliveryCart(storeTypeSlug: 'electronics')),
      isFalse,
    );
  });

  test('localizedCodUnavailableReason maps vendor-disabled copy', () {
    final cart = _deliveryCart(
      payment: const CartPaymentEligibility(
        acceptsCashOrders: false,
        cashOnDeliveryAvailable: false,
        cashOnDeliveryUnavailableReason:
            'This vendor is not accepting cash orders',
      ),
    );
    expect(
      localizedCodUnavailableReason(cart),
      'This vendor is not accepting cash orders',
    );
    expect(
      localizeCodServerMessage('This vendor is not accepting cash orders'),
      'This vendor is not accepting cash orders',
    );
  });

  test('CartPaymentEligibility.tryParse reads cart payment JSON', () {
    final parsed = CartPaymentEligibility.tryParse({
      'acceptsCashOrders': false,
      'cashOnDeliveryAvailable': false,
      'cashOnDeliveryUnavailableReason': 'This vendor is not accepting cash orders',
    });
    expect(parsed?.cashOnDeliveryAvailable, isFalse);
    expect(parsed?.acceptsCashOrders, isFalse);
  });
}
