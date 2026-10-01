import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/api_constants.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/auth/utils/require_login.dart';
import 'package:yjeek_app/features/navigation/model/user_me.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';
import 'package:yjeek_app/features/ui_content/view/ui_banner_widgets.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final storage = ref.read(storageServiceProvider);
    await ref.read(authApiProvider).logout(bearerToken: storage.token);
    await storage.clearSession();
    ref.invalidate(userMeProvider);
    ref.invalidate(notificationsUnreadCountProvider);
    if (!context.mounted) return;
    context.go(RouteNames.welcome);
  }

  Future<void> _requireSignIn(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onSignedIn,
  ) async {
    if (!await requireLogin(context, ref)) return;
    if (!context.mounted) return;
    onSignedIn();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(storageServiceProvider).hasSession;
    final userAsync = ref.watch(userMeProvider);
    final user = loggedIn ? userAsync.valueOrNull : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _AccountHeader(
              user: user,
              loggedIn: loggedIn,
              unreadCount:
                  ref.watch(notificationsUnreadCountProvider).valueOrNull ?? 0,
              onNotificationsTap: () {
                if (!loggedIn) {
                  _requireSignIn(
                    context,
                    ref,
                    () => context.push(RouteNames.notifications),
                  );
                  return;
                }
                context.push(RouteNames.notifications);
              },
              onSignIn: () => _requireSignIn(context, ref, () {}),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: UiPlacementBanner(placementKey: 'account_promo'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: _WalletCashbackRow(
                loggedIn: loggedIn,
                balanceLabel: user?.wallet.balanceLabel ?? 'BHD 0.000',
                cashbackLabel: user?.wallet.cashbackLabel ?? 'BHD 0.000',
                onWalletTap: () {
                  if (!loggedIn) {
                    _requireSignIn(
                      context,
                      ref,
                      () => context.push(RouteNames.wallet),
                    );
                    return;
                  }
                  context.push(RouteNames.wallet);
                },
                onCashbackTap: () {
                  if (!loggedIn) {
                    _requireSignIn(
                      context,
                      ref,
                      () => context.push(RouteNames.walletCashback),
                    );
                    return;
                  }
                  context.push(RouteNames.walletCashback);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ProfileMenuSection(
              title: 'ACCOUNT',
              children: [
                ProfileMenuTile(
                  iconAsset: AppAssets.accountPersonal,
                  title: NavigationStrings.personalInfo,
                  trailing: loggedIn ? null : NavigationStrings.signInToView,
                  onTap: loggedIn
                      ? () => context.push(RouteNames.personalInfo)
                      : () => _requireSignIn(
                            context,
                            ref,
                            () => context.push(RouteNames.personalInfo),
                          ),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountIdCard,
                  title: NavigationStrings.idVerification,
                  badge: loggedIn
                      ? (user?.verificationBadge ?? NavigationStrings.notVerified)
                      : null,
                  trailing: loggedIn ? null : NavigationStrings.signInToView,
                  onTap: loggedIn
                      ? () => context.push(RouteNames.idVerification)
                      : () => _requireSignIn(
                            context,
                            ref,
                            () => context.push(RouteNames.idVerification),
                          ),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountLocation,
                  title: NavigationStrings.savedAddresses,
                  trailing: loggedIn
                      ? '${user?.profile.addressCount ?? 0}'
                      : NavigationStrings.signInToView,
                  onTap: loggedIn
                      ? () => context.push(RouteNames.savedAddresses)
                      : () => _requireSignIn(
                            context,
                            ref,
                            () => context.push(RouteNames.savedAddresses),
                          ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: ProfileMenuSection(
              title: 'ACTIVITY',
              children: [
                ProfileMenuTile(
                  iconAsset: AppAssets.accountOrderHistory,
                  title: NavigationStrings.orderHistory,
                  trailing: loggedIn ? null : NavigationStrings.signInToView,
                  onTap: loggedIn
                      ? () => context.goHome(tab: 1)
                      : () => _requireSignIn(
                            context,
                            ref,
                            () => context.goHome(tab: 1),
                          ),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.walletCashBack,
                  title: 'My Rewards',
                  trailing: loggedIn ? null : NavigationStrings.signInToView,
                  onTap: loggedIn
                      ? () => context.push(RouteNames.rewards)
                      : () => _requireSignIn(
                            context,
                            ref,
                            () => context.push(RouteNames.rewards),
                          ),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountHelp,
                  title: 'Invite a friend',
                  trailing: loggedIn ? null : NavigationStrings.signInToView,
                  onTap: loggedIn
                      ? () => context.push(RouteNames.referral)
                      : () => _requireSignIn(
                            context,
                            ref,
                            () => context.push(RouteNames.referral),
                          ),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountWallet,
                  title: NavigationStrings.yjeekWallet,
                  trailing: loggedIn ? null : NavigationStrings.signInToView,
                  onTap: loggedIn
                      ? () => context.push(RouteNames.wallet)
                      : () => _requireSignIn(
                            context,
                            ref,
                            () => context.push(RouteNames.wallet),
                          ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: ProfileMenuSection(
              title: 'SETTINGS',
              children: [
                ProfileMenuTile(
                  iconAsset: AppAssets.accountGlobe,
                  title: NavigationStrings.language,
                  trailing: user?.profile.languageLabel ?? NavigationStrings.english,
                  onTap: () => context.push(RouteNames.language),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountWorldGlobe,
                  iconSize: 24,
                  title: NavigationStrings.countryRegion,
                  trailing: user?.profile.countryLabel ?? NavigationStrings.bahrain,
                  onTap: () => context.push(RouteNames.countryRegion),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: ProfileMenuSection(
              title: 'SUPPORT',
              children: [
                ProfileMenuTile(
                  iconAsset: AppAssets.accountHelp,
                  title: NavigationStrings.helpSupport,
                  onTap: () => context.push(RouteNames.helpSupport),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountInfo,
                  title: NavigationStrings.aboutPolicies,
                  onTap: () => context.push(RouteNames.aboutPolicies),
                ),
                if (kDebugMode || ApiConstants.isLikelyUatBackend)
                  ProfileMenuTile(
                    iconAsset: AppAssets.payBenefitPay,
                    title: 'BenefitPay Test Payment',
                    onTap: () => context.push(RouteNames.benefitPayCertTest),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: loggedIn
                  ? ProfileMenuTile(
                      iconAsset: AppAssets.accountLogout,
                      title: NavigationStrings.logout,
                      destructive: true,
                      onTap: () => _logout(context, ref),
                    )
                  : ProfileMenuTile(
                      icon: Icons.login_rounded,
                      title: NavigationStrings.signIn,
                      onTap: () => _requireSignIn(context, ref, () {}),
                    ),
            ),
          ),
          if (loggedIn)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                child: const _AccountDeletionLink(),
              ),
            )
          else
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}

class _AccountDeletionLink extends ConsumerStatefulWidget {
  const _AccountDeletionLink();

  @override
  ConsumerState<_AccountDeletionLink> createState() =>
      _AccountDeletionLinkState();
}

class _AccountDeletionLinkState extends ConsumerState<_AccountDeletionLink> {
  bool _deleting = false;

  Future<void> _deleteAccount() async {
    if (_deleting) return;
    if (!await requireLogin(context, ref)) return;
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(NavigationStrings.deleteAccountConfirmTitle),
        content: Text(NavigationStrings.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(NavigationStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9B111E),
            ),
            child: Text(NavigationStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    final response = await ref.read(userRepositoryProvider).deleteAccount();
    if (!mounted) return;

    if (response.ok) {
      final storage = ref.read(storageServiceProvider);
      await ref.read(authApiProvider).logout(bearerToken: storage.token);
      await storage.clearSession();
      ref.invalidate(userMeProvider);
      ref.invalidate(notificationsUnreadCountProvider);
      if (!mounted) return;
      context.go(RouteNames.welcome);
      return;
    }

    setState(() => _deleting = false);
    if (await redirectToLoginIfAuthError(context, ref, response.message)) {
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.message ?? NavigationStrings.couldNotDeleteAccount,
        ),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _deleting ? null : _deleteAccount,
      behavior: HitTestBehavior.opaque,
      child: Text(
        _deleting
            ? NavigationStrings.deleting
            : NavigationStrings.accountDeletion,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption(
          color: AppColors.textSecondary,
        ).copyWith(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    this.user,
    this.loggedIn = true,
    this.unreadCount = 0,
    this.onNotificationsTap,
    this.onSignIn,
  });

  final UserMe? user;
  final bool loggedIn;
  final int unreadCount;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final name =
        loggedIn ? (user?.displayName ?? 'Customer') : NavigationStrings.guest;
    final phone = loggedIn
        ? (user?.formattedPhone ?? '')
        : NavigationStrings.signInToView;
    final letter = loggedIn ? (user?.avatarLetter ?? 'C') : '?';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  NavigationStrings.account,
                  style: AppTextStyles.titleSmall(
                    color: AppColors.white,
                  ).copyWith(fontSize: 18.sp),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onNotificationsTap,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 34.w,
                    height: 34.w,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E9B47),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            color: AppColors.white,
                            size: 18.sp,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -2.h,
                            right: -2.w,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 16.w),
                              height: 16.w,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDB2626),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: AppTextStyles.displayMedium(
                      color: AppColors.primary,
                    ).copyWith(fontSize: 20.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.titleSmall(
                          color: AppColors.white,
                        ).copyWith(fontSize: 18.sp),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        phone,
                        style: AppTextStyles.bodyMedium(
                          color: const Color(0xFFDCE7D4),
                        ).copyWith(fontSize: 12.5.sp),
                      ),
                    ],
                  ),
                ),
                if (loggedIn)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.white,
                        width: 1.4,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => context.push(RouteNames.editPersonalInfo),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 15.sp,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            NavigationStrings.editProfile,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.white,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onSignIn,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        NavigationStrings.signIn,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.primary,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletCashbackRow extends StatelessWidget {
  const _WalletCashbackRow({
    required this.loggedIn,
    required this.balanceLabel,
    required this.cashbackLabel,
    required this.onWalletTap,
    required this.onCashbackTap,
  });

  final bool loggedIn;
  final String balanceLabel;
  final String cashbackLabel;
  final VoidCallback onWalletTap;
  final VoidCallback onCashbackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onWalletTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        AppAssets.accountWallet,
                        width: 17.w,
                        height: 17.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        NavigationStrings.yjeekWallet,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textSecondary,
                        ).copyWith(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    loggedIn
                        ? balanceLabel
                        : NavigationStrings.signInToView,
                    style: AppTextStyles.titleSmall().copyWith(
                      fontSize: loggedIn ? 18.sp : 13.sp,
                      color: loggedIn
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 38.h, color: const Color(0xFFE6EBE3)),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: onCashbackTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 17.sp,
                        color: const Color(0xFFC9A84C),
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        NavigationStrings.cashback,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textSecondary,
                        ).copyWith(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    loggedIn
                        ? cashbackLabel
                        : NavigationStrings.signInToView,
                    style: AppTextStyles.titleSmall().copyWith(
                      fontSize: loggedIn ? 18.sp : 13.sp,
                      color: loggedIn
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
