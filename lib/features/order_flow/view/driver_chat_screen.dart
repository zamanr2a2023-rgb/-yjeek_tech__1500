import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DriverChatScreen extends StatelessWidget {
  const DriverChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _DriverChatHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9E0D9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Today',
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2EB),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '🛍 Order ${OrderFlowData.orderIdDisplay} · ${OrderFlowData.vendor}',
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFF127036),
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                for (final message in OrderFlowData.driverMessages)
                  DriverChatBubble(message: message),
                SizedBox(height: 8.h),
                const DriverChatQuickReplies(replies: OrderFlowData.chatQuickReplies),
              ],
            ),
          ),
          const DriverChatInputBar(),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 1),
    );
  }
}

class _DriverChatHeader extends StatelessWidget {
  const _DriverChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            NavCircleBackButton(
              onTap: () => Navigator.of(context).maybePop(),
              iconColor: AppColors.textPrimary,
            ),
            SizedBox(width: 10.w),
            Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2EB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.person_outline,
                color: AppColors.cartTabActive,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OrderFlowData.driverName,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    OrderFlowStrings.onlineChamp,
                    style: AppTextStyles.labelSmall(color: AppColors.cartTabActive).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2EB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.phone_outlined,
                color: const Color(0xFF127036),
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
