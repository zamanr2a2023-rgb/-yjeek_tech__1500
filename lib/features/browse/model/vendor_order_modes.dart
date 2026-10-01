/// Customer list filtering: vendor flags ∩ primary branch allows* (matches menu API).
bool vendorSupportsOrderType(Map<String, dynamic> json, String mode) {
  final upper = mode.toUpperCase();
  final types = json['orderTypes'];
  if (types is List && types.isNotEmpty) {
    final listed = types
        .map((t) => t.toString().toUpperCase())
        .where((t) => t.isNotEmpty)
        .toSet();
    if (!listed.contains(upper)) return false;
  }

  switch (upper) {
    case 'DELIVERY':
      return json['supportsDelivery'] == true;
    case 'PICKUP':
      if (json['supportsPickup'] != true) return false;
      return _branchAllows(json, pickup: true);
    case 'DINE_IN':
      if (json['supportsDineIn'] != true) return false;
      return _branchAllows(json, dineIn: true);
    default:
      return false;
  }
}

bool _branchAllows(
  Map<String, dynamic> json, {
  bool pickup = false,
  bool dineIn = false,
}) {
  final branches = json['branches'];
  if (branches is! List || branches.isEmpty) return true;

  Map<String, dynamic>? primary;
  for (final raw in branches) {
    if (raw is! Map<String, dynamic>) continue;
    if (raw['isPrimary'] == true) {
      primary = raw;
      break;
    }
    primary ??= raw;
  }
  if (primary == null) return true;

  if (pickup) {
    return primary['allowsPickup'] != false;
  }
  if (dineIn) {
    return primary['allowsDineIn'] != false;
  }
  return true;
}
