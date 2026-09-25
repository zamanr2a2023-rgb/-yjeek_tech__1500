/// Matches backend checkout: `vatAmount = roundBhd(totalAmount * 0.1)`.
const double kCheckoutVatRate = 0.1;

double checkoutVatAmount(double amountBeforeVat) {
  if (!amountBeforeVat.isFinite || amountBeforeVat <= 0) return 0;
  return double.parse(
    (amountBeforeVat * kCheckoutVatRate).toStringAsFixed(3),
  );
}

/// Cart/API `totalAmount` + VAT + tip — same figure as order `totalAmount` after place.
double checkoutGrandTotal(double amountBeforeVat, [double tipAmount = 0]) {
  final tip = tipAmount.isFinite && tipAmount > 0 ? tipAmount : 0.0;
  final base = amountBeforeVat.isFinite ? amountBeforeVat : 0.0;
  return double.parse(
    (base + checkoutVatAmount(base) + tip).toStringAsFixed(3),
  );
}
