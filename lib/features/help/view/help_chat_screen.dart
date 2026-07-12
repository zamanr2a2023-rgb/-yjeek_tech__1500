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
      bottomNavIndex: bottomNavIndex,
      showBottomNav: false,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
              children: [
                _ChatStatusRow(label: HelpPhase2Data.chatStatusFor(variant)),
                SizedBox(height: 12.h),
                for (final message in messages) ...[
                  HelpChatBubble(message: message),
                  if (message.quickReplies.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 38.w),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: message.quickReplies
                            .map((reply) => _QuickReplyChip(label: reply))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 4.h),
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

class _ChatStatusRow extends StatelessWidget {
  const _ChatStatusRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption(color: const Color(0xFF3D4842)).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.5.sp,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  const _QuickReplyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
