import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  bool _deleting = false;

  Future<void> _openEdit() async {
    await context.push(RouteNames.editPersonalInfo);
    ref.invalidate(userMeProvider);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account. Active orders must be finished first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF9B111E)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    final response = await ref.read(userRepositoryProvider).deleteAccount();
    if (!mounted) return;
    setState(() => _deleting = false);

    if (response.ok) {
      final storage = ref.read(storageServiceProvider);
      await ref.read(authApiProvider).logout(bearerToken: storage.token);
      await storage.clearSession();
      ref.invalidate(userMeProvider);
      if (!mounted) return;
      context.go(RouteNames.welcome);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Could not delete account'),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(userMeProvider);
    final me = meAsync.valueOrNull;
    final loading = meAsync.isLoading && me == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(
            title: NavigationStrings.personalInfo,
            trailing: GestureDetector(
              onTap: _openEdit,
              child: Text(
                NavigationStrings.edit,
                style: AppTextStyles.labelSmall(color: AppColors.white).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(userMeProvider);
                      await ref.read(userMeProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      children: [
                        _InfoCard(
                          children: [
                            AccountInfoRow(
                              iconAsset: AppAssets.accountPersonal,
                              label: NavigationStrings.fullName,
                              value: _name(me),
                            ),
                            const Divider(height: 1, color: Color(0xFFE6EBE3)),
                            AccountInfoRow(
                              icon: Icons.phone_outlined,
                              label: NavigationStrings.phoneNumber,
                              value: me?.formattedPhone ?? '—',
                              suffix: me == null || me.isPhoneVerified
                                  ? const VerifiedBadge()
                                  : null,
                            ),
                            const Divider(height: 1, color: Color(0xFFE6EBE3)),
                            AccountInfoRow(
                              iconAsset: AppAssets.accountEmail,
                              label: NavigationStrings.email,
                              value: (me?.email?.trim().isNotEmpty ?? false)
                                  ? me!.email!.trim()
                                  : '—',
                            ),
                            const Divider(height: 1, color: Color(0xFFE6EBE3)),
                            AccountInfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: NavigationStrings.dateOfBirth,
                              value: (me?.profile.dateOfBirthLabel.isNotEmpty ??
                                      false)
                                  ? me!.profile.dateOfBirthLabel
                                  : '—',
                            ),
                            const Divider(height: 1, color: Color(0xFFE6EBE3)),
                            AccountInfoRow(
                              iconAsset: AppAssets.accountStar,
                              label: NavigationStrings.memberSince,
                              value: me?.memberSinceLabel ?? '—',
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        SectionHeaderLabel(label: NavigationStrings.accountActions),
                        _InfoCard(
                          children: [
                            AccountActionRow(
                              icon: Icons.phone_outlined,
                              title: NavigationStrings.changePhone,
                              onTap: () async {
                                await context.push(RouteNames.changePhone);
                                ref.invalidate(userMeProvider);
                              },
                            ),
                            const Divider(height: 1, color: Color(0xFFE6EBE3)),
                            AccountActionRow(
                              iconAsset: AppAssets.accountShield,
                              title: NavigationStrings.privacyData,
                              onTap: () => context.push(
                                '${RouteNames.policyDocument}?type=privacy',
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE6EBE3)),
                            AccountActionRow(
                              iconAsset: AppAssets.accountDelete,
                              title: _deleting
                                  ? 'Deleting…'
                                  : NavigationStrings.deleteAccount,
                              destructive: true,
                              onTap: _deleting ? null : _deleteAccount,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        const PrivacyFooterBanner(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }

  String _name(UserMe? me) {
    if (me == null) return '—';
    final name = me.displayName;
    return name == 'Customer' ? '—' : name;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
