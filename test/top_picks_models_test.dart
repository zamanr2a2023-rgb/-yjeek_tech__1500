import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/home/model/top_picks_models.dart';

void main() {
  test('parseTopPicksData flattens branches.items', () {
    final items = HomeTopPickItem.parseTopPicksData({
      'branches': [
        {
          'branchId': 'br1',
          'vendorId': 'v1',
          'vendorName': 'SF Kitchen',
          'distanceKm': 1.2,
          'items': [
            {
              'productId': 'p1',
              'name': 'Beef Chap',
              'price': 2.5,
              'sortOrder': 0,
              'isAvailable': true,
            },
          ],
        },
      ],
    });
    expect(items.length, 1);
    expect(items.first.branchId, 'br1');
    expect(items.first.vendorId, 'v1');
    expect(items.first.productId, 'p1');
  });

  test('parseTopPicksData reads flat items array', () {
    final items = HomeTopPickItem.parseTopPicksData({
      'items': [
        {
          'branchId': 'br2',
          'vendorId': 'v2',
          'vendorName': 'Cafe',
          'productId': 'p9',
          'name': 'Latte',
          'isAvailable': true,
        },
      ],
    });
    expect(items.single.productId, 'p9');
  });
}
