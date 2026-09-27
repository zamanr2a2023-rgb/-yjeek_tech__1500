class RewardsWalletBucket {
  const RewardsWalletBucket({
    required this.available,
    required this.pending,
    required this.expiringSoon,
    required this.withdrawable,
    this.expiringSoonBy,
  });

  final String available;
  final String pending;
  final String expiringSoon;
  final String withdrawable;
  final DateTime? expiringSoonBy;

  factory RewardsWalletBucket.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RewardsWalletBucket(
        available: '0.000',
        pending: '0.000',
        expiringSoon: '0.000',
        withdrawable: '0.000',
      );
    }
    return RewardsWalletBucket(
      available: _money(json['available']),
      pending: _money(json['pending']),
      expiringSoon: _money(json['expiringSoon']),
      withdrawable: _money(json['withdrawable']),
      expiringSoonBy: DateTime.tryParse(json['expiringSoonBy']?.toString() ?? ''),
    );
  }

  String get availableLabel => 'BHD $available';
  String get pendingLabel => 'BHD $pending';
  String get expiringSoonLabel => 'BHD $expiringSoon';
  String get withdrawableLabel => 'BHD $withdrawable';
}

class RewardsSpinInfo {
  const RewardsSpinInfo({
    this.campaignId,
    this.spinsRemaining = 0,
    this.live = false,
  });

  final String? campaignId;
  final int spinsRemaining;
  final bool live;

  factory RewardsSpinInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RewardsSpinInfo();
    return RewardsSpinInfo(
      campaignId: json['campaignId']?.toString(),
      spinsRemaining: (json['spinsRemaining'] as num?)?.toInt() ?? 0,
      live: json['live'] == true,
    );
  }
}

class RewardsMission {
  const RewardsMission({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
  });

  final String id;
  final String title;
  final int progress;
  final int target;

  factory RewardsMission.fromJson(Map<String, dynamic> json) {
    return RewardsMission(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 0,
    );
  }
}

class RewardsSummary {
  const RewardsSummary({
    required this.wallet,
    required this.activeVoucherCount,
    required this.spin,
    required this.missions,
  });

  final RewardsWalletBucket wallet;
  final int activeVoucherCount;
  final RewardsSpinInfo spin;
  final List<RewardsMission> missions;

  static const empty = RewardsSummary(
    wallet: RewardsWalletBucket(
      available: '0.000',
      pending: '0.000',
      expiringSoon: '0.000',
      withdrawable: '0.000',
    ),
    activeVoucherCount: 0,
    spin: RewardsSpinInfo(),
    missions: [],
  );

  factory RewardsSummary.fromJson(Map<String, dynamic> json) {
    final walletRaw = json['wallet'];
    final vouchersRaw = json['vouchers'];
    final missionsRaw = json['missions'];
    final missions = <RewardsMission>[];
    if (missionsRaw is List) {
      for (final raw in missionsRaw) {
        if (raw is Map<String, dynamic>) {
          missions.add(RewardsMission.fromJson(raw));
        }
      }
    }
    return RewardsSummary(
      wallet: RewardsWalletBucket.fromJson(
        walletRaw is Map<String, dynamic> ? walletRaw : null,
      ),
      activeVoucherCount: vouchersRaw is Map
          ? (vouchersRaw['activeCount'] as num?)?.toInt() ?? 0
          : 0,
      spin: RewardsSpinInfo.fromJson(
        json['spin'] is Map<String, dynamic>
            ? json['spin'] as Map<String, dynamic>
            : null,
      ),
      missions: missions,
    );
  }
}

String _money(dynamic raw) {
  if (raw is num) return raw.toStringAsFixed(3);
  final parsed = double.tryParse(raw?.toString() ?? '');
  return parsed == null ? '0.000' : parsed.toStringAsFixed(3);
}
