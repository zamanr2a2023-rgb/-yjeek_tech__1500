import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/catalog/model/catalog_cart_payload.dart';

void main() {
  test('food payload keeps option ids and omits variantId', () {
    final body = catalogCartItemBody(
      productId: 'burger',
      quantity: 1,
      optionIds: const ['opt-reg'],
      addonIds: const ['cheese'],
    );

    expect(body.containsKey('variantId'), isFalse);
    expect(body['options'], {
      'optionIds': ['opt-reg'],
      'addonIds': ['cheese'],
    });
  });

  test('variant payload sends variantId and addon ids only', () {
    final fashion = catalogCartItemBody(
      productId: 'oxford',
      quantity: 1,
      variantId: 'var-m-navy',
      optionIds: const ['must-not-send'],
      addonIds: const ['gift-wrap'],
    );
    expect(fashion['variantId'], 'var-m-navy');
    expect(fashion['options'], {
      'addonIds': ['gift-wrap'],
    });
    expect((fashion['options'] as Map).containsKey('optionIds'), isFalse);

    final electronics = catalogCartItemBody(
      productId: 'a55',
      quantity: 1,
      variantId: 'var-256-blue',
    );
    expect(electronics['variantId'], 'var-256-blue');
    expect((electronics['options'] as Map).containsKey('optionIds'), isFalse);

    final vape = catalogCartItemBody(
      productId: 'caliburn',
      quantity: 1,
      variantId: 'var-12mg',
    );
    expect(vape['variantId'], 'var-12mg');
  });

  test('delivery cart shows variant label and keeps old lines', () {
    final cart = cartSnapshotFromJson({
      'vendor': {'id': 'hm', 'name': 'H&M'},
      'items': [
        {
          'id': 'line-food',
          'productId': 'burger',
          'quantity': 1,
          'unitPrice': 2.5,
          'product': {'name': 'Burger', 'price': 2.5, 'description': 'Beef'},
          'options': {
            'labels': ['Regular'],
          },
        },
        {
          'id': 'line-shirt',
          'productId': 'oxford',
          'quantity': 1,
          'variantId': 'var-m-navy',
          'unitPrice': 13.9,
          'product': {
            'name': 'Classic Fit Oxford Shirt',
            'price': 12.9,
            'description': 'Oxford cloth',
          },
          'options': {
            'variantLabel': 'M / Navy',
            'addons': [
              {'name': 'Gift wrapping', 'price': 1, 'quantity': 1},
            ],
          },
        },
      ],
      'summary': {'totalAmount': 16.4},
    }, CartOrderType.delivery);

    final food = cart.items.first;
    expect(food.variantId, isNull);
    expect(food.subtitle, 'Regular');
    expect(food.unitPriceLabel, 'BHD 2.500');

    final shirt = cart.items[1];
    expect(shirt.name, 'Classic Fit Oxford Shirt');
    expect(shirt.variantId, 'var-m-navy');
    expect(shirt.variantLabel, 'M / Navy');
    expect(shirt.subtitle, 'M / Navy · Gift wrapping');
    expect(shirt.unitPriceLabel, 'BHD 13.900');
  });

  test('scheduled cart keeps a line that has no variant', () {
    final cart = scheduledCartSnapshotFromJson({
      'groups': [
        {
          'vendor': {'id': 'shop', 'name': 'Sharaf DG'},
          'items': [
            {
              'id': 'old',
              'productId': 'phone',
              'name': 'Galaxy',
              'description': 'In stock',
              'quantity': 1,
              'unitPrice': 149,
            },
          ],
        },
      ],
      'summary': {'totalAmount': 149},
    });

    expect(cart, isNotNull);
    expect(cart!.items.single.variantId, isNull);
    expect(cart.items.single.subtitle, 'In stock');
    expect(cart.items.single.unitPriceLabel, 'BHD 149.000');
  });
}
