import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';
import 'package:yjeek_app/features/services_booking/services_booking_routes.dart';
import 'package:yjeek_app/features/services_order_flow/model/services_order_flow_data.dart';
import 'package:yjeek_app/features/services_order_flow/view/widgets/services_order_flow_widgets.dart';
import 'package:yjeek_app/routes/route_names.dart';

class ServicesCompleteScreen extends ConsumerStatefulWidget {
  const ServicesCompleteScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<ServicesCompleteScreen> createState() =>
      _ServicesCompleteScreenState();
}

class _ServicesCompleteScreenState
    extends ConsumerState<ServicesCompleteScreen> {
  static const Color _text = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B756E);
  static const Color _green = Color(0xFF2E9E4D);
  static const Color _border = Color(0xFFE0E6E0);
  static const Color _bg = Color(0xFFF2F7F2);

  int _providerRating = 5;
  int _serviceRating = 5;
  double _staffTip = 0;
  bool _submitting = false;
  bool _reordering = false;
  bool _alreadyRated = false;
  String _thankYou = ServicesOrderFlowStrings.thankYouVisit;

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
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;
    final review = order['review'];
    setState(() {
      if (vendorName != null && vendorName.isNotEmpty) {
        _thankYou = 'Hope you enjoyed your visit to $vendorName.';
      }
      _alreadyRated = review != null;
    });
  }

  double? _parseTipLabel(String? label) {
    if (label == null || label.isEmpty) return null;
    if (label == ServicesOrderFlowStrings.customTip) return null;
    final cleaned = label.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  Future<void> _onTipChanged(String? label) async {
    if (label == null) {
      setState(() => _staffTip = 0);
      return;
    }
    if (label == ServicesOrderFlowStrings.customTip) {
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
          orderRating: _providerRating,
          experienceRating: _providerRating,
          foodRating: _serviceRating,
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
      context.push(BrowseRoutes.servicesBrowse());
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
    context.push(ServicesBookingRoutes.booking);
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    final topPad = (safeTop < 44.h ? 44.h : safeTop) + 20.h;

    return OrderFlowScaffold(
      showHeader: false,
      bottomNavIndex: 0,
      backgroundColor: _bg,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, topPad, 20.w, 24.h),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: ServicesConfirmedIcon(),
          ),
          SizedBox(height: 14.h),
          Text(
            ServicesOrderFlowStrings.serviceComplete,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: _text,
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 29 / 24,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            _thankYou,
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              color: _muted,
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              height: 16 / 13,
            ),
          ),
          if (!_alreadyRated) ...[
            SizedBox(height: 14.h),
            OrderStarRatingCard(
              title: ServicesOrderFlowStrings.rateProvider,
              initialRating: 5,
              onChanged: (v) => _providerRating = v,
            ),
            SizedBox(height: 14.h),
            OrderStarRatingCard(
              title: ServicesOrderFlowStrings.rateService,
              initialRating: 5,
              onChanged: (v) => _serviceRating = v,
            ),
            SizedBox(height: 14.h),
            OrderFlowCard(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ServicesOrderFlowStrings.tipSpecialist,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      color: _text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 17 / 14,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ServicesTipChips(onChanged: _onTipChanged),
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: 14.h),
            Text(
              'Thanks — you already rated this booking.',
              style: GoogleFonts.inter(color: _muted, fontSize: 13.sp),
            ),
          ],
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Text(
                _alreadyRated ? 'Done' : ServicesOrderFlowStrings.submit,
                style: GoogleFonts.inter(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  height: 19 / 16,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: _reordering ? null : _bookAgain,
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                backgroundColor: AppColors.white,
                side: const BorderSide(color: _border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: _text, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    ServicesOrderFlowStrings.bookAgain,
                    style: GoogleFonts.inter(
                      color: _text,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      height: 18 / 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
