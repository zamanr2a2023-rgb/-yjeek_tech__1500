import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/help_phase2_issue_body.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';

class HelpIssueScreen extends StatefulWidget {
  const HelpIssueScreen({
    super.key,
    required this.type,
    required this.orderId,
    required this.bottomNavIndex,
  });

  final HelpIssueType type;
  final String orderId;
  final int bottomNavIndex;

  @override
  State<HelpIssueScreen> createState() => _HelpIssueScreenState();
}

class _HelpIssueScreenState extends State<HelpIssueScreen> {
  late List<bool> _itemChecks;
  String? _selectedChip;
  String? _selectedCancelReason;
  bool _confirmNotReceived = true;
  bool _feltUnwell = false;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _itemChecks = HelpData.orderItems.map((item) => item.selected).toList();
    _selectedChip = HelpData.foodQualityOptions.first;
    _selectedCancelReason = HelpData.cancelReasons.first;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _title => switch (widget.type) {
        HelpIssueType.orderLate => 'Order is late',
        HelpIssueType.missingItems => 'Missing items',
        HelpIssueType.damagedSpilled => 'Damaged or spilled',
        HelpIssueType.wrongOrder => 'Wrong order',
        HelpIssueType.notReceived => 'Order not received',
        HelpIssueType.foodQuality => 'Food quality',
        HelpIssueType.cancelOrder => 'Cancel order',
        HelpIssueType.champComplaint => 'Champ behavior',
        HelpIssueType.paymentIssue => 'Payment issue',
        HelpIssueType.serviceNoShow => 'Provider no-show',
        HelpIssueType.serviceQualityDispute => 'Service quality',
        HelpIssueType.propertyDamage => 'Property damage',
        HelpIssueType.dineInReservation => 'Reservation issue',
        HelpIssueType.dineInBillQuality => 'Bill or quality',
        HelpIssueType.pickUpNotReady => 'Pick-up not ready',
        HelpIssueType.cashbackNotCredited => 'Missing cashback',
        HelpIssueType.cashOut => 'Cash-out issue',
        HelpIssueType.modifyRequest => 'Modify request',
        _ => 'Help',
      };

  bool get _isPhase2Issue => switch (widget.type) {
        HelpIssueType.champComplaint ||
        HelpIssueType.paymentIssue ||
        HelpIssueType.serviceNoShow ||
        HelpIssueType.serviceQualityDispute ||
        HelpIssueType.propertyDamage ||
        HelpIssueType.dineInReservation ||
        HelpIssueType.dineInBillQuality ||
        HelpIssueType.pickUpNotReady ||
        HelpIssueType.cashbackNotCredited ||
        HelpIssueType.cashOut ||
        HelpIssueType.modifyRequest =>
          true,
        _ => false,
      };

  bool get _phase2HasExternalBottom =>
      widget.type == HelpIssueType.modifyRequest ||
      widget.type == HelpIssueType.paymentIssue;

  bool get _showReportBanner =>
      widget.type == HelpIssueType.missingItems ||
      widget.type == HelpIssueType.wrongOrder;

  @override
  Widget build(BuildContext context) {
    final orderContext = HelpData.contextForOrderId(widget.orderId);

    return HelpScreenScaffold(
      title: _title,
      bottomNavIndex: widget.bottomNavIndex,
      showBottomNav: false,
      // Figma H4–H9: white title + back on green header.
      darkTitle: false,
      banner: _showReportBanner
          ? const HelpInfoBanner(message: HelpData.reportWindowBanner)
          : null,
      body: _buildIssueBody(orderContext),
      bottom: _isPhase2Issue && _phase2HasExternalBottom
          ? _buildPhase2Bottom()
          : null,
    );
  }

  Widget _buildScrollForm(List<Widget> children) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      children: children,
    );
  }

  Widget _buildIssueBody(HelpOrderContext orderContext) {
    return switch (widget.type) {
      HelpIssueType.missingItems => _buildScrollForm([
          ..._buildMissingItemsFields(),
          HelpPrimaryButton(
            label: 'Submit',
            showCheck: true,
            inline: true,
            onTap: () => _submit(context),
          ),
        ]),
      HelpIssueType.wrongOrder => _buildScrollForm([
          ..._buildWrongOrderFields(),
          HelpPrimaryButton(
            label: 'Submit',
            showCheck: true,
            inline: true,
            onTap: () => _submit(context),
          ),
        ]),
      HelpIssueType.damagedSpilled => _buildScrollForm([
          ..._buildDamagedSpilledFields(),
          HelpPrimaryButton(
            label: 'Submit & get refund',
            inline: true,
            onTap: () => _submit(context),
          ),
        ]),
      HelpIssueType.notReceived => _buildScrollForm([
          HelpFormHeading(
            title: 'You didn’t get your order?',
            subtitle:
                'We’ll check GPS and the handover record for ${orderContext.order.shortId}.',
          ),
          SizedBox(height: 14.h),
          _buildNotReceivedMapCard(),
          SizedBox(height: 14.h),
          _buildNotReceivedConfirmCard(),
          HelpPrimaryButton(
            label: 'Report not received',
            showCheck: true,
            inline: true,
            onTap: _confirmNotReceived ? () => _submit(context) : null,
          ),
        ]),
      HelpIssueType.foodQuality => _buildScrollForm([
          ..._buildFoodQualityFields(),
          HelpPrimaryButton(
            label: 'Submit complaint',
            showCheck: true,
            inline: true,
            onTap: () => _submit(context),
          ),
        ]),
      HelpIssueType.cancelOrder => _buildScrollForm([
          const HelpWarningBanner(
            title: 'Vendor is preparing your order',
            subtitle: 'Cancelling now may incur a fee',
          ),
          SizedBox(height: 14.h),
          const HelpFormHeading(title: 'Why are you cancelling?'),
          SizedBox(height: 10.h),
          HelpChipSelector(
            options: HelpData.cancelReasons,
            selected: _selectedCancelReason,
            onSelected: (value) => setState(() => _selectedCancelReason = value),
          ),
          SizedBox(height: 14.h),
          const HelpRefundSummaryCard(),
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Column(
              children: [
                HelpDestructiveButton(
                  label: 'Cancel order',
                  onTap: () => _submit(context),
                ),
                SizedBox(height: 10.h),
                HelpOutlineButton(
                  label: 'Keep my order',
                  onTap: () => context.pop(),
                ),
              ],
            ),
          ),
        ]),
      _ => ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
          children: [
            if (_isPhase2Issue)
              HelpPhase2IssueBody(
                type: widget.type,
                orderContext: orderContext,
                externalSubmit: _phase2HasExternalBottom,
                onSubmit: () => _submit(context),
              )
            else if (widget.type.hasDedicatedForm)
              ..._buildDedicatedForm(orderContext)
            else
              ..._buildGenericForm(),
          ],
        ),
    };
  }

  List<Widget> _buildOrderItemCheckboxCard() {
    return [
      HelpCard(
        child: Column(
          children: [
            for (var i = 0; i < HelpData.orderItems.length; i++) ...[
              if (i > 0) SizedBox(height: 12.h),
              HelpItemCheckboxRow(
                label: HelpData.orderItems[i].label,
                price: HelpData.orderItems[i].price,
                checked: _itemChecks[i],
                onChanged: (value) => setState(() => _itemChecks[i] = value),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildMissingItemsFields() {
    return [
      const HelpFormHeading(title: 'Which items are missing?'),
      SizedBox(height: 12.h),
      ..._buildOrderItemCheckboxCard(),
      SizedBox(height: 14.h),
      const HelpPhotoUploadBox(),
    ];
  }

  List<Widget> _buildWrongOrderFields() {
    return [
      const HelpFormHeading(
        title: 'This isn’t what you ordered?',
        subtitle: 'Help us fix it fast',
      ),
      SizedBox(height: 12.h),
      ..._buildOrderItemCheckboxCard(),
      SizedBox(height: 14.h),
      const HelpPhotoUploadBox(),
    ];
  }

  List<Widget> _buildDamagedSpilledFields() {
    return [
      const HelpFormHeading(
        title: 'Add a photo of the damage',
        subtitle: 'A clear photo lets us refund you automatically.',
      ),
      SizedBox(height: 14.h),
      const HelpPhotoUploadBox(),
      SizedBox(height: 14.h),
      HelpNoteField(
        label: 'Add a note (optional)',
        hint: 'Tell us what happened…',
        controller: _noteController,
      ),
    ];
  }

  List<Widget> _buildFoodQualityFields() {
    return [
      const HelpFormHeading(title: 'What was wrong with the food?'),
      SizedBox(height: 12.h),
      HelpChipSelector(
        options: HelpData.foodQualityOptions,
        selected: _selectedChip,
        onSelected: (value) => setState(() => _selectedChip = value),
      ),
      SizedBox(height: 14.h),
      HelpNoteField(
        label: 'Describe it',
        hint: 'Tell us more…',
        controller: _noteController,
      ),
      SizedBox(height: 14.h),
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE6EBE3)),
        ),
        child: Row(
          children: [
            Icon(Icons.photo_camera_outlined, size: 20.sp, color: const Color(0xFF6B7B6E)),
            SizedBox(width: 10.w),
            Text(
              'Add a photo (optional)',
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 14.h),
      _buildFeltUnwellCard(),
    ];
  }

  Widget _buildFeltUnwellCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF5C6C6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _feltUnwell = !_feltUnwell),
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: _feltUnwell ? const Color(0xFFC0392B) : AppColors.white,
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(color: const Color(0xFFC0392B)),
              ),
              alignment: Alignment.center,
              child: _feltUnwell
                  ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
                  : null,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'I or someone felt unwell after eating',
              style: AppTextStyles.labelSmall(color: const Color(0xFFC0392B)).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotReceivedMapCard() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE4EAE0),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.map_outlined, size: 48.sp, color: AppColors.primary),
    );
  }

  Widget _buildNotReceivedConfirmCard() {
    return GestureDetector(
      onTap: () => setState(() => _confirmNotReceived = !_confirmNotReceived),
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
                color: _confirmNotReceived ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: _confirmNotReceived
                      ? AppColors.primary
                      : const Color(0xFFE6EBE3),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: _confirmNotReceived
                  ? Icon(Icons.check, size: 15.sp, color: AppColors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'I confirm I did not receive this order',
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDedicatedForm(HelpOrderContext orderContext) {
    return switch (widget.type) {
      HelpIssueType.orderLate => [
          const HelpFormHeading(
            title: 'Order late +15?',
            subtitle:
                'When your order is 15 minutes past ETA, an instant wallet credit is '
                'applied and you’ll get a notification.',
          ),
        ],
      _ => [],
    };
  }

  List<Widget> _buildGenericForm() {
    final body = switch (widget.type) {
      HelpIssueType.champComplaint =>
        'Tell us what happened with your champ. Our support team will review the report '
            'and follow up within 24 hours.',
      HelpIssueType.paymentIssue =>
        'Describe the payment problem you experienced. Include the payment method and time '
            'of the transaction if possible.',
      HelpIssueType.serviceNoShow =>
        'Let us know when your service provider was scheduled and did not arrive.',
      HelpIssueType.serviceQualityDispute =>
        'Describe the quality issue with the service you received.',
      HelpIssueType.propertyDamage =>
        'Describe any property damage that occurred during the service visit.',
      HelpIssueType.dineInReservation =>
        'Tell us about your dine-in reservation that was not honored.',
      HelpIssueType.dineInBillQuality =>
        'Describe the issue with your dine-in bill or food quality.',
      HelpIssueType.pickUpNotReady =>
        'Let us know when you arrived for pick-up and the order was not ready.',
      HelpIssueType.cashbackNotCredited =>
        'Tell us which order should have earned cashback and we will investigate.',
      HelpIssueType.modifyRequest =>
        'Describe the changes you need to make to your scheduled order.',
      _ => 'Contact our support team for help with this issue.',
    };

    return [
      HelpFormHeading(title: 'How can we help?', subtitle: body),
      SizedBox(height: 14.h),
      HelpNoteField(
        label: 'Your message',
        hint: 'Describe the issue…',
        controller: _noteController,
      ),
      SizedBox(height: 16.h),
      HelpPrimaryButton(
        label: 'Submit',
        showCheck: true,
        inline: true,
        onTap: () => _submit(context),
      ),
    ];
  }

  Widget? _buildPhase2Bottom() {
    if (widget.type == HelpIssueType.paymentIssue) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: HelpPrimaryButton(
          label: 'Submit and continue to chat',
          showCheck: true,
          inline: true,
          onTap: () => context.push(
            HelpRoutes.helpChat(variant: HelpChatVariant.payment),
          ),
        ),
      );
    }
    return null;
  }

  void _submit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your request has been submitted')),
    );
    context.pop();
  }
}
