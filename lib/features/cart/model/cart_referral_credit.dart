/// Referral credit fields from cart/checkout `summary` (M02).
class CartReferralCredit {
  const CartReferralCredit({
    this.available,
    this.maxApplicable,
    this.applied,
  });

  final double? available;
  final double? maxApplicable;
  final double? applied;

  bool get hasAvailable => (available ?? 0) > 0;

  static CartReferralCredit? tryParse(Map<String, dynamic>? summary) {
    if (summary == null) return null;
    final available = _read(summary['referralCreditAvailable']);
    final max = _read(summary['referralCreditMaxApplicable']);
    final applied = _read(summary['referralCreditApplied']);
    if (available == null && max == null && applied == null) return null;
    return CartReferralCredit(
      available: available,
      maxApplicable: max,
      applied: applied,
    );
  }

  static double? _read(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
  }
}
