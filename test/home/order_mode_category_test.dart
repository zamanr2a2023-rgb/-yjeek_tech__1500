import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';

void main() {
  test('order modes are not shop categories', () {
    expect(
      isOrderModeCategory(kind: 'ORDER_MODE', slug: 'delivery', name: 'Delivery'),
      isTrue,
    );
    expect(
      isOrderModeCategory(kind: 'ORDER_MODE', slug: 'order-mode-services', name: 'Services'),
      isTrue,
    );
    expect(isOrderModeCategory(slug: 'pickup', name: 'Pickup'), isTrue);
    expect(isOrderModeCategory(slug: 'dine-in', name: 'Dine-in'), isTrue);
    expect(isOrderModeCategory(slug: 'dine_in', name: 'Dine-in'), isTrue);
    expect(isOrderModeCategory(slug: 'scheduled', name: 'Scheduled'), isTrue);

    expect(
      isOrderModeCategory(kind: 'STORE_TYPE', slug: 'services', name: 'Services'),
      isFalse,
    );
    expect(
      isOrderModeCategory(kind: 'STORE_TYPE', slug: 'food', name: 'Food'),
      isFalse,
    );
    expect(
      isOrderModeCategory(kind: 'STORE_TYPE', slug: 'flowers', name: 'Flowers'),
      isFalse,
    );
  });
}
