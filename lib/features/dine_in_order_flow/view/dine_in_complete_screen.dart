import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/dine_in_order_flow/model/dine_in_order_flow_data.dart';
import 'package:yjeek_app/features/dine_in_order_flow/view/widgets/dine_in_order_flow_widgets.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';
import 'package:yjeek_app/routes/route_names.dart';

class DineInCompleteScreen extends ConsumerStatefulWidget {
  const DineInCompleteScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<DineInCompleteScreen> createState() =>
      _DineInCompleteScreenState();
}

class _DineInCompleteScreenState extends ConsumerState<DineInCompleteScreen> {
  static const Color _screenBg = Color(0xFF8BAE9A);

  final _reviewController = TextEditingController();
  int _experienceRating = 5;
  int _foodRating = 4;
  double _staffTip = 0;
  bool _submitting = false;
  bool _reordering = false;
  bool _alreadyRated = false;
  String _thankYou = DineInOrderFlowStrings.thankYouVisit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _hydrate() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) return;
    final order = await ref.read(ordersRepositoryProvider).getOrder(id);
    if (!mounted || order == null) return;
    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final venue = order['venue'];
    final area = venue is Map ? venue['area']?.toString() : null;
    final review = order['review'];
    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) {
        _thankYou = area != null && area.isNotEmpty
            ? 'Thanks for dining at $vendorName · $area.'
            : 'Thanks for dining at $vendorName.';
      }
      _alreadyRated = review != null;
    });
  }

  double? _parseTipLabel(String? label) {
    if (label == null || label.isEmpty) return null;
    if (label == DineInOrderFlowStrings.customTip) return null;
    final cleaned = label.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  Future<void> _onTipChanged(String? label) async {
    if (label == null) {
      setState(() => _staffTip = 0);
      return;
    }
    if (label == DineInOrderFlowStrings.customTip) {
      final custom = await _askCustomTip();
      if (!mounted) return;
      setState(() => _staffTip = custom ?? 0);
      return;
    }
    setState(() => _staffTip = _parseTipLabel(label) ?? 0);
  }

  Future<double?> _askCustomTip() async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom tip'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'BHD amount',
            prefixText: 'BHD ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(NavigationStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, v != null && v >= 0 ? v : null);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _submit() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      context.go('${RouteNames.home}?tab=1');
      return;
    }
    if (_alreadyRated) {
      context.go('${RouteNames.home}?tab=1');
      return;
    }
    setState(() => _submitting = true);
    final ok = await ref.read(ordersRepositoryProvider).submitReview(
          id,
          orderRating: _experienceRating,
          experienceRating: _experienceRating,
          foodRating: _foodRating,
          comment: _reviewController.text.trim(),
          staffTipAmount: _staffTip > 0 ? _staffTip : null,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit rating. Try again.')),
      );
      return;
    }
    context.go('${RouteNames.home}?tab=1');
  }

  Future<void> _bookAgain() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      context.goHome(tab: 2, dineInCart: true);
      return;
    }
    setState(() => _reordering = true);
    final ok = await ref.read(ordersRepositoryProvider).reorder(id);
    if (!mounted) return;
    setState(() => _reordering = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reorder. Try again.')),
      );
      return;
    }
    context.goHome(tab: 2, cartHasItems: true, dineInCart: true);
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      backgroundColor: _screenBg,
      bottomNavIndex: 0,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          Align(
            alignment: Alignment.centerLeft,
            child: OrderSuccessIcon(size: 64.w),
          ),
          SizedBox(height: 14.h),
          Text(
            DineInOrderFlowStrings.visitComplete,
            textAlign: TextAlign.left,
            style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                .copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                  height: 1.2,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            _thankYou,
            textAlign: TextAlign.left,
            style: AppTextStyles.bodySmall(color: const Color(0xFF6B756E))
                .copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 13.sp,
                  height: 1.23,
                ),
          ),
          if (!_alreadyRated) ...[
            SizedBox(height: 14.h),
            OrderStarRatingCard(
              title: DineInOrderFlowStrings.rateExperience,
              initialRating: 5,
              onChanged: (v) => _experienceRating = v,
            ),
            SizedBox(height: 14.h),
            OrderStarRatingCard(
              title: DineInOrderFlowStrings.rateFood,
              initialRating: 4,
              onChanged: (v) => _foodRating = v,
            ),
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE0E6E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DineInOrderFlowStrings.tipStaff,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1.2,
                        ),
                  ),
                  SizedBox(height: 10.h),
                  DineInTipChips(onChanged: _onTipChanged),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            DineInReviewField(controller: _reviewController),
          ] else ...[
            SizedBox(height: 14.h),
            Text(
              'Thanks — you already rated this visit.',
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
            ),
          ],
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cartTabActive,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Text(
                _alreadyRated ? 'Done' : DineInOrderFlowStrings.submit,
                style: AppTextStyles.labelMedium(color: AppColors.white)
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton.icon(
              onPressed: _reordering ? null : _bookAgain,
              icon: Icon(Icons.refresh, size: 18.sp, color: AppColors.textPrimary),
              label: Text(
                DineInOrderFlowStrings.bookAgain,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: Color(0xFFE0E6E0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
