import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/model/checkout_helpers.dart';
import 'package:yjeek_app/features/catalog/model/catalog_cart_payload.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';

void main() {
  test('tip is added to the server grand total without another VAT', () {
    expect(payableWithTip(22.25, 0.3), 22.55);
    expect(payableWithTip(22.25, 0.3), isNot(22.25 * 1.1 + 0.3));
  });

  test('checkout bill uses server VAT and grand total once', () {
    const cart = CartSnapshot(
      orderType: CartOrderType.delivery,
      vendorName: 'Kitchen',
      items: [],
      billLines: [
        BillLine(label: 'Subtotal', value: 'BHD 20.000'),
        BillLine(label: 'Delivery fee', value: 'BHD 2.000'),
        BillLine(label: 'Service fee', value: 'BHD 0.250'),
        BillLine(label: 'VAT', value: 'BHD 2.225'),
        BillLine(label: 'Order total', value: 'BHD 24.475', isBold: true),
      ],
      upsell: [],
      upsellTitle: '',
      includeCutlery: false,
      totalLabel: 'BHD 24.475',
      cashbackLabel: '',
      totalAmount: 22.25,
      vatAmount: 2.225,
      grandTotal: 24.475,
    );

    final lines = billLinesWithTip(cart, 0.3);
    final vat = lines.where((line) => line.label == 'VAT').toList();
    expect(vat, hasLength(1));
    expect(vat.single.value, 'BHD 2.225');
    expect(lines.last.value, 'BHD 24.775');
    expect(
      lines.last.value,
      isNot('BHD ${(24.475 * 1.1 + 0.3).toStringAsFixed(3)}'),
    );
    expect(formatCheckoutTotal(cart, 0), 'BHD 24.475');
  });

  test('food modifier payload still sends optionIds and no variantId', () {
    final body = catalogCartItemBody(
      productId: 'burger',
      quantity: 1,
      optionIds: const ['size-regular'],
    );
    expect(body['productId'], 'burger');
    expect(body.containsKey('variantId'), isFalse);
    expect(body['options'], {
      'optionIds': ['size-regular'],
    });
  });
}
