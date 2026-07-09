import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class EditPersonalInfoScreen extends StatelessWidget {
  const EditPersonalInfoScreen({super.key});

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
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              children: [
                AccountFormField(
                  label: NavigationStrings.fullName,
                  value: NavigationData.userName,
                ),
                SizedBox(height: 14.h),
                AccountFormField(
                  label: NavigationStrings.email,
                  value: WalletData.userEmail,
                ),
                SizedBox(height: 14.h),
                AccountFormField(
                  label: NavigationStrings.dateOfBirth,
                  value: WalletData.userDob,
                ),
                SizedBox(height: 14.h),
                Text(
                  NavigationStrings.gender,
                  style: AppTextStyles.labelSmall(
                    color: const Color(0xFF6B756E),
                  ).copyWith(fontSize: 12.5.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                GenderChipRow(selected: WalletData.userGender),
                SizedBox(height: 14.h),
                AccountFormField(
                  label: NavigationStrings.phoneVerified,
                  value: NavigationData.userPhone,
                  valueColor: const Color(0xFF6B756E),
                  suffix: Text(
                    '✓ Verified',
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF127036),
                    ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                          ).copyWith(fontSize: 12.5.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label: NavigationStrings.saveChanges,
                  height: 52,
                  backgroundColor: AppColors.cartTabActive,
                  onPressed: () => context.pop(),
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
