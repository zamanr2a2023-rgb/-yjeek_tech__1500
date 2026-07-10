import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class HelpPoliciesLegalScreen extends StatelessWidget {
  const HelpPoliciesLegalScreen({super.key, this.bottomNavIndex = 4});

  final int bottomNavIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(
            title: NavigationStrings.aboutPolicies,
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
              children: const [
                AboutPoliciesList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: bottomNavIndex),
    );
  }
}
