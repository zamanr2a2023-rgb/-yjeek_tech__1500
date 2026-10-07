class ZoodBenefitCopy {
  const ZoodBenefitCopy({required this.emoji, required this.text});

  final String emoji;
  final String text;

  factory ZoodBenefitCopy.fromJson(Map<String, dynamic> json) {
    return ZoodBenefitCopy(
      emoji: json['emoji']?.toString() ?? '✦',
      text: json['text']?.toString() ?? '',
    );
  }
}

class ZoodBannerCopy {
  const ZoodBannerCopy({
    required this.show,
    required this.placement,
    required this.badge,
    required this.headline,
    required this.hint,
    required this.cta,
    required this.chips,
  });

  final bool show;
  final String placement;
  final String badge;
  final String headline;
  final String hint;
  final String cta;
  final List<String> chips;

  factory ZoodBannerCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ZoodBannerCopy(
        show: false,
        placement: 'BELOW_PAYMENT',
        badge: '',
        headline: '',
        hint: '',
        cta: '',
        chips: [],
      );
    }
    final chipsRaw = json['chips'];
    return ZoodBannerCopy(
      show: json['show'] == true,
      placement: json['placement']?.toString() ?? 'BELOW_PAYMENT',
      badge: json['badge']?.toString() ?? '',
      headline: json['headline']?.toString() ?? '',
      hint: json['hint']?.toString() ?? '',
      cta: json['cta']?.toString() ?? '',
      chips: chipsRaw is List
          ? chipsRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
          : const [],
    );
  }
}

class ZoodSheetCopy {
  const ZoodSheetCopy({
    required this.title,
    required this.subtitle,
    required this.joinCta,
    required this.dismissCta,
    required this.alreadyJoined,
    required this.benefits,
  });

  final String title;
  final String subtitle;
  final String joinCta;
  final String dismissCta;
  final String alreadyJoined;
  final List<ZoodBenefitCopy> benefits;

  factory ZoodSheetCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ZoodSheetCopy(
        title: '',
        subtitle: '',
        joinCta: '',
        dismissCta: '',
        alreadyJoined: '',
        benefits: [],
      );
    }
    final benefitsRaw = json['benefits'];
    return ZoodSheetCopy(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      joinCta: json['joinCta']?.toString() ?? '',
      dismissCta: json['dismissCta']?.toString() ?? '',
      alreadyJoined: json['alreadyJoined']?.toString() ?? '',
      benefits: benefitsRaw is List
          ? benefitsRaw
              .whereType<Map<String, dynamic>>()
              .map(ZoodBenefitCopy.fromJson)
              .where((b) => b.text.isNotEmpty)
              .toList()
          : const [],
    );
  }
}

class ZoodWaitingListRouteArgs {
  const ZoodWaitingListRouteArgs({this.promo, required this.joinScreen});

  final ZoodPromo? promo;
  final String joinScreen;
}

class ZoodPromo {
  const ZoodPromo({
    required this.joined,
    required this.dismissed,
    this.joinedAt,
    required this.banner,
    required this.sheet,
  });

  final bool joined;
  final bool dismissed;
  final DateTime? joinedAt;
  final ZoodBannerCopy banner;
  final ZoodSheetCopy sheet;

  factory ZoodPromo.fromJson(Map<String, dynamic> json) {
    DateTime? joinedAt;
    final rawJoinedAt = json['joinedAt'];
    if (rawJoinedAt is String && rawJoinedAt.isNotEmpty) {
      joinedAt = DateTime.tryParse(rawJoinedAt);
    }
    return ZoodPromo(
      joined: json['joined'] == true ||
          json['waitlistJoined'] == true ||
          json['zoodWaitlistJoinedAt'] != null,
      dismissed: json['dismissed'] == true ||
          json['waitlistDismissed'] == true ||
          json['zoodWaitlistDismissedAt'] != null,
      joinedAt: joinedAt,
      banner: ZoodBannerCopy.fromJson(
        json['banner'] is Map<String, dynamic>
            ? json['banner'] as Map<String, dynamic>
            : null,
      ),
      sheet: ZoodSheetCopy.fromJson(
        json['sheet'] is Map<String, dynamic>
            ? json['sheet'] as Map<String, dynamic>
            : null,
      ),
    );
  }
}
