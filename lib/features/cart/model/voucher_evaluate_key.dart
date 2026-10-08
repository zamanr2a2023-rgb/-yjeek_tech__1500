import 'package:yjeek_app/features/cart/model/cart_repository.dart';

/// Stable key for re-running voucher evaluate when the basket changes.
String voucherEvaluateKey(CartSnapshot? cart) {
  if (cart == null) return '';
  final parts = cart.items
      .expand(
        (i) => i.lineSegments.map((s) => '${s.id}:${s.quantity}'),
      )
      .join('|');
  return '${cart.cartId ?? ''}_${cart.vendorId ?? ''}_'
      '${cart.totalAmount.toStringAsFixed(3)}_${cart.itemCount}_$parts';
}
