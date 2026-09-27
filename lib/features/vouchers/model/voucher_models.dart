class CustomerVoucher {
  const CustomerVoucher({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.validTo,
    required this.fundedBy,
    required this.vendorScopeSummary,
    this.value,
    this.maxDiscount,
    this.minOrder,
    this.maxOrder,
  });

  final String id;
  final String title;
  final String type;
  final String status;
  final DateTime validTo;
  final String fundedBy;
  final String vendorScopeSummary;
  final String? value;
  final String? maxDiscount;
  final String? minOrder;
  final String? maxOrder;

  factory CustomerVoucher.fromJson(Map<String, dynamic> json) {
    return CustomerVoucher(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Voucher',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      validTo: DateTime.tryParse(json['validTo']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      fundedBy: json['fundedBy']?.toString() ?? '',
      vendorScopeSummary: json['vendorScopeSummary']?.toString() ?? '',
      value: json['value']?.toString(),
      maxDiscount: json['maxDiscount']?.toString(),
      minOrder: json['minOrder']?.toString(),
      maxOrder: json['maxOrder']?.toString(),
    );
  }

  String get valueLabel {
    if (type == 'free_delivery') return 'Free delivery';
    if (type == 'percent' && value != null) {
      final n = double.tryParse(value!);
      if (n != null) return '${n.toStringAsFixed(0)}% off';
      return '$value% off';
    }
    if (value != null && value!.isNotEmpty) return 'BHD $value off';
    return 'Discount';
  }

  String get validToLabel {
    final local = validTo.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }
}

class ApplicableVoucher {
  const ApplicableVoucher({
    required this.voucherId,
    required this.estimatedSaving,
    required this.autoSelect,
  });

  final String voucherId;
  final String estimatedSaving;
  final bool autoSelect;

  factory ApplicableVoucher.fromJson(Map<String, dynamic> json) {
    return ApplicableVoucher(
      voucherId: json['voucherId']?.toString() ?? '',
      estimatedSaving: json['estimatedSaving']?.toString() ?? '0.000',
      autoSelect: json['autoSelect'] == true,
    );
  }
}

class NotApplicableVoucher {
  const NotApplicableVoucher({
    required this.voucherId,
    required this.reason,
  });

  final String voucherId;
  final String reason;

  factory NotApplicableVoucher.fromJson(Map<String, dynamic> json) {
    return NotApplicableVoucher(
      voucherId: json['voucherId']?.toString() ?? '',
      reason: json['reason']?.toString() ?? 'Not applicable',
    );
  }
}

class CheckoutVoucherEvaluation {
  const CheckoutVoucherEvaluation({
    required this.applicable,
    required this.notApplicable,
  });

  final List<ApplicableVoucher> applicable;
  final List<NotApplicableVoucher> notApplicable;

  String? get autoSelectedId {
    for (final v in applicable) {
      if (v.autoSelect) return v.voucherId;
    }
    return applicable.isNotEmpty ? applicable.first.voucherId : null;
  }

  factory CheckoutVoucherEvaluation.fromJson(Map<String, dynamic> json) {
    final applicable = <ApplicableVoucher>[];
    final notApplicable = <NotApplicableVoucher>[];
    final a = json['applicable'];
    final n = json['notApplicable'];
    if (a is List) {
      for (final raw in a) {
        if (raw is Map<String, dynamic>) {
          applicable.add(ApplicableVoucher.fromJson(raw));
        }
      }
    }
    if (n is List) {
      for (final raw in n) {
        if (raw is Map<String, dynamic>) {
          notApplicable.add(NotApplicableVoucher.fromJson(raw));
        }
      }
    }
    return CheckoutVoucherEvaluation(
      applicable: applicable,
      notApplicable: notApplicable,
    );
  }

  static const empty = CheckoutVoucherEvaluation(
    applicable: [],
    notApplicable: [],
  );
}
