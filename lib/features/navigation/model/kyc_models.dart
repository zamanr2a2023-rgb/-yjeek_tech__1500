class KycSection {
  const KycSection({
    required this.status,
    this.frontUrl,
    this.backUrl,
    this.certificateUrl,
    this.cprNumber,
    this.cprExpiry,
    this.ibanMasked,
    this.accountName,
    this.rejectReason,
  });

  final String status;
  final String? frontUrl;
  final String? backUrl;
  final String? certificateUrl;
  final String? cprNumber;
  final DateTime? cprExpiry;
  final String? ibanMasked;
  final String? accountName;
  final String? rejectReason;

  bool get isVerified => status.toUpperCase() == 'VERIFIED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get hasFront => frontUrl != null && frontUrl!.isNotEmpty;
  bool get hasBack => backUrl != null && backUrl!.isNotEmpty;
  bool get hasCertificate =>
      certificateUrl != null && certificateUrl!.isNotEmpty;

  String get badgeLabel {
    return switch (status.toUpperCase()) {
      'VERIFIED' => 'VERIFIED',
      'PENDING' => 'PENDING',
      'REJECTED' => 'REJECTED',
      _ => 'NOT VERIFIED',
    };
  }

  factory KycSection.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const KycSection(status: 'NOT_VERIFIED');
    }
    DateTime? expiry;
    final rawExpiry = json['cprExpiry'];
    if (rawExpiry != null) {
      expiry = DateTime.tryParse(rawExpiry.toString());
    }
    return KycSection(
      status: json['status'] as String? ?? 'NOT_VERIFIED',
      frontUrl: json['frontUrl'] as String?,
      backUrl: json['backUrl'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      cprNumber: json['cprNumber'] as String?,
      cprExpiry: expiry,
      ibanMasked: json['ibanMasked'] as String?,
      accountName: json['accountName'] as String?,
      rejectReason: json['rejectReason'] as String?,
    );
  }
}

class KycStatus {
  const KycStatus({
    required this.status,
    required this.id,
    required this.bank,
    this.hasIdDocument = false,
    this.hasBankDocument = false,
  });

  final String status;
  final KycSection id;
  final KycSection bank;
  final bool hasIdDocument;
  final bool hasBankDocument;

  bool get isFullyVerified => id.isVerified && bank.isVerified;

  static const empty = KycStatus(
    status: 'NOT_VERIFIED',
    id: KycSection(status: 'NOT_VERIFIED'),
    bank: KycSection(status: 'NOT_VERIFIED'),
  );

  factory KycStatus.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final bankRaw = json['bank'];
    return KycStatus(
      status: json['status'] as String? ?? 'NOT_VERIFIED',
      id: KycSection.fromJson(
        idRaw is Map<String, dynamic> ? idRaw : null,
      ),
      bank: KycSection.fromJson(
        bankRaw is Map<String, dynamic> ? bankRaw : null,
      ),
      hasIdDocument: json['hasIdDocument'] == true,
      hasBankDocument: json['hasBankDocument'] == true,
    );
  }
}
