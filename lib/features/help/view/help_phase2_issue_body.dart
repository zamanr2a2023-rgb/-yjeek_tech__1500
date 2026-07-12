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
  bool _noAnswer = true;
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
        HelpIssueType.dineInBillQuality => HelpPhase2Data.dineInBillIssues.first.label,
        HelpIssueType.cashOut => HelpPhase2Data.cashOutIssues.first.label,
        _ => null,
      };

  String? get _defaultRadio => switch (widget.type) {
        HelpIssueType.dineInBillQuality => HelpPhase2Data.dineInBillIssues.first.label,
        HelpIssueType.cashOut => HelpPhase2Data.cashOutIssues.first.label,
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
        if (widget.type == HelpIssueType.propertyDamage && !widget.externalSubmit)
          HelpDestructiveButton(
            label: 'Report property damage',
            inline: true,
            onTap: _onPrimaryTap,
          )
        else if (_bottomLabel != null && !widget.externalSubmit)
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
    if (widget.type == HelpIssueType.dineInReservation ||
        widget.type == HelpIssueType.dineInBillQuality ||
        widget.type == HelpIssueType.pickUpNotReady ||
        widget.type == HelpIssueType.cashOut) {
      context.push(HelpRoutes.helpChat(variant: HelpChatVariant.support));
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
          iconAsset: 'assets/cup.png',
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
        _serviceCard(
          service.vendor,
          '${service.serviceLabel} · ${service.orderId} · ${service.price}',
          '🔧 Service booking',
          service.statusDetail,
          iconBg: const Color(0xFFE0F2F1),
          badgeBg: const Color(0xFFE0F2F1),
          badgeColor: const Color(0xFF00695C),
        ),
        SizedBox(height: 14.h),
        HelpAlertCard(
          title: 'Provider hasn’t arrived?',
          subtitle: HelpPhase2Data.serviceNoShowAlert,
          iconAsset: 'assets/watch.png',
          backgroundColor: const Color(0xFFFFF7E6),
          borderColor: const Color(0xFFF3D9A6),
          foregroundColor: const Color(0xFF7A4B00),
          subtitleColor: const Color(0xFF8A6516),
          iconBackgroundColor: const Color(0xFFF5A623),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Before a no-show is declared'),
        SizedBox(height: 14.h),
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
              Text(
                'Have you tried calling the provider directly?',
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5.sp,
                ),
              ),
              SizedBox(height: 12.h),
              HelpOutlineButton(
                label: 'Call provider',
                icon: Icons.phone,
                onTap: () {},
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _noAnswer = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: _noAnswer ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _noAnswer ? AppColors.primary : const Color(0xFFD7DDD6),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'Yes — no answer',
                        style: AppTextStyles.labelSmall(
                          color: _noAnswer ? AppColors.white : const Color(0xFF404842),
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.5.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => setState(() => _noAnswer = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: !_noAnswer ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: !_noAnswer ? AppColors.primary : const Color(0xFFD7DDD6),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'Not yet',
                        style: AppTextStyles.labelSmall(
                          color: !_noAnswer ? AppColors.white : const Color(0xFF404842),
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      HelpIssueType.serviceQualityDispute => [
        _serviceCard(
          service.vendor,
          '${service.serviceLabel} · ${service.orderId} · ${service.price}',
          '🔧 Service booking',
          'Completed · today 13:30',
        ),
        SizedBox(height: 14.h),
        HelpInfoBanner(
          message: HelpPhase2Data.serviceQualityInfoMessage,
          icon: '🕒',
          borderRadius: 10.r,
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'What went wrong?'),
        SizedBox(height: 14.h),
        HelpCard(
          padding: EdgeInsets.all(14.w),
          child: HelpChipSelector(
            options: _chipOptions,
            selected: _selectedChip,
            onSelected: (v) => setState(() => _selectedChip = v),
          ),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Listed vs delivered'),
        SizedBox(height: 14.h),
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHAT WAS LISTED',
                      style: AppTextStyles.caption(color: const Color(0xFF8A938C)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 9.5.sp,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      HelpPhase2Data.serviceQualityListed,
                      style: AppTextStyles.caption(color: const Color(0xFF3D4842)).copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              HelpNoteField(
                label: '',
                hint: 'Describe what was incomplete or below standard…',
                controller: _noteController,
                maxLines: 2,
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Evidence'),
        SizedBox(height: 14.h),
        const HelpPhotoUploadBox(
          hint: 'Add photos or video',
          subtitle: 'Strongly encouraged · JPG/PNG/MP4',
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4EC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            HelpPhase2Data.serviceQualityFooter,
            style: AppTextStyles.caption(color: const Color(0xFF55605A)).copyWith(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
      ],
      HelpIssueType.propertyDamage => [
        _serviceCard(
          service.vendor,
          '${service.serviceLabel} · ${service.orderId} · ${service.price}',
          '🔧 Service booking',
          'Service · today 14:00',
        ),
        SizedBox(height: 14.h),
        HelpAlertCard(
          title: 'Goes straight to our Ops Manager',
          subtitle: HelpPhase2Data.propertyDamageAlert,
          icon: Icons.priority_high_rounded,
          backgroundColor: const Color(0xFFFDECEC),
          borderColor: const Color(0xFFF3C6C6),
          foregroundColor: const Color(0xFF8A1C1C),
          subtitleColor: const Color(0xFF9A3B3B),
          iconBackgroundColor: const Color(0xFFC62828),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Photos of the damage · required'),
        SizedBox(height: 14.h),
        const HelpPhotoUploadBoxRed(),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'What was damaged?'),
        SizedBox(height: 14.h),
        HelpNoteField(
          label: '',
          hint: 'Describe the damage and where it happened…',
          controller: _noteController,
          maxLines: 2,
        ),
      ],
      HelpIssueType.dineInReservation => [
        _serviceCard(
          HelpPhase2Data.dineInReservationOrder.vendor,
          HelpPhase2Data.dineInReservationOrder.detail,
          HelpPhase2Data.dineInReservationOrder.badgeLead,
          HelpPhase2Data.dineInReservationOrder.badgeTrail,
          iconEmoji: '🍽',
          iconBg: const Color(0xFFFDECEC),
          badgeBg: const Color(0xFFFDECEC),
          badgeColor: const Color(0xFFC62828),
        ),
        SizedBox(height: 14.h),
        HelpAlertCard(
          title: 'Reservation not honored?',
          subtitle: HelpPhase2Data.dineInReservationAlert,
          icon: Icons.restaurant,
          backgroundColor: const Color(0xFFFDECEC),
          borderColor: const Color(0xFFF3C6C6),
          foregroundColor: const Color(0xFF8A1C1C),
          subtitleColor: const Color(0xFF9A3B3B),
          iconBackgroundColor: const Color(0xFFC62828),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'What we do immediately'),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE6EBE3)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < HelpPhase2Data.dineInReservationSteps.length; i++) ...[
                if (i > 0) SizedBox(height: 14.h),
                HelpNumberedStep(
                  number: i + 1,
                  title: HelpPhase2Data.dineInReservationSteps[i].title,
                  text: HelpPhase2Data.dineInReservationSteps[i].subtitle,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4EC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            HelpPhase2Data.dineInReservationFooter,
            style: AppTextStyles.caption(color: const Color(0xFF55605A)).copyWith(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
      ],
      HelpIssueType.dineInBillQuality => [
        _serviceCard(
          HelpPhase2Data.dineInBillOrder.vendor,
          HelpPhase2Data.dineInBillOrder.detail,
          HelpPhase2Data.dineInBillOrder.badgeLead,
          HelpPhase2Data.dineInBillOrder.badgeTrail,
          iconEmoji: '🍽',
          iconBg: const Color(0xFFFDECEC),
          badgeBg: const Color(0xFFFDECEC),
          badgeColor: const Color(0xFFC62828),
        ),
        SizedBox(height: 14.h),
        HelpInfoBanner(
          message: 'Report within 2 hours of your visit.',
          icon: '🕒',
          borderRadius: 10.r,
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'What happened?'),
        SizedBox(height: 14.h),
        for (var i = 0; i < HelpPhase2Data.dineInBillIssues.length; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          HelpRadioOptionRow(
            label: HelpPhase2Data.dineInBillIssues[i].label,
            subtitle: HelpPhase2Data.dineInBillIssues[i].subtitle,
            selected: _selectedRadio == HelpPhase2Data.dineInBillIssues[i].label,
            highlightBorder: true,
            onTap: () => setState(
              () => _selectedRadio = HelpPhase2Data.dineInBillIssues[i].label,
            ),
          ),
        ],
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Photo of the bill · required'),
        SizedBox(height: 14.h),
        const HelpPhotoUploadBox(
          hint: 'Add photo of the physical bill',
          subtitle: 'We compare it against your Yjeek app price · JPG/PNG',
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Add any details (optional)'),
        SizedBox(height: 14.h),
        HelpNoteField(
          label: '',
          hint: 'Add any details (optional)…',
          controller: _noteController,
          maxLines: 2,
        ),
      ],
      HelpIssueType.pickUpNotReady => [
        _serviceCard(
          HelpPhase2Data.pickUpNotReadyOrder.vendor,
          HelpPhase2Data.pickUpNotReadyOrder.detail,
          HelpPhase2Data.pickUpNotReadyOrder.badgeLead,
          HelpPhase2Data.pickUpNotReadyOrder.badgeTrail,
          iconAsset: 'assets/bag.png',
          iconBg: const Color(0xFFFFF3E0),
          badgeBg: const Color(0xFFFFF3E0),
          badgeColor: const Color(0xFFE65100),
        ),
        SizedBox(height: 14.h),
        HelpAlertCard(
          title: 'Order not ready at pick-up?',
          subtitle: HelpPhase2Data.pickUpNotReadyAlert,
          iconAsset: 'assets/watch.png',
          backgroundColor: const Color(0xFFFFF7E6),
          borderColor: const Color(0xFFF3D9A6),
          foregroundColor: const Color(0xFF7A4B00),
          subtitleColor: const Color(0xFF8A6516),
          iconBackgroundColor: const Color(0xFFF5A623),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: 'Check-in status'),
        SizedBox(height: 14.h),
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
                  Text(
                    '✓',
                    style: AppTextStyles.labelMedium(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Checked in at 13:00 · vendor pinged',
                      style: AppTextStyles.labelMedium(color: const Color(0xFF25302B))
                          .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '06:12',
                      style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                          .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 26.sp,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: ' / 15:00 wait',
                      style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEF0EC)),
              SizedBox(height: 12.h),
              for (var i = 0; i < HelpPhase2Data.pickUpNotReadyMilestones.length; i++) ...[
                if (i > 0) SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HelpPhase2Data.pickUpNotReadyMilestones[i].icon,
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            HelpPhase2Data.pickUpNotReadyMilestones[i].title,
                            style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                                .copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5.sp,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            HelpPhase2Data.pickUpNotReadyMilestones[i].subtitle,
                            style: AppTextStyles.caption(color: const Color(0xFF6B7280))
                                .copyWith(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4EC),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            HelpPhase2Data.pickUpNotReadyFooter,
            style: AppTextStyles.caption(color: const Color(0xFF55605A)).copyWith(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
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
                      color: const Color(0xFFE9F0FA),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/bank.png',
                      width: 22.sp,
                      height: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet cash-out',
                          style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                              .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5.sp,
                          ),
                        ),
                        Text(
                          'Requested today 11:00 · Processing',
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
                  color: const Color(0xFFE9F0FA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Text(
                      '💳 Wallet',
                      style: AppTextStyles.caption(color: const Color(0xFF1565C0)).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Cash-out',
                      style: AppTextStyles.caption(color: const Color(0xFF1565C0)).copyWith(
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
        const HelpSectionTitle(label: 'We pulled your request'),
        SizedBox(height: 14.h),
        const HelpDetailRowsCard(
          lines: HelpPhase2Data.cashOutDetails,
          showDividers: true,
          dividerColor: Color(0xFFEEF0EC),
        ),
        SizedBox(height: 14.h),
        const HelpSectionTitle(label: "What's the issue?"),
        SizedBox(height: 14.h),
        for (var i = 0; i < HelpPhase2Data.cashOutIssues.length; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          HelpRadioOptionRow(
            label: HelpPhase2Data.cashOutIssues[i].label,
            subtitle: HelpPhase2Data.cashOutIssues[i].subtitle,
            selected: _selectedRadio == HelpPhase2Data.cashOutIssues[i].label,
            onTap: () => setState(
              () => _selectedRadio = HelpPhase2Data.cashOutIssues[i].label,
            ),
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

  Widget _serviceCard(
    String vendor,
    String detailLine,
    String badgeLead,
    String badgeTrail, {
    String? iconAsset,
    String iconEmoji = '🧰',
    Color iconBg = const Color(0xFFE0F2F1),
    Color badgeBg = const Color(0xFFE0F2F1),
    Color badgeColor = const Color(0xFF00695C),
  }) {
    return Container(
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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: iconAsset == null
                    ? Text(iconEmoji, style: TextStyle(fontSize: 18.sp))
                    : Image.asset(
                        iconAsset,
                        width: 22.sp,
                        height: 22.sp,
                        fit: BoxFit.contain,
                        errorBuilder: (_, error, stackTrace) => Text(
                          iconEmoji,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
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
                        fontSize: 14.5.sp,
                      ),
                    ),
                    Text(
                      detailLine,
                      style: AppTextStyles.caption(color: const Color(0xFF6B7280)).copyWith(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
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
              color: badgeBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Text(
                  badgeLead,
                  style: AppTextStyles.caption(color: badgeColor).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    badgeTrail,
                    style: AppTextStyles.caption(color: badgeColor).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
