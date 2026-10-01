/// Customer delivery quote from cart, checkout, and order payloads.
/// Money stays server-authored. The app does not recompute fees.
class DeliveryQuote {
  const DeliveryQuote({
    required this.fee,
    required this.waived,
    required this.outOfRange,
    this.waiveReason,
    this.distanceKm,
    this.prompts,
  });

  final String fee;
  final bool waived;
  final String? waiveReason;
  final String? distanceKm;
  final bool outOfRange;
  final DeliveryPrompts? prompts;

  bool get blocksCheckout => prompts?.minOrder?.blocksCheckout == true;

  String? get minOrderMessage {
    final prompt = prompts?.minOrder;
    if (prompt == null || !prompt.blocksCheckout) return null;
    final message = prompt.message?.trim();
    if (message == null || message.isEmpty) return null;
    return message;
  }

  String? get freeDeliveryMessage {
    final message = prompts?.freeDelivery?.message?.trim();
    if (message == null || message.isEmpty) return null;
    return message;
  }

  /// Always a 3-decimal BHD amount, including a waived `0.000`.
  String get feeLabel => formatBhdAmount(fee);

  static DeliveryQuote? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final promptsRaw = map['prompts'];
    return DeliveryQuote(
      fee: map['fee']?.toString() ?? '0.000',
      waived: map['waived'] == true,
      waiveReason: map['waiveReason']?.toString(),
      distanceKm: map['distanceKm']?.toString(),
      outOfRange: map['outOfRange'] == true,
      prompts: promptsRaw is Map
          ? DeliveryPrompts.tryParse(Map<String, dynamic>.from(promptsRaw))
          : null,
    );
  }
}

class DeliveryPrompts {
  const DeliveryPrompts({this.minOrder, this.freeDelivery});

  final MinOrderPrompt? minOrder;
  final FreeDeliveryPrompt? freeDelivery;

  static DeliveryPrompts tryParse(Map<String, dynamic> json) {
    final minRaw = json['minOrder'];
    final freeRaw = json['freeDelivery'];
    return DeliveryPrompts(
      minOrder: minRaw is Map
          ? MinOrderPrompt.tryParse(Map<String, dynamic>.from(minRaw))
          : null,
      freeDelivery: freeRaw is Map
          ? FreeDeliveryPrompt.tryParse(Map<String, dynamic>.from(freeRaw))
          : null,
    );
  }
}

class MinOrderPrompt {
  const MinOrderPrompt({
    required this.blocksCheckout,
    this.required,
    this.shortfall,
    this.message,
  });

  final String? required;
  final String? shortfall;
  final bool blocksCheckout;
  final String? message;

  static MinOrderPrompt tryParse(Map<String, dynamic> json) {
    return MinOrderPrompt(
      required: json['required']?.toString(),
      shortfall: json['shortfall']?.toString(),
      blocksCheckout: json['blocksCheckout'] == true,
      message: json['message']?.toString(),
    );
  }
}

class FreeDeliveryPrompt {
  const FreeDeliveryPrompt({
    this.threshold,
    this.shortfall,
    this.message,
  });

  final String? threshold;
  final String? shortfall;
  final String? message;

  static FreeDeliveryPrompt tryParse(Map<String, dynamic> json) {
    return FreeDeliveryPrompt(
      threshold: json['threshold']?.toString(),
      shortfall: json['shortfall']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

/// Contract 409 copy for `OUT_OF_DELIVERY_RANGE`. The quote flag has no message field.
const String kOutOfDeliveryRangeMessage =
    'This address is outside the delivery area';

String formatBhdAmount(dynamic raw) {
  if (raw is num) return 'BHD ${raw.toStringAsFixed(3)}';
  final parsed = double.tryParse(raw?.toString() ?? '');
  if (parsed == null) return 'BHD 0.000';
  return 'BHD ${parsed.toStringAsFixed(3)}';
}

double? parseApiMoney(dynamic raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '');
}

/// "Free" only for a waived in-range fee. Every other amount stays numeric.
String deliveryFeeReceiptLabel({
  required dynamic fee,
  DeliveryQuote? quote,
}) {
  if (quote != null && quote.waived && !quote.outOfRange) return 'Free';
  if (quote != null) return quote.feeLabel;
  return formatBhdAmount(fee);
}
