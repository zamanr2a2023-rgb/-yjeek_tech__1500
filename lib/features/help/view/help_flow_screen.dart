import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class HelpFlowScreen extends StatefulWidget {
  const HelpFlowScreen({
    super.key,
    required this.flow,
    this.bottomNavIndex = 4,
  });

  final HelpFlowType flow;
  final int bottomNavIndex;

  @override
  State<HelpFlowScreen> createState() => _HelpFlowScreenState();
}

class _HelpFlowScreenState extends State<HelpFlowScreen> {
  String? _selectedReason;
  bool _confirmFee = true;

  @override
  void initState() {
    super.initState();
    _selectedReason = HelpPhase2Data.scheduledCancelReasons.first;
  }

  String get _title => switch (widget.flow) {
        HelpFlowType.scheduledCancelFree => 'Cancel scheduled order',
        HelpFlowType.scheduledCancelOutside => 'Cancel scheduled order',
        HelpFlowType.scheduledCancelConfirmed => 'Cancellation confirmed',
        HelpFlowType.modifyAwaiting => 'Change requested',
        HelpFlowType.modifyCannotAccommodate => 'Change unavailable',
      };

  @override
  Widget build(BuildContext context) {
    return HelpScreenScaffold(
      title: _title,
      bottomNavIndex: widget.bottomNavIndex,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        children: _buildBody(),
      ),
      bottom: _buildBottom(context),
    );
  }

  List<Widget> _buildBody() {
    final order = HelpPhase2Data.scheduledGroceryOrder;
    return switch (widget.flow) {
      HelpFlowType.scheduledCancelFree => [
        _orderCard(order.vendor, order.orderId, order.subtitle),
        SizedBox(height: 14.h),
        Center(
          child: Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 4),
            ),
            alignment: Alignment.center,
            child: Text(
              '01:45:30',
              style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        const HelpInfoBanner(
          message: 'You’re within the free cancellation window — no fee will be charged.',
        ),
        SizedBox(height: 14.h),
        const HelpFormHeading(title: 'Why are you cancelling?'),
        SizedBox(height: 10.h),
        HelpChipSelector(
          options: HelpPhase2Data.scheduledCancelReasons,
          selected: _selectedReason,
          onSelected: (v) => setState(() => _selectedReason = v),
        ),
        SizedBox(height: 14.h),
        HelpDetailRowsCard(
          title: 'Refund summary',
          lines: const [
            HelpDetailLine(label: 'Order total', value: 'BHD 24.600'),
            HelpDetailLine(
              label: 'Cancellation fee',
              value: 'BHD 0.000 — Free',
              valueColor: Color(0xFF0F4D27),
            ),
            HelpDetailLine(
              label: 'Refund to Wallet',
              value: 'BHD 24.600',
              valueColor: Color(0xFF0F4D27),
            ),
          ],
        ),
      ],
      HelpFlowType.scheduledCancelOutside => [
        _orderCard(order.vendor, order.orderId, order.subtitle),
        SizedBox(height: 14.h),
        const HelpAlertCard(
          title: 'Free cancellation window has closed',
          subtitle:
              'The vendor may already be preparing your order. A cancellation fee may apply.',
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Estimated refund'),
        SizedBox(height: 10.h),
        HelpDetailRowsCard(
          lines: const [
            HelpDetailLine(label: 'Order total', value: 'BHD 24.600'),
            HelpDetailLine(
              label: 'Cancellation fee',
              value: 'Up to 50% · prep-based',
              valueColor: Color(0xFFE08A1E),
            ),
            HelpDetailLine(
              label: 'Estimated refund',
              value: 'BHD 12.300 – 24.600',
            ),
          ],
        ),
        SizedBox(height: 14.h),
        GestureDetector(
          onTap: () => setState(() => _confirmFee = !_confirmFee),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE6EBE3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: _confirmFee ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: _confirmFee ? AppColors.primary : const Color(0xFFE6EBE3),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: _confirmFee
                      ? Icon(Icons.check, size: 15.sp, color: AppColors.white)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'I understand a cancellation fee may apply based on the preparation stage.',
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      HelpFlowType.scheduledCancelConfirmed => [
        SizedBox(height: 24.h),
        const Center(child: HelpSuccessCircle()),
        SizedBox(height: 16.h),
        Text(
          'Scheduled order cancelled',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'You cancelled within the free window — no fee charged.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(fontSize: 12.sp),
        ),
        SizedBox(height: 20.h),
        HelpDetailRowsCard(
          lines: const [
            HelpDetailLine(
              label: 'Refunded to Wallet',
              value: '+ BHD 24.600',
              valueColor: Color(0xFF0F4D27),
            ),
            HelpDetailLine(label: 'Order', value: '#YJK-2026-00051'),
            HelpDetailLine(label: 'Reference', value: 'CX-2026-10521'),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'Your delivery slot was released and any promo codes were restored.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(fontSize: 11.sp),
        ),
      ],
      HelpFlowType.modifyAwaiting => [
        const HelpAlertCard(
          icon: Icons.hourglass_top_rounded,
          title: 'Waiting for approval',
          subtitle: 'Responds within 2:00:00',
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Requested change'),
        SizedBox(height: 10.h),
        HelpDetailRowsCard(
          lines: const [
            HelpDetailLine(label: 'From', value: 'Sat 4 Jul · 18:00 – 18:30'),
            HelpDetailLine(
              label: 'To',
              value: 'Sat 4 Jul · 20:00 – 20:30',
              valueColor: Color(0xFF0F4D27),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'Your original delivery time stays active until the vendor responds.',
          style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(fontSize: 11.5.sp),
        ),
      ],
      HelpFlowType.modifyCannotAccommodate => [
        const HelpAlertCard(
          icon: Icons.event_busy_outlined,
          title: 'Vendor cannot accommodate',
          subtitle: 'Your requested time slot is not available.',
          backgroundColor: Color(0xFFFBEAEC),
          foregroundColor: Color(0xFFC0392B),
          subtitleColor: Color(0xFF9A3A3A),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Your options'),
        SizedBox(height: 10.h),
        const HelpNumberedStep(
          number: 1,
          text: 'Keep your original delivery slot.',
        ),
        SizedBox(height: 10.h),
        const HelpNumberedStep(
          number: 2,
          text: 'Choose another available slot or cancel for a full refund.',
        ),
      ],
    };
  }

  Widget? _buildBottom(BuildContext context) {
    return switch (widget.flow) {
      HelpFlowType.scheduledCancelFree => HelpPrimaryButton(
          label: 'Confirm free cancellation',
          showCheck: true,
          onTap: () => context.push(HelpRoutes.helpFlow(flow: HelpFlowType.scheduledCancelConfirmed)),
        ),
      HelpFlowType.scheduledCancelOutside => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Column(
            children: [
              HelpOrangeButton(
                label: 'Continue to cancel',
                onTap: () => context.push(HelpRoutes.helpFlow(flow: HelpFlowType.scheduledCancelConfirmed)),
              ),
              SizedBox(height: 10.h),
              HelpOutlineButton(label: 'Keep my order', onTap: () => context.pop()),
            ],
          ),
        ),
      HelpFlowType.scheduledCancelConfirmed => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Column(
            children: [
              HelpPrimaryButton(
                label: 'View Wallet',
                onTap: () => context.push(RouteNames.wallet),
              ),
              SizedBox(height: 10.h),
              HelpOutlineButton(
                label: 'Back to Orders',
                onTap: () => context.go('${RouteNames.home}?tab=1'),
              ),
            ],
          ),
        ),
      HelpFlowType.modifyAwaiting => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Column(
            children: [
              HelpPrimaryButton(label: 'Notify me & keep waiting', onTap: () => context.pop()),
              SizedBox(height: 10.h),
              HelpOutlineButton(label: 'Preview: vendor response', onTap: () {}),
            ],
          ),
        ),
      HelpFlowType.modifyCannotAccommodate => HelpPrimaryButton(
          label: 'Choose another slot',
          onTap: () => context.pop(),
        ),
    };
  }

  Widget _orderCard(String vendor, String orderId, String subtitle) {
    return HelpOrderCompactCard(
      order: HelpOrder(
        vendorName: vendor,
        orderId: orderId,
        shortId: orderId,
        statusLabel: subtitle,
        itemCount: 6,
        totalBhd: '24.600',
        deliveredAt: subtitle,
        compactSubtitle: subtitle,
      ),
    );
  }
}
