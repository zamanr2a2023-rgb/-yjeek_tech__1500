import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key, this.bottomNavIndex = 4});

  final int bottomNavIndex;

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  String _category = HelpPhase2Data.faqCategories.first;
  int? _expandedIndex = 0;

  List<HelpFaqItem> get _filtered {
    if (_category == 'Wallet') return HelpPhase2Data.faqItems;
    return HelpPhase2Data.faqItems
        .where((item) => item.category == _category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return HelpScreenScaffold(
      title: 'Frequently asked',
      bottomNavIndex: widget.bottomNavIndex,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          const HelpSearchField(hint: 'Search questions…'),
          SizedBox(height: 14.h),
          SizedBox(
            height: 36.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: HelpPhase2Data.faqCategories.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final category = HelpPhase2Data.faqCategories[index];
                final active = category == _category;
                return GestureDetector(
                  onTap: () => setState(() {
                    _category = category;
                    _expandedIndex = _category == 'Wallet' ? 0 : null;
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: active ? AppColors.primary : const Color(0xFFE6EBE3),
                      ),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.labelSmall(
                        color: active ? AppColors.white : const Color(0xFF6B7B6E),
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 14.h),
          HelpCard(
            child: Column(
              children: [
                for (var i = 0; i < _filtered.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Color(0xFFE6EBE3)),
                  HelpChevronRow(
                    title: _filtered[i].question,
                    dense: true,
                    showDivider: false,
                    expanded: _expandedIndex == i,
                    onTap: () => setState(() {
                      _expandedIndex = _expandedIndex == i ? null : i;
                    }),
                  ),
                  if (_expandedIndex == i)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F7F2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        _filtered[i].answer,
                        style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E))
                            .copyWith(fontSize: 12.sp, height: 1.35),
                      ),
                    ),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: () => context.push(
              HelpRoutes.helpChat(variant: HelpChatVariant.support),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18.sp, color: const Color(0xFF2E7D32)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Didn’t find it? Report your issue — most are resolved instantly',
                      style: AppTextStyles.labelSmall(color: const Color(0xFF2E7D32)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        height: 1.35,
                      ),
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
