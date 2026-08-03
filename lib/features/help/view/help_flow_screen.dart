import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class HelpFlowScreen extends ConsumerStatefulWidget {
  const HelpFlowScreen({
    super.key,
    required this.flow,
    this.orderId,
    this.bottomNavIndex = 4,
  });

  final HelpFlowType flow;
  final String? orderId;
  final int bottomNavIndex;

  @override
  ConsumerState<HelpFlowScreen> createState() => _HelpFlowScreenState();
}

class _HelpFlowScreenState extends ConsumerState<HelpFlowScreen> {
  String? _selectedReason;
  bool _confirmFee = true;
  bool _loading = false;
  bool _submitting = false;
  String _vendor = HelpPhase2Data.scheduledGroceryOrder.vendor;
  String _orderNumber = HelpPhase2Data.scheduledGroceryOrder.orderId;
  String _subtitle = HelpPhase2Data.scheduledGroceryOrder.subtitle;
  String _totalBhd = '24.600';
  bool _canCancel = true;
  bool _isFreeWindow = true;
  double _feePercent = 0;
  double _refundMin = 0;
  double _refundMax = 0;
  String? _cancelRef;
  String? _policyNote;

  @override
  void initState() {
    super.initState();
    _selectedReason = HelpPhase2Data.scheduledCancelReasons.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) return;
    setState(() => _loading = true);
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    if (!mounted || order == null) {
      setState(() => _loading = false);
      return;
    }
    final vendor = order['vendor'];
    final quote = order['cancelQuote'];
    final total = order['totalAmount'];
    setState(() {
      _vendor = vendor is Map
          ? (vendor['name']?.toString() ?? _vendor)
          : _vendor;
      final number = order['orderNumber']?.toString();
      if (number != null && number.isNotEmpty) {
        _orderNumber = number.startsWith('#') ? number : '#$number';
      }
      _totalBhd = total is num ? total.toStringAsFixed(3) : _totalBhd;
      _subtitle =
          '${order['itemCount'] ?? 0} items · BHD $_totalBhd';
      if (quote is Map) {
        _canCancel = quote['canCancel'] == true;
        _isFreeWindow = quote['isFreeWindow'] == true;
        _feePercent = (quote['feePercentMax'] as num?)?.toDouble() ?? 0;
        _refundMin = (quote['refundEstimateMin'] as num?)?.toDouble() ?? 0;
        _refundMax = (quote['refundEstimateMax'] as num?)?.toDouble() ?? 0;
        _policyNote = quote['policyNote']?.toString();
      }
      _loading = false;
    });
  }

  Future<void> _confirmCancel() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      context.push(
        HelpRoutes.helpFlow(
          flow: HelpFlowType.scheduledCancelConfirmed,
          tab: widget.bottomNavIndex,
        ),
      );
      return;
    }
    if (!_canCancel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This order can no longer be cancelled'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final ok = await ref.read(ordersRepositoryProvider).cancel(
          orderId,
          reason: _selectedReason ?? 'Scheduled order cancelled',
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not cancel this order'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }
    setState(() {
      _cancelRef = 'CX-${DateTime.now().year}-${DateTime.now().millisecond}';
    });
    context.push(
      HelpRoutes.helpFlow(
        flow: HelpFlowType.scheduledCancelConfirmed,
        orderId: orderId,
        tab: widget.bottomNavIndex,
      ),
    );
  }

  String get _title => switch (widget.flow) {
        HelpFlowType.scheduledCancelFree => 'Cancel scheduled order',
        HelpFlowType.scheduledCancelOutside => 'Cancel scheduled order',
        HelpFlowType.scheduledCancelConfirmed => 'Cancellation confirmed',
        HelpFlowType.modifyAwaiting => 'Change requested',
        HelpFlowType.modifyCannotAccommodate => 'Vendor response',
      };

  @override
  Widget build(BuildContext context) {
    // Auto-pick SC1 vs SC3 when opening free flow but quote says outside window.
    final effectiveFlow =
        widget.flow == HelpFlowType.scheduledCancelFree && !_isFreeWindow
            ? HelpFlowType.scheduledCancelOutside
            : widget.flow;

    return HelpScreenScaffold(
      title: _title,
      bottomNavIndex: widget.bottomNavIndex,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              children: _buildBody(effectiveFlow),
            ),
      bottom: _buildBottom(context, effectiveFlow),
    );
  }

  List<Widget> _buildBody(HelpFlowType flow) {
    return switch (flow) {
      HelpFlowType.scheduledCancelFree => [
          _orderCard(_vendor, _orderNumber, _subtitle),
          SizedBox(height: 14.h),
          const HelpInfoBanner(
            message:
                'You’re within the free cancellation window — no fee will be charged.',
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
            lines: [
              HelpDetailLine(label: 'Order total', value: 'BHD $_totalBhd'),
              const HelpDetailLine(
                label: 'Cancellation fee',
                value: 'BHD 0.000 — Free',
                valueColor: Color(0xFF0F4D27),
              ),
              HelpDetailLine(
                label: 'Refund to Wallet',
                value: 'BHD $_totalBhd',
                valueColor: const Color(0xFF0F4D27),
              ),
            ],
          ),
        ],
      HelpFlowType.scheduledCancelOutside => [
          _orderCard(_vendor, _orderNumber, _subtitle),
          SizedBox(height: 14.h),
          HelpAlertCard(
            icon: Icons.schedule,
            title: 'Free window closed',
            subtitle: _policyNote ??
                'A fee may apply based on preparation stage (up to ${_feePercent.toStringAsFixed(0)}%).',
            backgroundColor: const Color(0xFFFBEFE0),
            foregroundColor: const Color(0xFFE08A1E),
            subtitleColor: const Color(0xFF9A6A1E),
          ),
          SizedBox(height: 14.h),
          HelpDetailRowsCard(
            title: 'Estimated refund',
            lines: [
              HelpDetailLine(label: 'Order total', value: 'BHD $_totalBhd'),
              HelpDetailLine(
                label: 'Cancellation fee',
                value: 'Up to ${_feePercent.toStringAsFixed(0)}% · prep-based',
                valueColor: const Color(0xFFE08A1E),
              ),
              HelpDetailLine(
                label: 'Estimated refund',
                value:
                    'BHD ${_refundMin.toStringAsFixed(3)} – ${_refundMax.toStringAsFixed(3)}',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => setState(() => _confirmFee = !_confirmFee),
            child: Row(
              children: [
                Icon(
                  _confirmFee
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'I understand a cancellation fee may apply based on the preparation stage.',
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFF6B7B6E),
                    ).copyWith(fontSize: 12.sp, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      HelpFlowType.scheduledCancelConfirmed => [
          SizedBox(height: 24.h),
          Center(
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3DE),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: AppColors.primary, size: 36.sp),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              'Scheduled order cancelled',
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 18.sp),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'Your cancellation was processed.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: const Color(0xFF6B7B6E)),
            ),
          ),
          SizedBox(height: 16.h),
          HelpDetailRowsCard(
            title: 'Details',
            lines: [
              HelpDetailLine(
                label: 'Refunded to Wallet',
                value: '+ BHD $_totalBhd',
                valueColor: const Color(0xFF0F4D27),
              ),
              HelpDetailLine(label: 'Order', value: _orderNumber),
              HelpDetailLine(
                label: 'Reference',
                value: _cancelRef ?? 'CX-pending',
              ),
            ],
          ),
        ],
      HelpFlowType.modifyAwaiting => [
          const HelpAlertCard(
            icon: Icons.hourglass_top_outlined,
            title: 'Waiting for approval',
            subtitle: 'Vendor usually responds within 2 hours.',
            backgroundColor: Color(0xFFFBEFE0),
            foregroundColor: Color(0xFFE08A1E),
            subtitleColor: Color(0xFF9A6A1E),
          ),
          SizedBox(height: 14.h),
          _orderCard(_vendor, _orderNumber, _subtitle),
          SizedBox(height: 12.h),
          Text(
            'Your original delivery time stays active until the vendor responds.',
            style: AppTextStyles.caption(color: const Color(0xFF6B7B6E))
                .copyWith(fontSize: 11.5.sp),
          ),
        ],
      HelpFlowType.modifyCannotAccommodate => [
          HelpAlertCard(
            icon: Icons.event_busy_outlined,
            title: 'Vendor can\'t accommodate',
            subtitle:
                '$_vendor couldn\'t accept the new time. Your original order is still confirmed.',
            backgroundColor: const Color(0xFFFBEAEC),
            foregroundColor: const Color(0xFFC0392B),
            subtitleColor: const Color(0xFF9A3A3A),
          ),
          SizedBox(height: 14.h),
          const HelpSectionTitle(label: 'What would you like to do?'),
          SizedBox(height: 10.h),
          _orderCard(_vendor, _orderNumber, 'Original order'),
        ],
    };
  }

  Widget? _buildBottom(BuildContext context, HelpFlowType flow) {
    return switch (flow) {
      HelpFlowType.scheduledCancelFree => HelpPrimaryButton(
          label: _submitting ? 'Cancelling…' : 'Confirm free cancellation',
          showCheck: true,
          onTap: _submitting ? null : _confirmCancel,
        ),
      HelpFlowType.scheduledCancelOutside => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Column(
            children: [
              HelpOrangeButton(
                label: _submitting ? 'Cancelling…' : 'Continue to cancel',
                onTap: (!_confirmFee || _submitting) ? null : _confirmCancel,
              ),
              SizedBox(height: 10.h),
              HelpOutlineButton(
                label: 'Keep my order',
                onTap: () => context.pop(),
              ),
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
              HelpPrimaryButton(
                label: 'Notify me & keep waiting',
                onTap: () => context.pop(),
              ),
              SizedBox(height: 10.h),
              HelpOutlineButton(
                label: 'Preview: vendor response',
                onTap: () => context.push(
                  HelpRoutes.helpFlow(
                    flow: HelpFlowType.modifyCannotAccommodate,
                    orderId: widget.orderId,
                    tab: widget.bottomNavIndex,
                  ),
                ),
              ),
            ],
          ),
        ),
      HelpFlowType.modifyCannotAccommodate => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Column(
            children: [
              HelpPrimaryButton(
                label: 'Keep my original order',
                onTap: () => context.pop(),
              ),
              SizedBox(height: 10.h),
              HelpOrangeButton(
                label: 'Cancel order · outside-window policy',
                onTap: () => context.push(
                  HelpRoutes.helpFlow(
                    flow: HelpFlowType.scheduledCancelOutside,
                    orderId: widget.orderId,
                    tab: widget.bottomNavIndex,
                  ),
                ),
              ),
            ],
          ),
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
        itemCount: 1,
        totalBhd: _totalBhd,
        deliveredAt: subtitle,
        compactSubtitle: subtitle,
      ),
    );
  }
}
