import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenScreenHeader(title: NavigationStrings.editProfileTitle),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
              children: [
                Center(
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
                          NavigationData.userName[0],
                          style: AppTextStyles.displayMedium(
                            color: AppColors.cartTabActive,
                          ).copyWith(fontSize: 28.sp),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 14.sp, color: AppColors.cartTabActive),
                          SizedBox(width: 6.w),
                          Text(
                            NavigationStrings.changePhoto,
                            style: AppTextStyles.labelSmall(
                              color: AppColors.cartTabActive,
                            ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                AccountFormField(label: NavigationStrings.fullName, value: NavigationData.userName),
                SizedBox(height: 14.h),
                AccountFormField(
                  label: NavigationStrings.phoneNumber,
                  value: NavigationData.userPhone,
                  suffix: const VerifiedBadge(),
                ),
                SizedBox(height: 14.h),
                AccountFormField(label: NavigationStrings.emailOptional, value: WalletData.userEmail),
                SizedBox(height: 14.h),
                AccountFormField(label: NavigationStrings.dobOptional, value: WalletData.userDob),
                SizedBox(height: 14.h),
                Text(
                  NavigationStrings.genderOptional,
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                GenderChipRow(selected: WalletData.userGender),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: PrimaryGreenButton(
                label: NavigationStrings.saveChanges,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
