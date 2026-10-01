/// Adds a customer tip onto a server grand total.
///
/// VAT stays on the server. This does not multiply by a tax rate.
double payableWithTip(double serverGrandTotal, [double tipAmount = 0]) {
  final tip = tipAmount.isFinite && tipAmount > 0 ? tipAmount : 0.0;
  final base = serverGrandTotal.isFinite ? serverGrandTotal : 0.0;
  return double.parse((base + tip).toStringAsFixed(3));
}
