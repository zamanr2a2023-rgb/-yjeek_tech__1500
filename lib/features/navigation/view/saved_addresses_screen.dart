import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.savedAddresses),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              children: [
                for (var i = 0; i < WalletData.savedAddresses.length; i++) ...[
                  if (i > 0) SizedBox(height: 14.h),
                  _AddressCard(address: WalletData.savedAddresses[i]),
                ],
                SizedBox(height: 14.h),
                GestureDetector(
                  onTap: () => context.push(RouteNames.addAddress),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(13.r),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: 18.sp,
                          color: const Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          NavigationStrings.addNewAddress,
                          style: AppTextStyles.labelMedium(
                            color: const Color(0xFF2E7D32),
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
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

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final SavedAddress address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : const Color(0xFFE6EBE3),
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AddressIconBadge(
            iconAsset: address.iconAsset,
            icon: address.icon,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.label,
                      // Figma labels (Home / Work / Mum's place): #1A1A1A.
                      style: AppTextStyles.labelMedium(
                        color: const Color(0xFF1A1A1A),
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                      ),
                    ),
                    if (address.isDefault) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.accountIconBackground,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          NavigationStrings.defaultLabel,
                          style: AppTextStyles.caption(
                            color: const Color(0xFF2E7D32),
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 9.5.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  address.address,
                  style: AppTextStyles.labelSmall(
                    color: const Color(0xFF6B7B6E),
                  ).copyWith(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit_outlined,
            size: 18.sp,
            color: const Color(0xFF6B7B6E),
          ),
        ],
      ),
    );
  }
}

class _AddressIconBadge extends StatelessWidget {
  const _AddressIconBadge({
    this.iconAsset,
    this.icon,
  }) : assert(iconAsset != null || icon != null);

  final String? iconAsset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: AppColors.accountIconBackground,
        borderRadius: BorderRadius.circular(11.r),
      ),
      alignment: Alignment.center,
      child: iconAsset != null
          ? Image.asset(
              iconAsset!,
              width: 21.w,
              height: 21.w,
              fit: BoxFit.contain,
            )
          : Icon(
              icon,
              size: 21.w,
              color: const Color(0xFF2E7D32),
            ),
    );
  }
}
