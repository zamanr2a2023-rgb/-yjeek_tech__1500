import 'package:flutter/material.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
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
          GreenScreenHeader(
            title: OrderFlowData.driverName,
            subtitle: OrderFlowStrings.onlineChamp,
            trailing: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColors.accountIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone_outlined, color: AppColors.primary, size: 18.sp),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              children: [
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
