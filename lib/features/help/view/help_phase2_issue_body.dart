import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';

class HelpPhase2IssueBody extends StatefulWidget {
  const HelpPhase2IssueBody({
    super.key,
    required this.type,
    required this.orderContext,
    required this.onSubmit,
    this.externalSubmit = false,
  });

  final HelpIssueType type;
  final HelpOrderContext orderContext;
  final VoidCallback onSubmit;
  final bool externalSubmit;

  @override
  State<HelpPhase2IssueBody> createState() => _HelpPhase2IssueBodyState();
}

class _HelpPhase2IssueBodyState extends State<HelpPhase2IssueBody> {
  int _rating = 2;
  String? _selectedChip;
  String? _selectedRadio;
  bool _noAnswer = false;
  Set<String> _champSelections = {'Unsafe driving'};
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedChip = _defaultChip;
    _selectedRadio = _defaultRadio;
  }

  String? get _defaultChip => switch (widget.type) {
        HelpIssueType.champComplaint => HelpPhase2Data.champIssues[1],
        HelpIssueType.paymentIssue => HelpPhase2Data.paymentIssues.first,
        HelpIssueType.serviceQualityDispute => HelpPhase2Data.serviceQualityIssues.first,
        HelpIssueType.dineInBillQuality => HelpPhase2Data.dineInBillIssues.first,
        HelpIssueType.cashOut => HelpPhase2Data.cashOutIssues.first,
        _ => null,
      };

  String? get _defaultRadio => switch (widget.type) {
        HelpIssueType.dineInBillQuality => HelpPhase2Data.dineInBillIssues.first,
        HelpIssueType.cashOut => HelpPhase2Data.cashOutIssues.first,
        _ => null,
      };

  List<String> get _chipOptions => switch (widget.type) {
        HelpIssueType.champComplaint => HelpPhase2Data.champIssues,
        HelpIssueType.paymentIssue => HelpPhase2Data.paymentIssues,
        HelpIssueType.serviceQualityDispute => HelpPhase2Data.serviceQualityIssues,
        _ => const [],
      };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _ratingLabel => switch (_rating) {
        1 || 2 => '$_rating / 5 · Poor',
        3 => '$_rating / 5 · Average',
        4 => '$_rating / 5 · Good',
        _ => '$_rating / 5 · Excellent',
      };

  Color get _ratingLabelColor =>
      _rating <= 2 ? const Color(0xFFC24B00) : const Color(0xFF6B7B6E);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildContent(),
        if (_bottomLabel != null && !widget.externalSubmit)
          HelpPrimaryButton(
            label: _bottomLabel!,
            showCheck: _showCheck,
            inline: true,
            onTap: _onPrimaryTap,
          ),
      ],
    );
  }

  String? get _bottomLabel => switch (widget.type) {
        HelpIssueType.champComplaint => 'Submit complaint',
        HelpIssueType.paymentIssue => 'Submit and continue to chat',
        HelpIssueType.serviceNoShow => 'Report provider not arrived',
        HelpIssueType.serviceQualityDispute => 'Submit quality dispute',
        HelpIssueType.propertyDamage => null,
        HelpIssueType.dineInReservation => 'Report reservation issue',
        HelpIssueType.dineInBillQuality => 'Submit report',
        HelpIssueType.pickUpNotReady => 'Report — order not ready',
        HelpIssueType.cashbackNotCredited => 'Report missing cashback',
        HelpIssueType.cashOut => 'Submit cash-out dispute',
        HelpIssueType.modifyRequest => null,
        _ => null,
      };

  bool get _showCheck => switch (widget.type) {
        HelpIssueType.paymentIssue ||
        HelpIssueType.dineInReservation ||
        HelpIssueType.pickUpNotReady ||
        HelpIssueType.cashbackNotCredited =>
          true,
        _ => false,
      };

  void _onPrimaryTap() {
    if (widget.type == HelpIssueType.paymentIssue) {
      context.push(HelpRoutes.helpChat(variant: HelpChatVariant.payment));
      return;
    }
    if (widget.type == HelpIssueType.serviceNoShow) {
      context.push(HelpRoutes.helpChat(variant: HelpChatVariant.serviceNoShow));
      return;
    }
    widget.onSubmit();
  }

  List<Widget> _buildContent() {
    final order = widget.orderContext.order;
    final service = HelpPhase2Data.serviceOrder;

    return switch (widget.type) {
      HelpIssueType.champComplaint => [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE6EBE3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1E5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'AH',
                  style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ali H. · Your Champ',
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5.sp,
                      ),
                    ),
                    Text(
                      '${order.orderId} · Delivered today 13:48',
                      style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        const HelpSectionTitle(label: 'Rate your experience'),
        SizedBox(height: 16.h),
        HelpCard(
          padding: EdgeInsets.all(14.w),
          child: HelpStarRating(
            rating: _rating,
            onChanged: (v) => setState(() => _rating = v),
            label: _ratingLabel,
            labelColor: _ratingLabelColor,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E6),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFF3D9A6)),
          ),
          child: Text(
            'Ratings of 1–2 stars are treated as a formal complaint — not just a rating. '
            'Our team reviews every report and acts on the Champ’s record.',
            style: AppTextStyles.labelSmall(color: const Color(0xFF8A6516)).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        const HelpSectionTitle(label: 'What went wrong?'),
        SizedBox(height: 16.h),
        HelpCard(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select all that apply',
                style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.h),
              HelpMultiChipSelector(
                options: _chipOptions,
                selected: _champSelections,
                onChanged: (value) => setState(() => _champSelections = value),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        const HelpSectionTitle(label: 'Add details (optional)'),
        SizedBox(height: 16.h),
        HelpNoteField(
          label: '',
          hint: 'Tell us what happened…',
          controller: _noteController,
        ),
      ],
      HelpIssueType.paymentIssue => [
        HelpOrderCompactCard(
          order: order,
          subtitle: order.detailSubtitle,
        ),
        SizedBox(height: 16.h),
        const HelpSectionTitle(label: 'We pulled your payment automatically'),
        SizedBox(height: 16.h),
        const HelpDetailRowsCard(
          lines: HelpPhase2Data.paymentOrderDetails,
          showDividers: true,
          footer: HelpPhase2Data.paymentDetailsFooter,
        ),
        SizedBox(height: 16.h),
        const HelpSectionTitle(label: "What's the issue?"),
        SizedBox(height: 16.h),
        HelpCard(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose what happened',
                style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.h),
              HelpChipSelector(
                options: _chipOptions,
                selected: _selectedChip,
                onSelected: (v) => setState(() => _selectedChip = v),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        const HelpSectionTitle(label: 'Add details (optional)'),
        SizedBox(height: 16.h),
        HelpNoteField(
          label: '',
          hint: 'Tell us what looks wrong…',
          controller: _noteController,
          maxLines: 1,
        ),
      ],
      HelpIssueType.serviceNoShow => [
        _serviceCard(service.vendor, service.orderId, service.subtitle, service.price),
        SizedBox(height: 14.h),
        const HelpAlertCard(
          title: 'Provider hasn’t arrived?',
          subtitle: 'We’ll verify the appointment time before declaring a no-show.',
        ),
        SizedBox(height: 14.h),
        const HelpFormHeading(title: 'Before a no-show is declared'),
        SizedBox(height: 10.h),
        HelpOutlineButton(label: 'Call provider', onTap: () {}),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _noAnswer = true),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: _noAnswer ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _noAnswer ? AppColors.primary : const Color(0xFFE6EBE3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Yes — no answer',
                    style: AppTextStyles.labelSmall(
                      color: _noAnswer ? AppColors.white : const Color(0xFF6B7B6E),
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _noAnswer = false),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: !_noAnswer ? AppColors.white : AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE6EBE3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Not yet',
                    style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E))
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
      HelpIssueType.serviceQualityDispute => [
        _serviceCard(
          service.vendor,
          service.orderId,
          'Service booking · Completed — today 13:30',
          service.price,
        ),
        SizedBox(height: 14.h),
        const HelpFormHeading(title: 'What went wrong?'),
        SizedBox(height: 10.h),
        HelpChipSelector(
          options: _chipOptions,
          selected: _selectedChip,
          onSelected: (v) => setState(() => _selectedChip = v),
        ),
        SizedBox(height: 14.h),
        HelpNoteField(
          label: 'Listed vs delivered',
          hint: 'Describe what was promised vs what you received…',
          controller: _noteController,
        ),
        SizedBox(height: 14.h),
        const HelpPhotoUploadBox(hint: 'Add photos or video'),
      ],
      HelpIssueType.propertyDamage => [
        _serviceCard(service.vendor, service.orderId, service.subtitle, service.price),
        SizedBox(height: 14.h),
        const HelpAlertCard(
          icon: Icons.warning_amber_rounded,
          title: 'Goes straight to our Ops Manager',
          subtitle: 'Property damage reports are escalated immediately for review.',
          backgroundColor: Color(0xFFFBEAEC),
          foregroundColor: Color(0xFFC0392B),
          subtitleColor: Color(0xFF9A3A3A),
        ),
        SizedBox(height: 14.h),
        const HelpFormHeading(title: 'Photos of the damage — required'),
        SizedBox(height: 10.h),
        const HelpPhotoUploadBoxRed(),
        SizedBox(height: 14.h),
        HelpNoteField(
          label: 'What was damaged?',
          hint: 'Describe the damage…',
          controller: _noteController,
        ),
      ],
      HelpIssueType.dineInReservation => [
        HelpOrderDetailCard(order: order),
        SizedBox(height: 14.h),
        const HelpAlertCard(
          icon: Icons.error_outline,
          title: 'Reservation not honored?',
          subtitle: 'We’ll contact the restaurant and secure an alternative or refund.',
          backgroundColor: Color(0xFFFBEAEC),
          foregroundColor: Color(0xFFC0392B),
          subtitleColor: Color(0xFF9A3A3A),
        ),
        SizedBox(height: 14.h),
        const HelpFormHeading(title: 'What we do immediately'),
        SizedBox(height: 10.h),
        const HelpNumberedStep(
          number: 1,
          text: 'We call the restaurant to verify your reservation status.',
        ),
        SizedBox(height: 10.h),
        const HelpNumberedStep(
          number: 2,
          text: 'If not honored, we offer rebooking or a full refund to your Wallet.',
        ),
      ],
      HelpIssueType.dineInBillQuality => [
        HelpOrderDetailCard(order: order),
        SizedBox(height: 14.h),
        const HelpInfoBanner(message: 'Report within 2 hours of your visit.'),
        SizedBox(height: 14.h),
        const HelpFormHeading(title: 'What happened?'),
        SizedBox(height: 10.h),
        for (var i = 0; i < HelpPhase2Data.dineInBillIssues.length; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          HelpRadioOptionRow(
            label: HelpPhase2Data.dineInBillIssues[i],
            selected: _selectedRadio == HelpPhase2Data.dineInBillIssues[i],
            highlightBorder: true,
            onTap: () => setState(
              () => _selectedRadio = HelpPhase2Data.dineInBillIssues[i],
            ),
          ),
        ],
        SizedBox(height: 14.h),
        const HelpFormHeading(title: 'Photo of the bill — required'),
        SizedBox(height: 10.h),
        const HelpPhotoUploadBox(),
        SizedBox(height: 14.h),
        HelpNoteField(
          label: 'Add any details (optional)',
          hint: 'Tell us more…',
          controller: _noteController,
        ),
      ],
      HelpIssueType.pickUpNotReady => [
        HelpOrderDetailCard(order: order),
        SizedBox(height: 14.h),
        const HelpAlertCard(
          title: 'Order not ready at pick-up?',
          subtitle: 'We’ll verify with the vendor and may offer compensation after 15 min.',
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Check-in status'),
        SizedBox(height: 10.h),
        HelpDetailRowsCard(
          lines: const [
            HelpDetailLine(
              label: 'Checked in at 13:00 — vendor pinged',
              value: '✓',
              valueColor: Color(0xFF0F4D27),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          '06:12 / 15:00 wait',
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
      ],
      HelpIssueType.cashbackNotCredited => [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE6EBE3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    alignment: Alignment.center,
                    child: Text('🎁', style: TextStyle(fontSize: 18.sp)),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yjeek Cashback',
                          style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                              .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5.sp,
                          ),
                        ),
                        Text(
                          'Order ${order.orderId} · Delivered today',
                          style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Text(
                      '💳 Wallet',
                      style: AppTextStyles.caption(color: const Color(0xFF1D8A3E)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Cashback',
                      style: AppTextStyles.caption(color: const Color(0xFF1D8A3E)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        HelpInfoBanner(
          message: HelpPhase2Data.cashbackInfoMessage,
          icon: '🕒',
          borderRadius: 10.r,
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'We pulled the details'),
        SizedBox(height: 14.h),
        const HelpDetailRowsCard(
          lines: HelpPhase2Data.cashbackDetails,
          showDividers: true,
          dividerColor: Color(0xFFEEF0EC),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Automatic checks'),
        SizedBox(height: 14.h),
        HelpAutomaticCheckCard(items: HelpPhase2Data.cashbackAutomaticChecks),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4EC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            HelpPhase2Data.cashbackFooter,
            style: AppTextStyles.caption(color: const Color(0xFF55605A)).copyWith(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
      ],
      HelpIssueType.cashOut => [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE6EBE3)),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1F8),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(Icons.account_balance, color: const Color(0xFF2A6FB0), size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet cash-out',
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                      ),
                    ),
                    Text(
                      'Wallet Cash-out',
                      style: AppTextStyles.caption(color: const Color(0xFF2A6FB0)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        const HelpDetailRowsCard(
          title: 'We pulled your request',
          lines: HelpPhase2Data.cashOutDetails,
        ),
        SizedBox(height: 14.h),
        const HelpFormHeading(title: 'What’s the issue?'),
        SizedBox(height: 10.h),
        for (var i = 0; i < HelpPhase2Data.cashOutIssues.length; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          HelpRadioOptionRow(
            label: HelpPhase2Data.cashOutIssues[i],
            selected: _selectedRadio == HelpPhase2Data.cashOutIssues[i],
            onTap: () => setState(() => _selectedRadio = HelpPhase2Data.cashOutIssues[i]),
          ),
        ],
      ],
      HelpIssueType.modifyRequest => [
        const HelpFormHeading(
          title: 'Request a change',
          subtitle: 'Describe the changes you need for your scheduled order.',
        ),
        SizedBox(height: 14.h),
        HelpNoteField(
          label: 'Your request',
          hint: 'New time, items, or address…',
          controller: _noteController,
        ),
        SizedBox(height: 16.h),
        HelpPrimaryButton(
          label: 'Submit change request',
          showCheck: true,
          onTap: () => context.push(HelpRoutes.helpFlow(flow: HelpFlowType.modifyAwaiting)),
        ),
      ],
      _ => [],
    };
  }

  Widget _serviceCard(String vendor, String orderId, String subtitle, String price) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6EBE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBEAEC),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(Icons.home_repair_service, color: const Color(0xFFC0392B), size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor,
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                      ),
                    ),
                    Text(
                      '$orderId · $price',
                      style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)).copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              subtitle,
              style: AppTextStyles.caption(color: const Color(0xFF2E7D32)).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
