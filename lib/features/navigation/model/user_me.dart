class UserMe {
  const UserMe({
    required this.id,
    required this.phone,
    required this.countryCode,
    required this.role,
    required this.status,
    required this.profile,
    required this.wallet,
    required this.verification,
  });

  final String id;
  final String phone;
  final String countryCode;
  final String role;
  final String status;
  final UserProfile profile;
  final UserWallet wallet;
  final UserVerification verification;

  factory UserMe.fromJson(Map<String, dynamic> json) {
    return UserMe(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      countryCode: json['countryCode']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      profile: UserProfile.fromJson(
        (json['profile'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      wallet: UserWallet.fromJson(
        (json['wallet'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      verification: UserVerification.fromJson(
        (json['verification'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  String get displayName {
    final fromProfile = profile.displayName?.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;

    final first = profile.firstName?.trim() ?? '';
    final last = profile.lastName?.trim() ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;

    return 'Customer';
  }

  String get avatarLetter {
    final name = displayName.trim();
    if (name.isNotEmpty && name != 'Customer') return name[0].toUpperCase();
    if (phone.isNotEmpty) return phone[0].toUpperCase();
    return 'Y';
  }

  String get formattedPhone {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final spaced = digits.length <= 4
        ? digits
        : '${digits.substring(0, 4)} ${digits.substring(4)}';
    final code = countryCode.trim();
    if (code.isEmpty) return spaced;
    return '$code $spaced';
  }

  String get verificationBadge {
    final raw = verification.status.trim();
    if (raw.isEmpty) return 'NOT VERIFIED';
    return raw.replaceAll('_', ' ').toUpperCase();
  }
}

class UserProfile {
  const UserProfile({
    this.firstName,
    this.lastName,
    this.displayName,
    this.avatarUrl,
    this.language = 'en',
    this.country = 'BH',
    this.addressCount = 0,
  });

  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? avatarUrl;
  final String language;
  final String country;
  final int addressCount;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      displayName: json['displayName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      language: json['language']?.toString() ?? 'en',
      country: json['country']?.toString() ?? 'BH',
      addressCount: (json['addressCount'] as num?)?.toInt() ?? 0,
    );
  }

  String get languageLabel {
    switch (language.toLowerCase()) {
      case 'ar':
        return 'Arabic';
      case 'en':
      default:
        return 'English';
    }
  }

  String get countryLabel {
    switch (country.toUpperCase()) {
      case 'BH':
        return 'Bahrain';
      default:
        return country;
    }
  }
}

class UserWallet {
  const UserWallet({this.balance = 0, this.cashback = 0});

  final num balance;
  final num cashback;

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      balance: json['balance'] as num? ?? 0,
      cashback: json['cashback'] as num? ?? 0,
    );
  }

  String get balanceLabel => _formatBhd(balance);
  String get cashbackLabel => _formatBhd(cashback);

  static String _formatBhd(num value) {
    return 'BHD ${value.toStringAsFixed(3)}';
  }
}

class UserVerification {
  const UserVerification({this.status = 'NOT_VERIFIED'});

  final String status;

  factory UserVerification.fromJson(Map<String, dynamic> json) {
    return UserVerification(status: json['status']?.toString() ?? 'NOT_VERIFIED');
  }
}
