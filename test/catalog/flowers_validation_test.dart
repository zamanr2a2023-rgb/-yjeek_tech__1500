import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/browse/model/age_verification_repository.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/retail/product_detail_strategies.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/catalog/model/catalog_cart_payload.dart';
import 'package:yjeek_app/features/catalog/model/catalog_product.dart';
import 'package:yjeek_app/features/catalog/model/variant_match.dart';

/// Classic Red Roses as the customer product API presents it.
Map<String, dynamic> classicRedRosesJson() {
  return <String, dynamic>{
    'id': 'roses',
    'name': 'Classic Red Roses',
    'catalogMode': 'VARIANTS',
    'axes': [
      {
        'key': 'size',
        'name': 'Bouquet size',
        'uiHint': 'PILL',
        'isRequired': true,
        'values': [
          {'key': 'small', 'label': 'Small'},
          {'key': 'medium', 'label': 'Medium'},
          {'key': 'large', 'label': 'Large'},
          {'key': 'grand', 'label': 'Grand'},
        ],
      },
    ],
    'variants': [
      {
        'id': 'roses-s',
        'attributes': {'size': 'small'},
        'label': 'Small',
        'price': 18,
        'stockStatus': 'IN_STOCK',
        'isAvailable': true,
      },
      {
        'id': 'roses-m',
        'attributes': {'size': 'medium'},
        'label': 'Medium',
        'price': 18,
        'stockStatus': 'IN_STOCK',
        'isAvailable': true,
      },
      {
        'id': 'roses-l',
        'attributes': {'size': 'large'},
        'label': 'Large',
        'price': 26,
        'stockStatus': 'IN_STOCK',
        'isAvailable': true,
      },
      {
        'id': 'roses-g',
        'attributes': {'size': 'grand'},
        'label': 'Grand',
        'price': 36,
        'stockStatus': 'OUT_OF_STOCK',
        'isAvailable': false,
      },
    ],
    'addons': [
      {'id': 'card', 'name': 'Greeting card', 'price': 1.5, 'isActive': true},
      {'id': 'vase', 'name': 'Glass vase', 'price': 6, 'isActive': true},
      {'id': 'choc', 'name': 'Chocolate box', 'price': 8, 'isActive': true},
    ],
    'optionGroups': <dynamic>[],
  };
}

void main() {
  test('flowers payload loads size axis, variants, and addons', () {
    final product = CatalogProduct.fromJson(classicRedRosesJson());

    expect(product.catalogMode, CatalogMode.variants);
    expect(product.axes.single.key, 'size');
    expect(product.axes.single.uiHint, CatalogUiHint.pill);
    expect(product.axes.single.values.map((value) => value.label).toList(), [
      'Small',
      'Medium',
      'Large',
      'Grand',
    ]);
    expect(product.variants.map((row) => row.id).toList(), [
      'roses-s',
      'roses-m',
      'roses-l',
      'roses-g',
    ]);
    expect(product.addons.map((addon) => addon.name).toList(), [
      'Greeting card',
      'Glass vase',
      'Chocolate box',
    ]);
    expect(product.addons.map((addon) => addon.price).toList(), [1.5, 6, 8]);
  });

  test('size selection uses the absolute variant price', () {
    final product = CatalogProduct.fromJson(classicRedRosesJson());
    final detail = UniversalProductDetail(
      id: 'roses',
      name: 'Classic Red Roses',
      price: '18.000',
      description: 'Roses',
      optionGroups: const [],
      addons: const [],
      catalog: product,
    );
    expect(detail.usesVariantSelection, isTrue);

    final medium = matchVariant(
      variants: product.variants,
      selectedAttributes: const {'size': 'medium'},
    );
    expect(medium?.id, 'roses-m');
    expect(medium?.label, 'Medium');
    expect(variantPrice(medium), 18);
    expect(variantPrice(medium), medium?.price);
    expect(
      variantSelectionReady(
        axes: product.axes,
        selectedAttributes: const {'size': 'medium'},
        matched: medium,
      ),
      isTrue,
    );

    final grand = matchVariant(
      variants: product.variants,
      selectedAttributes: const {'size': 'grand'},
    );
    expect(grand?.price, 36);
    expect(variantIsSelectable(grand!), isFalse);
    expect(
      variantSelectionReady(
        axes: product.axes,
        selectedAttributes: const {'size': 'grand'},
        matched: grand,
      ),
      isFalse,
    );

    final sizes = availableValuesForAxis(
      variants: product.variants,
      axisKey: 'size',
      axisValueKeys: const ['small', 'medium', 'large', 'grand'],
    );
    expect(sizes['grand'], isFalse);
    expect(sizes['medium'], isTrue);

    expect(variantUnitWithAddons(medium, const [1.5]), 19.5);
  });

  test('flowers cart sends variantId and addon ids only', () {
    final body = catalogCartItemBody(
      productId: 'roses',
      quantity: 1,
      variantId: 'roses-m',
      optionIds: const ['must-not-send'],
      addonIds: const ['card', 'vase'],
    );

    expect(body['productId'], 'roses');
    expect(body['variantId'], 'roses-m');
    expect(body['quantity'], 1);
    expect(body['options'], {
      'addonIds': ['card', 'vase'],
    });
    expect((body['options'] as Map).containsKey('optionIds'), isFalse);
  });

  test('flowers cart shows name, size, addons, and server unit price', () {
    final cart = scheduledCartSnapshotFromJson({
      'groups': [
        {
          'vendor': {'id': 'bloom', 'name': 'Bloom Bahrain'},
          'items': [
            {
              'id': 'line-roses',
              'productId': 'roses',
              'name': 'Classic Red Roses',
              'description': 'In stock',
              'quantity': 1,
              'unitPrice': 19.5,
              'variantId': 'roses-m',
              'options': {
                'variantLabel': 'Medium',
                'addons': [
                  {'name': 'Greeting card', 'price': 1.5, 'quantity': 1},
                ],
              },
            },
          ],
        },
      ],
      'summary': {
        'subtotal': 19.5,
        'deliveryFee': 2.75,
        'serviceFee': 0,
        'totalAmount': 22.25,
      },
      'delivery': {'fee': '2.750', 'waived': false, 'outOfRange': false},
    });

    final line = cart!.items.single;
    expect(line.name, 'Classic Red Roses');
    expect(line.variantLabel, 'Medium');
    expect(line.subtitle, 'Medium · Greeting card');
    expect(line.unitPriceLabel, 'BHD 19.500');

    final delivery = cart.billLines.singleWhere(
      (row) => row.label == 'Delivery fee',
    );
    expect(delivery.value, 'BHD 2.750');
    expect(cart.delivery?.fee, '2.750');
    expect(delivery.value, isNot('BHD 1.000'));
  });

  test('catalog regression: food, fashion, electronics, vape, flowers', () {
    final foodGroups = browseOptionGroupsFromJson([
      <String, dynamic>{
        'name': 'Size',
        'minSelect': 1,
        'maxSelect': 1,
        'options': [
          <String, dynamic>{
            'id': 'opt-reg',
            'name': 'Regular',
            'priceDelta': 0,
          },
        ],
      },
    ]);
    final food = UniversalProductDetail(
      id: 'burger',
      name: 'Burger',
      price: '2.500',
      description: 'Classic',
      optionGroups: foodGroups,
      addons: const [],
      catalog: CatalogProduct.fromJson(<String, dynamic>{
        'catalogMode': 'MODIFIERS',
      }),
    );
    expect(food.usesVariantSelection, isFalse);
    expect(food.optionGroups.single.options.single.id, 'opt-reg');
    final foodBody = catalogCartItemBody(
      productId: 'burger',
      quantity: 1,
      optionIds: const ['opt-reg'],
    );
    expect(foodBody.containsKey('variantId'), isFalse);
    expect(foodBody['options'], {
      'optionIds': ['opt-reg'],
    });

    final fashion = matchVariant(
      variants: const [
        CatalogVariant(
          id: 'var-m-navy',
          attributes: {'size': 'm', 'colour': 'navy'},
          price: 12.9,
        ),
      ],
      selectedAttributes: const {'size': 'm', 'colour': 'navy'},
    );
    expect(fashion?.id, 'var-m-navy');
    expect(
      catalogCartItemBody(
        productId: 'oxford',
        quantity: 1,
        variantId: fashion?.id,
      )['variantId'],
      'var-m-navy',
    );

    final electronics = CatalogProduct.fromJson(<String, dynamic>{
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
    expect(electronics.restrictions?.isHighValue, isTrue);
    expect(
      matchVariant(
        variants: electronics.variants,
        selectedAttributes: const {'storage': '256gb', 'colour': 'blue'},
      )?.id,
      'var-256-blue',
    );

    final vape = matchVariant(
      variants: const [
        CatalogVariant(
          id: 'g2-12',
          attributes: {'nicotine': '12mg'},
          price: 12.5,
          stockStatus: CatalogStockStatus.inStock,
          isAvailable: true,
        ),
      ],
      selectedAttributes: const {'nicotine': '12mg'},
    );
    expect(vape?.id, 'g2-12');
    expect(
      CatalogAgeRestriction.fromJson(<String, dynamic>{
        'required': true,
        'canPurchase': false,
        'cta': 'VERIFY_AGE',
      }).requiresAgeVerification,
      isTrue,
    );
    expect(
      ageVerificationScreenFromApi('verified'),
      AgeVerificationScreen.verified,
    );

    final flowers = CatalogProduct.fromJson(classicRedRosesJson());
    expect(flowers.catalogMode, CatalogMode.variants);
    expect(flowers.axes.single.key, 'size');
    expect(flowers.addons, hasLength(3));
  });
}
