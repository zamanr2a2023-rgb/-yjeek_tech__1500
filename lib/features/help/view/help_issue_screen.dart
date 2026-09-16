import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/help_routes.dart';
import 'package:yjeek_app/features/help/model/help_data.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/help_phase2_issue_body.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';

class _OrderLineItem {
  const _OrderLineItem({
    required this.id,
    required this.label,
    required this.price,
    required this.quantity,
    required this.unitPrice,
  });

  final String id;
  final String label;
  final String price;
  final int quantity;
  final double unitPrice;
}

class HelpIssueScreen extends ConsumerStatefulWidget {
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
  ConsumerState<HelpIssueScreen> createState() => _HelpIssueScreenState();
}

class _HelpIssueScreenState extends ConsumerState<HelpIssueScreen> {
  List<_OrderLineItem> _items = const [];
  List<bool> _itemChecks = const [];
  String? _selectedChip;
  String? _selectedCancelReason;
  bool _confirmNotReceived = true;
  bool _feltUnwell = false;
  bool _loading = true;
  bool _submitting = false;
  bool _uploadingPhoto = false;
  bool _canCancel = true;
  bool _isFreeWindow = true;
  double _feePercentMax = 0;
  String _orderTotalBhd = '0.000';
  String _shortId = '';
  String? _photoUrl;
  String? _statusLabel;
  String? _statusRaw;
  String? _phase2Remark;
  Map<String, dynamic>? _cancelQuote;
  final _noteController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedChip = HelpData.foodQualityOptions.first;
    _selectedCancelReason = HelpData.cancelReasons.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _hydrate() async {
    setState(() => _loading = true);
    final order =
        await ref.read(ordersRepositoryProvider).getOrder(widget.orderId);
    if (!mounted) return;

    final fallback = HelpData.contextForOrderId(widget.orderId).order;
    final parsed = <_OrderLineItem>[];
    if (order != null) {
      final rawItems = order['items'];
      if (rawItems is List) {
        for (final row in rawItems) {
          if (row is! Map) continue;
          final id = row['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final name = row['name']?.toString() ?? 'Item';
          final qty = (row['quantity'] as num?)?.toInt() ?? 1;
          final unit = (row['unitPrice'] as num?)?.toDouble() ?? 0;
          parsed.add(
            _OrderLineItem(
              id: id,
              label: '$qty× $name',
              price: 'BHD ${(unit * qty).toStringAsFixed(3)}',
              quantity: qty,
              unitPrice: unit,
            ),
          );
        }
      }
      final total = order['totalAmount'];
      _orderTotalBhd =
          total is num ? total.toStringAsFixed(3) : fallback.totalBhd;
      final orderNumber = order['orderNumber']?.toString();
      _shortId = orderNumber != null && orderNumber.isNotEmpty
          ? (orderNumber.startsWith('#') ? orderNumber : '#$orderNumber')
          : fallback.shortId;
      _canCancel = order['canCancel'] == true ||
          (order['cancelQuote'] is Map &&
              (order['cancelQuote'] as Map)['canCancel'] == true);
      _statusRaw = order['status']?.toString();
      _statusLabel = _statusRaw?.replaceAll('_', ' ');
      final quote = order['cancelQuote'];
      if (quote is Map<String, dynamic>) {
        _cancelQuote = quote;
        _isFreeWindow = quote['isFreeWindow'] == true;
        _feePercentMax = (quote['feePercentMax'] as num?)?.toDouble() ?? 0;
        final ot = quote['orderTotal'];
        if (ot is num) _orderTotalBhd = ot.toStringAsFixed(3);
      }
    } else {
      _orderTotalBhd = fallback.totalBhd;
      _shortId = fallback.shortId;
      // Do not fall back to demo/static line items — Wrong order must use API items.
      setState(() {
        _items = const [];
        _itemChecks = const [];
        _loading = false;
      });
      return;
    }

    setState(() {
      _items = parsed;
      _itemChecks = List<bool>.filled(parsed.length, false);
      _loading = false;
    });
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

  bool get _phase2HasExternalBottom => false;

  bool get _showReportBanner =>
      widget.type == HelpIssueType.missingItems ||
      widget.type == HelpIssueType.wrongOrder;

  bool get _needsItems =>
      widget.type == HelpIssueType.missingItems ||
      widget.type == HelpIssueType.wrongOrder;

  bool get _photoRequired => widget.type == HelpIssueType.damagedSpilled;

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    final url = await ref.read(userRepositoryProvider).uploadFile(
          file.path,
          filename: file.name,
          // Public CUSTOMER category already live on api.yjeektech.com.
          category: 'address-photos',
        );
    if (!mounted) return;
    setState(() => _uploadingPhoto = false);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }
    setState(() => _photoUrl = url);
  }

  List<Map<String, dynamic>> _selectedTicketItems() {
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < _items.length; i++) {
      if (i >= _itemChecks.length || !_itemChecks[i]) continue;
      // Skip mock fallback ids that aren't real order item cuids.
      if (_items[i].id.length < 10) continue;
      out.add({
        'orderItemId': _items[i].id,
        'quantity': _items[i].quantity,
      });
    }
    return out;
  }

  double? _disputedAmount() {
    var sum = 0.0;
    for (var i = 0; i < _items.length; i++) {
      if (i >= _itemChecks.length || !_itemChecks[i]) continue;
      sum += _items[i].unitPrice * _items[i].quantity;
    }
    return sum > 0 ? sum : null;
  }

  String _buildRemark() {
    if (_phase2Remark != null && _phase2Remark!.isNotEmpty) {
      return _phase2Remark!;
    }
    final parts = <String>[];
    final note = _noteController.text.trim();
    if (note.isNotEmpty) parts.add(note);
    if (_selectedChip != null && widget.type == HelpIssueType.foodQuality) {
      parts.add('Quality: $_selectedChip');
    }
    if (_feltUnwell) parts.add('Felt unwell after eating');
    if (_selectedCancelReason != null &&
        widget.type == HelpIssueType.cancelOrder) {
      parts.add('Cancel reason: $_selectedCancelReason');
    }
    if (_confirmNotReceived && widget.type == HelpIssueType.notReceived) {
      parts.add('Customer confirmed order not received');
    }
    return parts.isEmpty ? 'Customer submitted $_title' : parts.join(' · ');
  }

  HelpChatVariant _chatVariantForType() => switch (widget.type) {
        HelpIssueType.paymentIssue => HelpChatVariant.payment,
        HelpIssueType.serviceNoShow => HelpChatVariant.serviceNoShow,
        _ => HelpChatVariant.support,
      };

  Future<void> _submit([String? phase2Remark]) async {
    if (_submitting) return;
    if (phase2Remark != null) _phase2Remark = phase2Remark;

    if (_needsItems && !_itemChecks.any((v) => v)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one item')),
      );
      return;
    }
    if (_photoRequired && (_photoUrl == null || _photoUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo of the damage')),
      );
      return;
    }
    if (widget.type == HelpIssueType.notReceived && !_confirmNotReceived) {
      return;
    }

    setState(() => _submitting = true);

    if (widget.type == HelpIssueType.cancelOrder) {
      if (!_canCancel) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This order can no longer be cancelled'),
            backgroundColor: Color(0xFFB42318),
          ),
        );
        return;
      }
      final ok = await ref.read(ordersRepositoryProvider).cancel(
            widget.orderId,
            reason: _selectedCancelReason ?? 'Customer cancelled via help',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled')),
      );
      context.pop();
      return;
    }

    if (widget.type == HelpIssueType.modifyRequest) {
      final ticket = await ref.read(supportRepositoryProvider).createTicket(
            subject: '$_title · $_shortId',
            remark: _buildRemark(),
            orderId: widget.orderId,
            issueType: widget.type.apiIssueType,
          );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (ticket == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not submit your request'),
            backgroundColor: Color(0xFFB42318),
          ),
        );
        return;
      }
      context.push(
        HelpRoutes.helpFlow(
          flow: HelpFlowType.modifyAwaiting,
          orderId: widget.orderId,
          tab: widget.bottomNavIndex,
        ),
      );
      return;
    }

    final ticket = await ref.read(supportRepositoryProvider).createTicket(
          subject: '$_title · $_shortId',
          remark: _buildRemark(),
          orderId: widget.orderId,
          issueType: widget.type.apiIssueType,
          items: _needsItems ? _selectedTicketItems() : null,
          evidenceUrls: _photoUrl != null ? [_photoUrl!] : null,
          disputedAmount: _needsItems ? _disputedAmount() : null,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ticket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not submit your request'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ticket.reused
              ? 'Continuing your existing request'
              : ticket.displayCode.isNotEmpty
              ? 'Submitted · ${ticket.displayCode}'
              : 'Your request has been submitted',
        ),
      ),
    );

    context.push(
      HelpRoutes.helpChat(
        variant: _chatVariantForType(),
        ticketId: ticket.id,
        orderId: widget.orderId,
        tab: widget.bottomNavIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderContext = HelpData.contextForOrderId(widget.orderId);
    final hydratedContext = HelpOrderContext(
      category: orderContext.category,
      isScheduled: orderContext.isScheduled,
      order: HelpOrder(
        vendorName: orderContext.order.vendorName,
        orderId: widget.orderId,
        shortId: _shortId.isNotEmpty ? _shortId : orderContext.order.shortId,
        statusLabel: _statusLabel ?? orderContext.order.statusLabel,
        itemCount: _items.isNotEmpty
            ? _items.fold<int>(0, (s, e) => s + e.quantity)
            : orderContext.order.itemCount,
        totalBhd: _orderTotalBhd,
        deliveredAt: orderContext.order.deliveredAt,
        compactSubtitle: orderContext.order.compactSubtitle,
      ),
    );

    return HelpScreenScaffold(
      title: _title,
      bottomNavIndex: widget.bottomNavIndex,
      showBottomNav: false,
      darkTitle: false,
      banner: _showReportBanner
          ? const HelpInfoBanner(message: HelpData.reportWindowBanner)
          : null,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _buildIssueBody(hydratedContext),
      bottom: _isPhase2Issue && _phase2HasExternalBottom
          ? _buildPhase2Bottom()
          : null,
    );
  }

  Widget _buildScrollForm(List<Widget> children) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      children: [
        ...children,
        if (_submitting)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
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
            onTap: _submitting ? null : _submit,
          ),
        ]),
      HelpIssueType.wrongOrder => _buildScrollForm([
          ..._buildWrongOrderFields(),
          HelpPrimaryButton(
            label: 'Submit',
            showCheck: true,
            inline: true,
            onTap: _submitting ? null : _submit,
          ),
        ]),
      HelpIssueType.damagedSpilled => _buildScrollForm([
          ..._buildDamagedSpilledFields(),
          HelpPrimaryButton(
            label: 'Submit & get refund',
            inline: true,
            onTap: _submitting ? null : _submit,
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
            onTap: (!_confirmNotReceived || _submitting) ? null : _submit,
          ),
        ]),
      HelpIssueType.foodQuality => _buildScrollForm([
          ..._buildFoodQualityFields(),
          HelpPrimaryButton(
            label: 'Submit complaint',
            showCheck: true,
            inline: true,
            onTap: _submitting ? null : _submit,
          ),
        ]),
      HelpIssueType.cancelOrder => _buildScrollForm([
          HelpWarningBanner(
            title: !_canCancel
                ? 'Cancellation unavailable'
                : (_statusRaw == 'PREPARING' || _statusRaw == 'CONFIRMED'
                    ? 'Vendor is preparing your order'
                    : (_isFreeWindow
                        ? 'Free cancellation available'
                        : 'Outside free window')),
            subtitle: _cancelQuote?['policyNote']?.toString() ??
                (_canCancel
                    ? 'Cancelling now may incur a fee'
                    : 'This order can no longer be cancelled from the app'),
          ),
          SizedBox(height: 14.h),
          if (_canCancel) ...[
            const HelpFormHeading(title: 'Why are you cancelling?'),
            SizedBox(height: 10.h),
            HelpChipSelector(
              options: HelpData.cancelReasons,
              selected: _selectedCancelReason,
              onSelected: (value) =>
                  setState(() => _selectedCancelReason = value),
            ),
            SizedBox(height: 14.h),
          ],
          HelpRefundSummaryCard(
            orderTotalBhd: _orderTotalBhd,
            canCancel: _canCancel,
            showFeeEstimate: _canCancel && _feePercentMax > 0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Column(
              children: [
                if (_canCancel)
                  HelpDestructiveButton(
                    label: 'Cancel order',
                    onTap: _submitting ? null : () => _submit(),
                  )
                else
                  HelpPrimaryButton(
                    label: 'Contact support',
                    showCheck: true,
                    inline: true,
                    onTap: _submitting
                        ? null
                        : () async {
                            final support =
                                ref.read(supportRepositoryProvider);
                            final active = await support
                                .findActiveTicketForOrder(widget.orderId);
                            if (!context.mounted) return;
                            if (active != null) {
                              context.push(
                                HelpRoutes.helpChat(
                                  ticketId: active.id,
                                  orderId: widget.orderId,
                                  tab: widget.bottomNavIndex,
                                ),
                              );
                              return;
                            }
                            final ticket = await support.createTicket(
                              subject: '$_title · $_shortId',
                              remark: 'Customer contacted support from issue form.',
                              orderId: widget.orderId,
                              issueType: widget.type.apiIssueType,
                            );
                            if (!context.mounted) return;
                            if (ticket == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not start support chat'),
                                  backgroundColor: Color(0xFFB42318),
                                ),
                              );
                              return;
                            }
                            context.push(
                              HelpRoutes.helpChat(
                                ticketId: ticket.id,
                                orderId: widget.orderId,
                                tab: widget.bottomNavIndex,
                              ),
                            );
                          },
                  ),
                SizedBox(height: 10.h),
                HelpOutlineButton(
                  label: _canCancel ? 'Keep my order' : 'Go back',
                  onTap: () => context.pop(),
                ),
              ],
            ),
          ),
        ]),
      HelpIssueType.orderLate => _buildScrollForm([
          const HelpFormHeading(
            title: 'Order late +15?',
            subtitle:
                'When your order is 15 minutes past ETA, an instant wallet credit is '
                'applied and you’ll get a notification.',
          ),
          SizedBox(height: 16.h),
          HelpPrimaryButton(
            label: 'Report late order',
            showCheck: true,
            inline: true,
            onTap: _submitting ? null : () => _submit(),
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
                onSubmit: (remark) => _submit(remark),
              )
            else
              ..._buildGenericForm(),
          ],
        ),
    };
  }

  List<Widget> _buildOrderItemCheckboxCard() {
    if (_items.isEmpty) {
      return [
        HelpCard(
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Text(
              'No items found on this order',
              style: AppTextStyles.labelSmall(color: const Color(0xFF6B7B6E)),
            ),
          ),
        ),
      ];
    }
    return [
      HelpCard(
        child: Column(
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) SizedBox(height: 12.h),
              HelpItemCheckboxRow(
                label: _items[i].label,
                price: _items[i].price,
                checked: i < _itemChecks.length && _itemChecks[i],
                onChanged: (value) => setState(() {
                  if (i < _itemChecks.length) _itemChecks[i] = value;
                }),
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
      HelpPhotoUploadBox(
        onTap: _pickPhoto,
        imageUrl: _photoUrl,
        uploading: _uploadingPhoto,
      ),
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
      HelpPhotoUploadBox(
        onTap: _pickPhoto,
        imageUrl: _photoUrl,
        uploading: _uploadingPhoto,
      ),
    ];
  }

  List<Widget> _buildDamagedSpilledFields() {
    return [
      const HelpFormHeading(
        title: 'Add a photo of the damage',
        subtitle: 'A clear photo lets us refund you automatically.',
      ),
      SizedBox(height: 14.h),
      HelpPhotoUploadBox(
        onTap: _pickPhoto,
        imageUrl: _photoUrl,
        uploading: _uploadingPhoto,
      ),
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
      GestureDetector(
        onTap: _pickPhoto,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE6EBE3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 20.sp,
                color: const Color(0xFF6B7B6E),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  _photoUrl != null
                      ? 'Photo attached · tap to change'
                      : 'Add a photo (optional)',
                  style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                      .copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              if (_uploadingPhoto)
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
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
              style: AppTextStyles.labelSmall(color: const Color(0xFFC0392B))
                  .copyWith(
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
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                    .copyWith(
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

  List<Widget> _buildGenericForm() {
    return [
      const HelpFormHeading(
        title: 'How can we help?',
        subtitle: 'Describe the issue and our team will follow up.',
      ),
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
        onTap: _submitting ? null : _submit,
      ),
    ];
  }

  Widget? _buildPhase2Bottom() => null;
}
