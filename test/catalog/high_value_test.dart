import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/catalog/model/catalog_cart_payload.dart';
import 'package:yjeek_app/features/catalog/model/catalog_product.dart';
import 'package:yjeek_app/features/catalog/model/variant_match.dart';

void main() {
  test('normal electronics product is not marked high value', () {
    final product = CatalogProduct.fromJson(<String, dynamic>{
      'id': 'a55',
      'catalogMode': 'VARIANTS',
      'restrictions': {'highValue': false, 'ageRestricted': false},
    });

    expect(product.restrictions?.isHighValue, isFalse);

    final body = catalogCartItemBody(
      productId: 'a55',
      quantity: 1,
      variantId: 'var-128-navy',
    );
    expect(body['variantId'], 'var-128-navy');
    expect(body.containsKey('highValue'), isFalse);
  });

  test('high value flag comes from restrictions.highValue', () {
    final flagged = CatalogProduct.fromJson(<String, dynamic>{
      'id': 'a55',
      'catalogMode': 'VARIANTS',
      'restrictions': {
        'highValue': true,
        'ageRestricted': false,
        'highValuePod': {'otpRequired': true, 'namedRecipientOnly': true},
      },
    });
    expect(flagged.restrictions?.isHighValue, isTrue);
    expect(flagged.restrictions?.ageRestricted, isFalse);

    final missing = CatalogProduct.fromJson(<String, dynamic>{
      'id': 'cable',
      'catalogMode': 'VARIANTS',
    });
    expect(missing.restrictions, isNull);
  });

  test('256GB + blue still resolves variant id and absolute price', () {
    final product = CatalogProduct.fromJson(<String, dynamic>{
      'catalogMode': 'VARIANTS',
      'restrictions': {'highValue': true, 'ageRestricted': false},
      'variants': [
        {
          'id': 'var-256-blue',
          'attributes': {'storage': '256gb', 'colour': 'blue'},
          'price': 176,
          'stockStatus': 'IN_STOCK',
          'isAvailable': true,
        },
      ],
    });

    final match = matchVariant(
      variants: product.variants,
      selectedAttributes: const {'storage': '256gb', 'colour': 'blue'},
    );
    expect(match?.id, 'var-256-blue');
    expect(variantPrice(match), 176);
    expect(product.restrictions?.isHighValue, isTrue);

    final body = catalogCartItemBody(
      productId: 'a55',
      quantity: 1,
      variantId: match!.id,
      addonIds: const ['warranty'],
    );
    expect(body['variantId'], 'var-256-blue');
    expect(body['options'], {
      'addonIds': ['warranty'],
    });
    expect((body['options'] as Map).containsKey('optionIds'), isFalse);
  });

  test(
    'scheduled cart keeps name, variant label, addons, and server price',
    () {
      final cart = scheduledCartSnapshotFromJson({
        'groups': [
          {
            'vendor': {'id': 'sharaf', 'name': 'Sharaf DG'},
            'items': [
              {
                'id': 'line-1',
                'productId': 'a55',
                'name': 'Galaxy A55',
                'description': 'In stock',
                'quantity': 1,
                'unitPrice': 176,
                'variantId': 'var-256-blue',
                'options': {
                  'variantLabel': '256GB / Blue',
                  'addons': [
                    {'name': 'Screen protector', 'price': 3.5, 'quantity': 1},
                  ],
                },
                'restrictions': {'highValue': true},
              },
            ],
          },
        ],
      });

      final line = cart!.items.single;
      expect(line.name, 'Galaxy A55');
      expect(line.variantId, 'var-256-blue');
      expect(line.variantLabel, '256GB / Blue');
      expect(line.subtitle, '256GB / Blue · Screen protector');
      expect(line.unitPriceLabel, 'BHD 176.000');
    },
  );

  test('food payload stays option ids without a variant id', () {
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

  test('high value checkout message uses the error code only', () {
    expect(
      highValueCheckoutMessage('HIGH_VALUE_DELIVERY_UNAVAILABLE'),
      'This high-value item couldn’t be checked out. Please try again.',
    );
    expect(highValueCheckoutMessage('SECURE_DELIVERY_REQUIRED'), isNotNull);
    expect(highValueCheckoutMessage('SCHEDULED_WINDOW_FULL'), isNull);
    expect(highValueCheckoutMessage('you are a high value customer'), isNull);
  });
}
