import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class EditPersonalInfoScreen extends ConsumerStatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  ConsumerState<EditPersonalInfoScreen> createState() =>
      _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState
    extends ConsumerState<EditPersonalInfoScreen> {
  bool _loading = true;
  bool _saving = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();

  DateTime? _dateOfBirth;
  String _genderLabel = 'Prefer not to say';
  String _phoneLabel = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await ref.read(userRepositoryProvider).fetchMe();
      if (!mounted) return;
      if (me != null) {
        _nameController.text = me.displayName == 'Customer' ? '' : me.displayName;
        _emailController.text = me.email?.trim() ?? '';
        _dateOfBirth = me.profile.dateOfBirth;
        _dobController.text = me.profile.dateOfBirthLabel;
        _genderLabel = me.profile.gender != null
            ? me.profile.genderLabel
            : 'Prefer not to say';
        _phoneLabel = me.formattedPhone;
      }
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _genderApiValue(String label) {
    return switch (label) {
      'Female' => 'FEMALE',
      'Male' => 'MALE',
      'Prefer not to say' => 'OTHER',
      _ => 'OTHER',
    };
  }

  ({String firstName, String? lastName}) _splitName(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return (firstName: '', lastName: null);
    }
    if (parts.length == 1) {
      return (firstName: parts.first, lastName: '');
    }
    return (
      firstName: parts.first,
      lastName: parts.sublist(1).join(' '),
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13, now.month, now.day),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateOfBirth = picked;
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
      _dobController.text =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    final email = _emailController.text.trim();
    if (email.isNotEmpty && !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    final names = _splitName(name);
    final body = <String, dynamic>{
      'firstName': names.firstName,
      if (names.lastName != null && names.lastName!.isNotEmpty)
        'lastName': names.lastName,
      'email': email.isEmpty ? null : email,
      'gender': _genderApiValue(_genderLabel),
      if (_dateOfBirth != null)
        'dateOfBirth': DateTime.utc(
          _dateOfBirth!.year,
          _dateOfBirth!.month,
          _dateOfBirth!.day,
        ).toIso8601String(),
    };

    setState(() => _saving = true);
    final response =
        await ref.read(userRepositoryProvider).updateProfile(body);
    if (!mounted) return;
    setState(() => _saving = false);

    if (response.ok) {
      ref.invalidate(userMeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Profile updated')),
      );
      if (context.canPop()) context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Could not save changes'),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: NavigationStrings.editPersonalInfo,
            flat: true,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                    children: [
                      AccountFormField(
                        label: NavigationStrings.fullName,
                        controller: _nameController,
                        readOnly: false,
                        hintText: 'Your name',
                      ),
                      SizedBox(height: 14.h),
                      AccountFormField(
                        label: NavigationStrings.email,
                        controller: _emailController,
                        readOnly: false,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'email@example.com',
                      ),
                      SizedBox(height: 14.h),
                      AccountFormField(
                        label: NavigationStrings.dateOfBirth,
                        controller: _dobController,
                        readOnly: true,
                        onTap: _pickDob,
                        hintText: 'Select date',
                        suffix: Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: const Color(0xFF6B756E),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        NavigationStrings.gender,
                        style: AppTextStyles.labelSmall(
                          color: const Color(0xFF6B756E),
                        ).copyWith(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GenderChipRow(
                        selected: _genderLabel,
                        onSelected: (value) =>
                            setState(() => _genderLabel = value),
                      ),
                      SizedBox(height: 14.h),
                      AccountFormField(
                        label: NavigationStrings.phoneVerified,
                        value: _phoneLabel.isEmpty ? '—' : _phoneLabel,
                        valueColor: const Color(0xFF6B756E),
                        readOnly: true,
                        suffix: Text(
                          '✓ Verified',
                          style: AppTextStyles.labelSmall(
                            color: const Color(0xFF127036),
                          ).copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2EB),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ℹ️', style: TextStyle(fontSize: 13.sp)),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                NavigationStrings.changePhoneNote,
                                style: AppTextStyles.labelSmall(
                                  color: const Color(0xFF127036),
                                ).copyWith(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      PrimaryGreenButton(
                        label: _saving
                            ? 'Saving…'
                            : NavigationStrings.saveChanges,
                        height: 52,
                        backgroundColor: AppColors.cartTabActive,
                        enabled: !_saving,
                        onPressed: _saving ? null : _save,
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}
