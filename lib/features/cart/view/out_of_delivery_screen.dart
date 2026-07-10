import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/cart_routes.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class OutOfDeliveryScreen extends StatelessWidget {
  const OutOfDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GreenScreenHeader(title: CartFlowStrings.deliveryAddress),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const CartMapPlaceholder(expand: true, tint: Color(0xFFF5E6D3)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: CartFlowCard(
                        child: Column(
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF3CD),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: const Color(0xFFE6A700),
                                size: 26.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              CartFlowStrings.outOfRangeTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleSmall().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 17.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              CartFlowStrings.outOfRangeBody,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
                                fontSize: 13.sp,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: PrimaryGreenButton(
                label: CartFlowStrings.chooseAnotherAddress,
                onPressed: () => context.go(CartRoutes.changeAddress),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 2),
    );
  }
}
