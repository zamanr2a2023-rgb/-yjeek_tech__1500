import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(userMeProvider);
    final me = meAsync.valueOrNull;
    final loading = meAsync.isLoading && me == null;

    Future<void> openEdit() async {
      await context.push(RouteNames.editPersonalInfo);
      ref.invalidate(userMeProvider);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.editProfileTitle),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: loading ? null : openEdit,
                          child: Column(
                          children: [
                            Container(
                              width: 80.w,
                              height: 80.w,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _initial(me),
                                style: AppTextStyles.displayMedium(
                                  color: AppColors.cartTabActive,
                                ).copyWith(fontSize: 28.sp),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt_outlined,
                                    size: 14.sp, color: AppColors.cartTabActive),
                                SizedBox(width: 6.w),
                                Text(
                                  NavigationStrings.changePhoto,
                                  style: AppTextStyles.labelSmall(
                                    color: AppColors.cartTabActive,
                                  ).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      AccountFormField(
                        label: NavigationStrings.fullName,
                        value: _name(me),
                        onTap: loading ? null : openEdit,
                      ),
                      SizedBox(height: 14.h),
                      AccountFormField(
                        label: NavigationStrings.phoneNumber,
                        value: me?.formattedPhone ?? '—',
                        onTap: loading ? null : openEdit,
                        suffix: me == null || me.isPhoneVerified
                            ? const VerifiedBadge()
                            : null,
                      ),
                      SizedBox(height: 14.h),
                      AccountFormField(
                        label: NavigationStrings.emailOptional,
                        value: (me?.email?.trim().isNotEmpty ?? false)
                            ? me!.email!.trim()
                            : '—',
                        onTap: loading ? null : openEdit,
                      ),
                      SizedBox(height: 14.h),
                      AccountFormField(
                        label: NavigationStrings.dobOptional,
                        value: (me?.profile.dateOfBirthLabel.isNotEmpty ?? false)
                            ? me!.profile.dateOfBirthLabel
                            : '—',
                        onTap: loading ? null : openEdit,
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        NavigationStrings.genderOptional,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 12.sp),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: loading ? null : openEdit,
                        child: GenderChipRow(
                          selected: me?.profile.genderLabel ?? '',
                        ),
                      ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: PrimaryGreenButton(
                label: NavigationStrings.saveChanges,
                onPressed: loading ? () {} : openEdit,
                enabled: !loading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _name(UserMe? me) {
    if (me == null) return '—';
    final name = me.displayName;
    return name == 'Customer' ? '—' : name;
  }

  String _initial(UserMe? me) {
    final name = _name(me);
    if (name == '—' || name.isEmpty) return '?';
    return name[0].toUpperCase();
  }
}
