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
    this.email,
    this.createdAt,
    this.phoneVerifiedAt,
  });

  final String id;
  final String phone;
  final String countryCode;
  final String? email;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? phoneVerifiedAt;
  final UserProfile profile;
  final UserWallet wallet;
  final UserVerification verification;

  factory UserMe.fromJson(Map<String, dynamic> json) {
    return UserMe(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      countryCode: json['countryCode']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal(),
      phoneVerifiedAt:
          DateTime.tryParse(json['phoneVerifiedAt']?.toString() ?? '')?.toLocal(),
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

  bool get isPhoneVerified => phoneVerifiedAt != null;

  String get memberSinceLabel {
    final dt = createdAt;
    if (dt == null) return '—';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
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
    this.dateOfBirth,
    this.gender,
  });

  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? avatarUrl;
  final String language;
  final String country;
  final int addressCount;
  final DateTime? dateOfBirth;
  final String? gender;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? dob;
    final rawDob = json['dateOfBirth'];
    if (rawDob != null) {
      dob = DateTime.tryParse(rawDob.toString())?.toLocal();
    }
    return UserProfile(
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      displayName: json['displayName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      language: json['language']?.toString() ?? 'en',
      country: json['country']?.toString() ?? 'BH',
      addressCount: (json['addressCount'] as num?)?.toInt() ?? 0,
      dateOfBirth: dob,
      gender: json['gender']?.toString(),
    );
  }

  /// UI label for gender chips.
  String get genderLabel {
    return switch ((gender ?? '').toUpperCase()) {
      'FEMALE' => 'Female',
      'MALE' => 'Male',
      'OTHER' => 'Prefer not to say',
      _ => 'Prefer not to say',
    };
  }

  String get dateOfBirthLabel {
    final dt = dateOfBirth;
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String get languageLabel {
    switch (language.toLowerCase()) {
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }

  String get countryLabel {
    switch (country.toUpperCase()) {
      case 'BH':
        return 'Bahrain';
      case 'KW':
        return 'Kuwait';
      case 'SA':
        return 'KSA';
      case 'AE':
        return 'UAE';
      case 'OM':
        return 'Oman';
      case 'QA':
        return 'Qatar';
      case 'JO':
        return 'Jordan';
      case 'EG':
        return 'Egypt';
      case 'IQ':
        return 'Iraq';
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
