import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

enum PolicyType { terms, privacy, refund }

extension PolicyTypeX on PolicyType {
  static PolicyType fromQuery(String? value) => switch (value) {
        'privacy' => PolicyType.privacy,
        'refund' => PolicyType.refund,
        _ => PolicyType.terms,
      };

  String get title => switch (this) {
        PolicyType.terms => NavigationStrings.termsConditions,
        PolicyType.privacy => NavigationStrings.privacyPolicy,
        PolicyType.refund => NavigationStrings.refundReturn,
      };

  String get intro => switch (this) {
        PolicyType.terms => WalletData.termsIntro,
        PolicyType.privacy => WalletData.privacyIntro,
        PolicyType.refund => WalletData.refundIntro,
      };

  List<PolicySection> get sections => switch (this) {
        PolicyType.terms => WalletData.termsSections,
        PolicyType.privacy => WalletData.privacySections,
        PolicyType.refund => WalletData.refundSections,
      };
}

class PolicyDocumentScreen extends StatelessWidget {
  const PolicyDocumentScreen({super.key, required this.type});

  final PolicyType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(title: type.title, backIconColor: AppColors.textPrimary),
          Expanded(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
                children: [
                  Text(
                    type.intro,
                    style: PolicyTypography.intro(),
                  ),
                  SizedBox(height: 14.h),
                  ...type.sections.asMap().entries.map((entry) {
                    final isLast = entry.key == type.sections.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
                      child: PolicySectionCard(section: entry.value),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}
