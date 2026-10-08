import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';

CartLineItem _line({
  required String id,
  String productId = 'p1',
  int quantity = 1,
  List<CartSideLine> sides = const [],
}) {
  return CartLineItem(
    id: id,
    productId: productId,
    name: 'Chicken Pasta',
    subtitle: 'Long description that should not affect merge key',
    quantity: quantity,
    unitPriceLabel: 'BHD 2.200',
    sides: sides,
  );
}

void main() {
  test('mergeEquivalentCartLines combines identical product and add-ons', () {
    const mozzarella = CartSideLine(
      name: 'Mozzarella Cheese',
      quantity: 1,
      priceLabel: 'BHD 0.000',
    );
    final merged = mergeEquivalentCartLines(
      [
        _line(id: 'a', sides: [mozzarella]),
        _line(id: 'b', sides: [mozzarella]),
      ],
      CartOrderType.delivery,
    );

    expect(merged.length, 1);
    expect(merged.first.quantity, 2);
    expect(merged.first.segments?.length, 2);
    expect(merged.first.segments?.map((s) => s.id).toList(), ['a', 'b']);
  });

  test('stableCartLineOrder keeps rows in place when API reorders', () {
    const mozzarella = CartSideLine(
      name: 'Mozzarella Cheese',
      quantity: 1,
      priceLabel: 'BHD 0.000',
    );
    final tikka = _line(id: '1', productId: 'tikka', sides: const []);
    final grill = _line(id: '2', productId: 'grill', sides: const []);
    final reordered = [grill, tikka];
    final previous = [
      cartLineMergeKey(tikka),
      cartLineMergeKey(grill),
    ];
    final ordered = stableCartLineOrder(reordered, previousKeys: previous);
    expect(ordered.map((i) => i.productId).toList(), ['tikka', 'grill']);
  });

  test('mergeEquivalentCartLines keeps distinct add-ons separate', () {
    final merged = mergeEquivalentCartLines(
      [
        _line(
          id: 'a',
          sides: const [
            CartSideLine(
              name: 'Mozzarella Cheese',
              quantity: 1,
              priceLabel: 'BHD 0.000',
            ),
          ],
        ),
        _line(
          id: 'b',
          sides: const [
            CartSideLine(
              name: 'Cheddar',
              quantity: 1,
              priceLabel: 'BHD 0.000',
            ),
          ],
        ),
      ],
      CartOrderType.delivery,
    );

    expect(merged.length, 2);
  });
}
