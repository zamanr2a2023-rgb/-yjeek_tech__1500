import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';

class HelpChatScreen extends StatelessWidget {
  const HelpChatScreen({
    super.key,
    required this.variant,
    this.bottomNavIndex = 4,
  });

  final HelpChatVariant variant;
  final int bottomNavIndex;

  @override
  Widget build(BuildContext context) {
    final messages = HelpPhase2Data.messagesFor(variant);

    return HelpScreenScaffold(
      title: HelpPhase2Data.chatTitleFor(variant),
      subtitle: HelpPhase2Data.chatSubtitleFor(variant),
      bottomNavIndex: bottomNavIndex,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              children: [
                for (final message in messages) ...[
                  HelpChatBubble(message: message),
                  if (message.quickReplies.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: message.quickReplies
                          .map(
                            (reply) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: const Color(0xFFE6EBE3)),
                              ),
                              child: Text(
                                reply,
                                style: AppTextStyles.labelSmall(
                                  color: const Color(0xFF6B7B6E),
                                ).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const HelpChatInputBar(),
        ],
      ),
    );
  }
}
