import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class DeliveredRateScreen extends ConsumerStatefulWidget {
  const DeliveredRateScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<DeliveredRateScreen> createState() =>
      _DeliveredRateScreenState();
}

class _DeliveredRateScreenState extends ConsumerState<DeliveredRateScreen> {
  final _reviewController = TextEditingController();
  int _orderRating = 4;
  int _driverRating = 4;
  bool _submitting = false;
  bool _hydrating = true;
  bool _alreadyRated = false;
  String _driverName = 'your champ';
  String _subtitle = OrderFlowStrings.deliveredSubtitle;

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

  void _applyReview(SubmittedReview review) {
    _alreadyRated = true;
    _orderRating = review.orderRating ?? review.foodRating ?? _orderRating;
    _driverRating = review.driverRating ?? _driverRating;
    if (review.comment != null) {
      _reviewController.text = review.comment!;
    }
  }

  Future<void> _hydrate() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _hydrating = false);
      return;
    }
    final order = await ref.read(ordersRepositoryProvider).getOrder(id);
    if (!mounted) return;
    if (order == null) {
      setState(() => _hydrating = false);
      return;
    }
    final vendor = order['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final champ = order['champ'];
    final driver = order['driver'];
    final champMap = champ is Map
        ? Map<String, dynamic>.from(champ)
        : driver is Map
            ? Map<String, dynamic>.from(driver)
            : null;
    final driverName = driverDisplayName(champMap);
    final review = submittedReviewFromOrder(order);
    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) {
        _subtitle = 'Hope you enjoyed your order from $vendorName.';
      }
      if (driverName.isNotEmpty) _driverName = driverName;
      if (review != null) _applyReview(review);
      _hydrating = false;
    });
  }

  Future<void> _submit() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      context.goHome(tab: 1);
      return;
    }
    if (_alreadyRated) {
      context.goHome(tab: 1);
      return;
    }
    setState(() => _submitting = true);
    final comment = _reviewController.text.trim();
    final ok = await ref.read(ordersRepositoryProvider).submitReview(
          id,
          orderRating: _orderRating,
          driverRating: _driverRating,
          foodRating: _orderRating,
          comment: comment.isEmpty ? null : comment,
        );
    if (!mounted) return;
    if (!ok) {
      await _hydrate();
      if (!mounted) return;
      setState(() => _submitting = false);
      if (_alreadyRated) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit rating. Try again.')),
      );
      return;
    }
    setState(() {
      _submitting = false;
      _alreadyRated = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your rating')),
    );
  }

  Future<void> _reorder() async {
    final id = widget.orderId;
    if (id != null && id.isNotEmpty) {
      final ok = await ref.read(ordersRepositoryProvider).reorder(id);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reorder')),
        );
        return;
      }
    }
    if (!mounted) return;
    context.goHome(tab: 2, cartHasItems: true);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_hydrating && !_submitting && !_alreadyRated;

    return OrderFlowScaffold(
      showHeader: false,
      body: _hydrating
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: OrderSuccessIcon(size: 64),
                ),
                SizedBox(height: 14.h),
                Text(
                  OrderFlowStrings.delivered,
                  style: AppTextStyles.titleMedium(color: AppColors.textPrimary)
                      .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 24.sp,
                        height: 29 / 24,
                      ),
                ),
                SizedBox(height: 14.h),
                Text(
                  _subtitle,
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary)
                      .copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        height: 16 / 13,
                      ),
                ),
                SizedBox(height: 14.h),
                OrderStarRatingCard(
                  title: OrderFlowStrings.rateYourOrder,
                  initialRating: _orderRating,
                  readOnly: _alreadyRated,
                  onChanged: _alreadyRated ? null : (v) => _orderRating = v,
                ),
                SizedBox(height: 14.h),
                OrderStarRatingCard(
                  title: '${OrderFlowStrings.rateYourChamp} · $_driverName',
                  initialRating: _driverRating,
                  readOnly: _alreadyRated,
                  onChanged: _alreadyRated ? null : (v) => _driverRating = v,
                ),
                SizedBox(height: 14.h),
                OrderReviewField(
                  controller: _reviewController,
                  readOnly: _alreadyRated,
                ),
                if (_alreadyRated) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Your rating has been submitted.',
                    style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                  ),
                ],
                SizedBox(height: 14.h),
                PrimaryGreenButton(
                  label: _alreadyRated
                      ? 'Done'
                      : OrderFlowStrings.submitAndDone,
                  backgroundColor: AppColors.cartTabActive,
                  height: 52,
                  onPressed: canSubmit || _alreadyRated ? _submit : null,
                ),
                SizedBox(height: 14.h),
                OrderReorderButton(onPressed: _reorder),
              ],
            ),
    );
  }
}
