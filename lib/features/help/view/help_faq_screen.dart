import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';

class HelpFaqScreen extends ConsumerStatefulWidget {
  const HelpFaqScreen({super.key, this.bottomNavIndex = 4});

  final int bottomNavIndex;

  @override
  ConsumerState<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends ConsumerState<HelpFaqScreen> {
  bool _loading = true;
  List<HelpFaqItem> _apiItems = const [];
  String _category = 'All';
  int? _expandedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final help = await ref.read(contentRepositoryProvider).fetchHelp();
    if (!mounted) return;
    final apiItems = help?.faq
            .map((e) => HelpFaqItem(category: 'All', question: e.q, answer: e.a))
            .toList() ??
        const <HelpFaqItem>[];
    setState(() {
      _apiItems = apiItems;
      _loading = false;
      _expandedIndex = apiItems.isNotEmpty || HelpPhase2Data.faqItems.isNotEmpty
          ? 0
          : null;
    });
  }

  List<String> get _categories {
    if (_apiItems.isNotEmpty) {
      return const ['All', ...HelpPhase2Data.faqCategories];
    }
    return HelpPhase2Data.faqCategories;
  }

  List<HelpFaqItem> get _filtered {
    if (_apiItems.isNotEmpty && (_category == 'All' || _category == 'General')) {
      return _apiItems;
    }
    final staticItems = HelpPhase2Data.faqItems;
    if (_category == 'All' || _category == 'Wallet') {
      return _apiItems.isNotEmpty ? _apiItems : staticItems;
    }
    return staticItems.where((item) => item.category == _category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return HelpScreenScaffold(
      title: 'Frequently asked',
      bottomNavIndex: widget.bottomNavIndex,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                children: [
                  const HelpSearchField(hint: 'Search questions…'),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 36.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final active = category == _category;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _category = category;
                            _expandedIndex = 0;
                          }),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  active ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : const Color(0xFFE6EBE3),
                              ),
                            ),
                            child: Text(
                              category,
                              style: AppTextStyles.labelSmall(
                                color: active
                                    ? AppColors.white
                                    : const Color(0xFF6B7B6E),
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                              ),
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
                        if (items.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(14.w),
                            child: Text(
                              'No questions yet',
                              style: AppTextStyles.labelSmall(
                                color: const Color(0xFF6B7B6E),
                              ),
                            ),
                          ),
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: Color(0xFFE6EBE3)),
                          HelpChevronRow(
                            title: items[i].question,
                            dense: true,
                            showDivider: false,
                            expanded: _expandedIndex == i,
                            onTap: () => setState(() {
                              _expandedIndex =
                                  _expandedIndex == i ? null : i;
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
                                items[i].answer,
                                style: AppTextStyles.labelSmall(
                                  color: const Color(0xFF6B7B6E),
                                ).copyWith(fontSize: 12.sp, height: 1.35),
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
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18.sp,
                            color: const Color(0xFF2E7D32),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Didn’t find it? Report your issue — most are resolved instantly',
                              style: AppTextStyles.labelSmall(
                                color: const Color(0xFF2E7D32),
                              ).copyWith(
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
            ),
    );
  }
}
