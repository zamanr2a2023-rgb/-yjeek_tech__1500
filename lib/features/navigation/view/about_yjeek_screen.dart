import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/content_repository.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class AboutYjeekScreen extends ConsumerStatefulWidget {
  const AboutYjeekScreen({super.key});

  @override
  ConsumerState<AboutYjeekScreen> createState() => _AboutYjeekScreenState();
}

class _AboutYjeekScreenState extends ConsumerState<AboutYjeekScreen> {
  bool _loading = true;
  AboutContent? _content;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final content = await ref.read(contentRepositoryProvider).fetchAbout();
    if (!mounted) return;
    setState(() {
      _content = content;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final details = content?.companyDetails ??
        const [
          ('Operator', 'Yjeek Technologies W.L.L'),
          ('CR No.', '110111-3'),
          (
            'Address',
            'Building 2732, Road 3649, Block 436, Al Seef, Kingdom of Bahrain'
          ),
          ('Governing law', 'Kingdom of Bahrain'),
          ('Phone', '+973 38866620'),
          ('Email', 'contact@yjeektech.com'),
          ('Web', 'www.yjeek.com'),
        ];
    final description = content?.description.isNotEmpty == true
        ? content!.description
        : NavigationStrings.aboutYjeekIntro;
    final platformTitle = content?.platformTitle.isNotEmpty == true
        ? content!.platformTitle
        : NavigationStrings.platformIncludes;
    final platformBody = content?.platformBody.isNotEmpty == true
        ? content!.platformBody
        : NavigationStrings.platformIncludesBody;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(
            title: content?.title ?? NavigationStrings.aboutYjeek,
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                          description,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFDBE3DB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                platformTitle,
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
                                platformBody,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFDBE3DB)),
                          ),
                          child: Column(
                            children: [
                              for (var i = 0; i < details.length; i++) ...[
                                if (i > 0) SizedBox(height: 10.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 110.w,
                                      child: Text(
                                        details[i].$1,
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
                                        details[i].$2,
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
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}
