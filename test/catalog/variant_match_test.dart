import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/retail/product_detail_strategies.dart';
import 'package:yjeek_app/features/catalog/model/catalog_product.dart';
import 'package:yjeek_app/features/catalog/model/variant_match.dart';

void main() {
  test('fashion size M + navy resolves the absolute variant price', () {
    final product = CatalogProduct.fromJson({
      'catalogMode': 'VARIANTS',
      'axes': [
        {
          'key': 'size',
          'uiHint': 'PILL',
          'values': [
            {'key': 'm', 'label': 'M'},
            {'key': 'l', 'label': 'L'},
            {'key': 'xl', 'label': 'XL'},
          ],
        },
        {
          'key': 'colour',
          'uiHint': 'SWATCH',
          'values': [
            {'key': 'navy', 'label': 'Navy', 'colorHex': '#001F3F'},
          ],
        },
      ],
      'variants': [
        {
          'id': 'hm-m-navy',
          'attributes': {'size': 'm', 'colour': 'navy'},
          'label': 'M / Navy',
          'price': 12.9,
          'stockStatus': 'IN_STOCK',
          'isAvailable': true,
        },
        {
          'id': 'hm-l-navy',
          'attributes': {'size': 'l', 'colour': 'navy'},
          'label': 'L / Navy',
          'price': 12.9,
          'stockStatus': 'IN_STOCK',
          'isAvailable': true,
        },
        {
          'id': 'hm-xl-navy',
          'attributes': {'size': 'xl', 'colour': 'navy'},
          'label': 'XL / Navy',
          'price': 14.9,
          'stockStatus': 'OUT_OF_STOCK',
          'isAvailable': true,
        },
      ],
    });

    final selected = {'size': 'm', 'colour': 'navy'};
    final match = matchVariant(
      variants: product.variants,
      selectedAttributes: selected,
    );

    expect(match?.id, 'hm-m-navy');
    expect(variantPrice(match), 12.9);

    final sizes = availableValuesForAxis(
      variants: product.variants,
      axisKey: 'size',
      selectedAttributes: {'colour': 'navy'},
      axisValueKeys: ['m', 'l', 'xl'],
    );
    expect(sizes, {'m': true, 'l': true, 'xl': false});
  });

  test('electronics 256GB + blue uses the variant price, not a delta', () {
    final variants = [
      CatalogVariant(
        id: 'a55-128-navy',
        attributes: const {'storage': '128gb', 'colour': 'navy'},
        price: 149,
        stockStatus: CatalogStockStatus.inStock,
        isAvailable: true,
      ),
      CatalogVariant(
        id: 'a55-256-blue',
        attributes: const {'storage': '256gb', 'colour': 'blue'},
        price: 176,
        stockStatus: CatalogStockStatus.inStock,
        isAvailable: true,
      ),
      CatalogVariant(
        id: 'a55-512-blue',
        attributes: const {'storage': '512gb', 'colour': 'blue'},
        price: 206,
        stockStatus: CatalogStockStatus.outOfStock,
        isAvailable: true,
      ),
    ];

    final match = matchVariant(
      variants: variants,
      selectedAttributes: const {'storage': '256gb', 'colour': 'blue'},
    );

    expect(match?.id, 'a55-256-blue');
    // 176 is the variant's own price. The matcher must not add 149 + 25 + 2.
    expect(variantPrice(match), 176);

    final storage = availableValuesForAxis(
      variants: variants,
      axisKey: 'storage',
      selectedAttributes: const {'colour': 'blue'},
      axisValueKeys: const ['128gb', '256gb', '512gb'],
    );
    expect(storage['256gb'], isTrue);
    expect(storage['512gb'], isFalse);
    expect(storage['128gb'], isFalse);
  });

  test('vape 12mg is its own variant and 20mg is not selectable', () {
    final variants = [
      const CatalogVariant(
        id: 'g2-0',
        attributes: {'nicotine': '0mg'},
        price: 12.5,
        stockStatus: CatalogStockStatus.inStock,
        isAvailable: true,
      ),
      const CatalogVariant(
        id: 'g2-12',
        attributes: {'nicotine': '12mg'},
        price: 12.75,
        stockStatus: CatalogStockStatus.inStock,
        isAvailable: true,
      ),
      const CatalogVariant(
        id: 'g2-20',
        attributes: {'nicotine': '20mg'},
        price: 13,
        stockStatus: CatalogStockStatus.outOfStock,
        isAvailable: false,
      ),
    ];

    final match = matchVariant(
      variants: variants,
      selectedAttributes: const {'nicotine': '12mg'},
    );

    expect(match?.id, 'g2-12');
    expect(variantPrice(match), 12.75);

    final strengths = availableValuesForAxis(
      variants: variants,
      axisKey: 'nicotine',
      axisValueKeys: const ['0mg', '12mg', '20mg'],
    );
    expect(strengths['12mg'], isTrue);
    expect(strengths['20mg'], isFalse);
  });

  test('partial selection does not match, and a null variant has no price', () {
    final match = matchVariant(
      variants: const [
        CatalogVariant(
          id: 'only-full',
          attributes: {'size': 'm', 'colour': 'navy'},
          price: 12.9,
        ),
      ],
      selectedAttributes: const {'size': 'm'},
    );

    expect(match, isNull);
    expect(variantPrice(match), isNull);
  });

  test('product json keeps restrictions and age gate nullable fields', () {
    final product = CatalogProduct.fromJson({
      'id': 'roses',
      'catalogMode': 'HYBRID',
      'restrictions': {'highValue': true, 'ageRestricted': false},
      'ageRestriction': {
        'required': true,
        'minimumAge': 18,
        'canPurchase': false,
        'cta': 'VERIFY_AGE',
        'banner': {
          'title': '18+ only',
          'message': 'your ID is checked on delivery',
        },
      },
      'addons': [
        {'id': 'card', 'name': 'Greeting card', 'price': 1.5, 'isActive': true},
      ],
    });

    expect(product.catalogMode, isNull);
    expect(product.restrictions?.highValue, isTrue);
    expect(product.restrictions?.ageRestricted, isFalse);
    expect(product.ageRestriction?.isRequired, isTrue);
    expect(product.ageRestriction?.minimumAge, 18);
    expect(product.ageRestriction?.canPurchase, isFalse);
    expect(product.ageRestriction?.cta, 'VERIFY_AGE');
    expect(product.ageRestriction?.banner?.title, '18+ only');
    expect(product.addons.single.price, 1.5);
  });

  test('food modifiers stay on option groups and do not become a variant', () {
    final optionGroups = browseOptionGroupsFromJson([
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

    final detail = UniversalProductDetail(
      id: 'burger',
      name: 'Burger',
      price: '2.500',
      description: 'Classic',
      optionGroups: optionGroups,
      addons: const [],
      catalog: CatalogProduct.fromJson(<String, dynamic>{
        'id': 'burger',
        'catalogMode': 'MODIFIERS',
        'variants': <dynamic>[],
      }),
    );

    expect(detail.usesVariantSelection, isFalse);
    expect(detail.optionGroups.single.options.single.id, 'opt-reg');
    expect(detail.catalog?.variants, isEmpty);
    expect(detail.catalog?.catalogMode, CatalogMode.modifiers);
  });

  test('missing catalogMode stays on the modifier flow', () {
    final detail = UniversalProductDetail(
      id: 'burger',
      name: 'Burger',
      price: '2.500',
      description: 'Classic',
      optionGroups: const [],
      addons: const [],
      catalog: CatalogProduct.fromJson(<String, dynamic>{'name': 'Burger'}),
    );
    expect(detail.usesVariantSelection, isFalse);
  });

  test('fashion, electronics, vape, and flowers resolve by attributes', () {
    final fashion = _ready(
      selected: const {'size': 'm', 'colour': 'navy'},
      variants: const [
        CatalogVariant(
          id: 'hm-m-navy',
          attributes: {'size': 'm', 'colour': 'navy'},
          price: 12.9,
          stockStatus: CatalogStockStatus.inStock,
          isAvailable: true,
        ),
      ],
      axes: const [
        CatalogAxis(key: 'size', name: 'Size', uiHint: CatalogUiHint.pill),
        CatalogAxis(
          key: 'colour',
          name: 'Colour',
          uiHint: CatalogUiHint.swatch,
        ),
      ],
    );
    expect(fashion.matched?.id, 'hm-m-navy');
    expect(fashion.ready, isTrue);
    expect(variantPrice(fashion.matched), 12.9);

    final electronics = _ready(
      selected: const {'storage': '256gb', 'colour': 'blue'},
      variants: const [
        CatalogVariant(
          id: 'a55-128',
          attributes: {'storage': '128gb', 'colour': 'navy'},
          price: 149,
          stockStatus: CatalogStockStatus.inStock,
          isAvailable: true,
        ),
        CatalogVariant(
          id: 'a55-256-blue',
          attributes: {'storage': '256gb', 'colour': 'blue'},
          price: 176,
          stockStatus: CatalogStockStatus.inStock,
          isAvailable: true,
        ),
      ],
      axes: const [
        CatalogAxis(key: 'storage', name: 'Storage'),
        CatalogAxis(key: 'colour', name: 'Colour'),
      ],
    );
    expect(electronics.matched?.id, 'a55-256-blue');
    expect(variantPrice(electronics.matched), 176);
    expect(electronics.ready, isTrue);

    final vape = _ready(
      selected: const {'nicotine': '12mg'},
      variants: const [
        CatalogVariant(
          id: 'g2-12',
          attributes: {'nicotine': '12mg'},
          price: 12.75,
          stockStatus: CatalogStockStatus.inStock,
          isAvailable: true,
        ),
        CatalogVariant(
          id: 'g2-20',
          attributes: {'nicotine': '20mg'},
          price: 13,
          stockStatus: CatalogStockStatus.outOfStock,
          isAvailable: false,
        ),
      ],
      axes: const [
        CatalogAxis(
          key: 'nicotine',
          name: 'Nicotine',
          uiHint: CatalogUiHint.pill,
        ),
      ],
    );
    expect(vape.matched?.id, 'g2-12');
    expect(vape.ready, isTrue);

    final vapeOut = _ready(
      selected: const {'nicotine': '20mg'},
      variants: const [
        CatalogVariant(
          id: 'g2-20',
          attributes: {'nicotine': '20mg'},
          price: 13,
          stockStatus: CatalogStockStatus.outOfStock,
          isAvailable: false,
        ),
      ],
      axes: const [CatalogAxis(key: 'nicotine', name: 'Nicotine')],
    );
    expect(vapeOut.matched?.id, 'g2-20');
    expect(vapeOut.ready, isFalse);

    final flowers = _ready(
      selected: const {'size': 'medium'},
      variants: const [
        CatalogVariant(
          id: 'roses-m',
          attributes: {'size': 'medium'},
          label: 'Medium',
          price: 18,
          stockStatus: CatalogStockStatus.inStock,
          isAvailable: true,
        ),
      ],
      axes: const [
        CatalogAxis(key: 'size', name: 'Size', uiHint: CatalogUiHint.pill),
      ],
    );
    expect(flowers.matched?.id, 'roses-m');
    expect(flowers.ready, isTrue);
    expect(variantUnitWithAddons(flowers.matched, const [1.5]), 19.5);
  });

  test('resolveVariantCatalog builds axes when API omits axis metadata', () {
    final product = CatalogProduct.fromJson({
      'catalogMode': 'VARIANTS',
      'variants': [
        {
          'id': 's-black',
          'attributes': {'size': 's', 'colour': 'black'},
          'label': 'S / Black',
          'price': 1,
          'stockQty': 3,
          'isAvailable': true,
        },
      ],
    });
    expect(product.axes.length, 2);
    expect(product.axes.any((a) => a.key == 'colour'), isTrue);
    expect(product.axes.any((a) => a.key == 'size'), isTrue);
  });
}

({CatalogVariant? matched, bool ready}) _ready({
  required Map<String, String> selected,
  required List<CatalogVariant> variants,
  required List<CatalogAxis> axes,
}) {
  final matched = matchVariant(
    variants: variants,
    selectedAttributes: selected,
  );
  return (
    matched: matched,
    ready: variantSelectionReady(
      axes: axes,
      selectedAttributes: selected,
      matched: matched,
    ),
  );
}
