import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_assets.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _AccountHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: _WalletCashbackRow(
                onWalletTap: () => context.push(RouteNames.wallet),
                onCashbackTap: () => context.push(RouteNames.walletCashback),
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
                  onTap: () => context.push(RouteNames.personalInfo),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountIdCard,
                  title: NavigationStrings.idVerification,
                  badge: NavigationStrings.notVerified,
                  onTap: () => context.push(RouteNames.idVerification),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountLocation,
                  title: NavigationStrings.savedAddresses,
                  trailing: '${WalletData.savedAddresses.length}',
                  onTap: () => context.push(RouteNames.savedAddresses),
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
                  onTap: () => context.goHome(tab: 1),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountWallet,
                  title: NavigationStrings.yjeekWallet,
                  onTap: () => context.push(RouteNames.wallet),
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
                  trailing: NavigationStrings.english,
                  onTap: () => context.push(RouteNames.language),
                ),
                ProfileMenuTile(
                  iconAsset: AppAssets.accountWorldGlobe,
                  iconSize: 24,
                  title: NavigationStrings.countryRegion,
                  trailing: NavigationStrings.bahrain,
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
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: ProfileMenuTile(
                iconAsset: AppAssets.accountLogout,
                title: NavigationStrings.logout,
                destructive: true,
                onTap: () {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Text(
                NavigationStrings.appVersion,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(
                  color: AppColors.textSecondary,
                ).copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
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
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    NavigationData.userName[0],
                    style: AppTextStyles.displayMedium(
                      color: AppColors.primary,
                    ).copyWith(fontSize: 24.sp),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NavigationData.userName,
                        style: AppTextStyles.titleSmall(
                          color: AppColors.white,
                        ).copyWith(fontSize: 20.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        NavigationData.userPhone,
                        style: AppTextStyles.bodyMedium(
                          color: const Color(0xFFDCE7D4),
                        ).copyWith(fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
    required this.onWalletTap,
    required this.onCashbackTap,
  });

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
                    NavigationData.walletBalance,
                    style: AppTextStyles.titleSmall().copyWith(fontSize: 18.sp),
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
                    WalletData.accountCashbackBalance,
                    style: AppTextStyles.titleSmall().copyWith(fontSize: 18.sp),
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
