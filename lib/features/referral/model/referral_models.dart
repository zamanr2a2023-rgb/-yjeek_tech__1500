class ReferralMe {
  const ReferralMe({
    required this.programmeEnabled,
    required this.inviterRewardAmount,
    required this.inviteeRewardAmount,
    required this.minOrderAmount,
    required this.remainingDay,
    required this.remainingMonth,
    this.creditValidityDays,
    this.inviteExpiryDays,
    this.coverageCapPercent,
    this.coverageCapEnabled = false,
    this.invitesPerDay,
    this.invitesPerMonth,
  });

  final bool programmeEnabled;
  final String inviterRewardAmount;
  final String inviteeRewardAmount;
  final String minOrderAmount;
  final int remainingDay;
  final int remainingMonth;
  final int? creditValidityDays;
  final int? inviteExpiryDays;
  final int? coverageCapPercent;
  final bool coverageCapEnabled;
  final int? invitesPerDay;
  final int? invitesPerMonth;

  factory ReferralMe.fromJson(Map<String, dynamic> json) {
    return ReferralMe(
      programmeEnabled: json['programmeEnabled'] == true,
      inviterRewardAmount: _money(json['inviterRewardAmount']),
      inviteeRewardAmount: _money(json['inviteeRewardAmount']),
      minOrderAmount: _money(json['minOrderAmount']),
      remainingDay: (json['remainingDay'] as num?)?.toInt() ?? 0,
      remainingMonth: (json['remainingMonth'] as num?)?.toInt() ?? 0,
      creditValidityDays: (json['creditValidityDays'] as num?)?.toInt(),
      inviteExpiryDays: (json['inviteExpiryDays'] as num?)?.toInt(),
      coverageCapPercent: (json['coverageCapPercent'] as num?)?.toInt(),
      coverageCapEnabled: json['coverageCapEnabled'] == true,
      invitesPerDay: (json['invitesPerDay'] as num?)?.toInt(),
      invitesPerMonth: (json['invitesPerMonth'] as num?)?.toInt(),
    );
  }
}

class ReferralInviteResult {
  const ReferralInviteResult({
    required this.share,
  });

  final ReferralSharePayload share;

  factory ReferralInviteResult.fromJson(Map<String, dynamic> json) {
    final shareRaw = json['share'];
    return ReferralInviteResult(
      share: shareRaw is Map<String, dynamic>
          ? ReferralSharePayload.fromJson(shareRaw)
          : const ReferralSharePayload(),
    );
  }
}

class ReferralSharePayload {
  const ReferralSharePayload({
    this.whatsAppText,
    this.smsBody,
    this.downloadUrl,
    this.deepLink,
  });

  final String? whatsAppText;
  final String? smsBody;
  final String? downloadUrl;
  final String? deepLink;

  factory ReferralSharePayload.fromJson(Map<String, dynamic> json) {
    return ReferralSharePayload(
      whatsAppText: json['whatsAppText']?.toString(),
      smsBody: json['smsBody']?.toString(),
      downloadUrl: json['downloadUrl']?.toString(),
      deepLink: json['deepLink']?.toString(),
    );
  }
}

class ReferralInviteRow {
  const ReferralInviteRow({
    required this.id,
    required this.phone,
    required this.status,
    this.reason,
    this.createdAt,
  });

  final String id;
  final String phone;
  final String status;
  final String? reason;
  final DateTime? createdAt;

  factory ReferralInviteRow.fromJson(Map<String, dynamic> json) {
    return ReferralInviteRow(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      reason: json['reason']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

String _money(dynamic raw) {
  if (raw is num) return raw.toStringAsFixed(3);
  final parsed = double.tryParse(raw?.toString() ?? '');
  return parsed == null ? '0.000' : parsed.toStringAsFixed(3);
}
