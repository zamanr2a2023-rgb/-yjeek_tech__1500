import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class AboutYjeekScreen extends StatelessWidget {
  const AboutYjeekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const companyDetails = [
      ('Operator', 'Yjeek Technologies W.L.L'),
      ('CR No.', '110111-3'),
      ('Address', 'Building 2732, Road 3649, Block 436, Al Seef, Kingdom of Bahrain'),
      ('Governing law', 'Kingdom of Bahrain'),
      ('Phone', '+973 38866620'),
      ('Email', 'contact@yjeektech.com'),
      ('Web', 'www.yjeektech.com'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(
            title: NavigationStrings.aboutYjeek,
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2EB),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Y',
                      style: AppTextStyles.displayMedium(
                        color: const Color(0xFF2E9E4D),
                      ).copyWith(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  NavigationStrings.aboutYjeekIntro,
                  style: AppTextStyles.bodyMedium(
                    color: const Color(0xFF6B756E),
                  ).copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFDBE3DB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NavigationStrings.platformIncludes,
                        style: AppTextStyles.labelMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        NavigationStrings.platformIncludesBody,
                        style: AppTextStyles.bodyMedium(
                          color: const Color(0xFF6B756E),
                        ).copyWith(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFDBE3DB)),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < companyDetails.length; i++) ...[
                        if (i > 0) SizedBox(height: 10.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110.w,
                              child: Text(
                                companyDetails[i].$1,
                                style: AppTextStyles.labelSmall(
                                  color: const Color(0xFF6B756E),
                                ).copyWith(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                companyDetails[i].$2,
                                style: AppTextStyles.labelMedium(
                                  color: AppColors.textPrimary,
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5.sp,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
