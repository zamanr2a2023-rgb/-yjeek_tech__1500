import 'package:yjeek_app/features/cart/model/cart_repository.dart';

/// Stable key for re-running voucher evaluate when the basket changes.
String voucherEvaluateKey(CartSnapshot? cart) {
  if (cart == null) return '';
  final parts = cart.items.map((i) => '${i.id}:${i.quantity}').join('|');
  return '${cart.cartId ?? ''}_${cart.vendorId ?? ''}_'
      '${cart.totalAmount.toStringAsFixed(3)}_${cart.itemCount}_$parts';
}
