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
  int _orderRating = 4;
  int _driverRating = 4;
  bool _submitting = false;
  String _driverName = OrderFlowData.driverName;
  String _subtitle = OrderFlowStrings.deliveredSubtitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) return;
    final order = await ref.read(ordersRepositoryProvider).getOrder(id);
    if (!mounted || order == null) return;
    final vendor = order['vendor'];
    final vendorName = vendor is Map<String, dynamic>
        ? vendor['name'] as String?
        : null;
    final driver = order['driver'];
    final driverName = driverDisplayName(
      driver is Map<String, dynamic> ? driver : null,
    );
    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) {
        _subtitle = 'Hope you enjoyed your order from $vendorName.';
      }
      if (driverName.isNotEmpty) _driverName = driverName;
    });
  }

  Future<void> _submit() async {
    final id = widget.orderId;
    if (id == null || id.isEmpty) {
      context.goHome(tab: 1);
      return;
    }
    setState(() => _submitting = true);
    await ref.read(ordersRepositoryProvider).submitReview(
          id,
          orderRating: _orderRating,
          driverRating: _driverRating,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    context.goHome(tab: 1);
  }

  Future<void> _reorder() async {
    final id = widget.orderId;
    if (id != null && id.isNotEmpty) {
      await ref.read(ordersRepositoryProvider).reorder(id);
    }
    if (!mounted) return;
    context.goHome(tab: 2, cartHasItems: true);
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      showHeader: false,
      body: ListView(
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
            onChanged: (v) => _orderRating = v,
          ),
          SizedBox(height: 14.h),
          OrderStarRatingCard(
            title: '${OrderFlowStrings.rateYourChamp} · $_driverName',
            onChanged: (v) => _driverRating = v,
          ),
          SizedBox(height: 14.h),
          PrimaryGreenButton(
            label: OrderFlowStrings.submitAndDone,
            backgroundColor: AppColors.cartTabActive,
            height: 52,
            onPressed: _submitting ? null : _submit,
          ),
          SizedBox(height: 14.h),
          OrderReorderButton(onPressed: _reorder),
        ],
      ),
    );
  }
}
