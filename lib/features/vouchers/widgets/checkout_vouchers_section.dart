import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/vouchers/model/voucher_models.dart';

/// Checkout voucher picker: evaluate → applicable / notApplicable.
class CheckoutVouchersSection extends ConsumerStatefulWidget {
  const CheckoutVouchersSection({
    super.key,
    required this.orderType,
    required this.selectedVoucherId,
    required this.onSelected,
    this.voucherTitles = const {},
    this.cartId,
    this.evaluateKey = '',
  });

  final String orderType;
  final String? selectedVoucherId;
  final ValueChanged<String?> onSelected;

  /// Optional id → title map from list API for richer labels.
  final Map<String, String> voucherTitles;

  final String? cartId;

  /// Changes when cart lines/totals change — triggers re-evaluate.
  final String evaluateKey;

  @override
  ConsumerState<CheckoutVouchersSection> createState() =>
      _CheckoutVouchersSectionState();
}

class _CheckoutVouchersSectionState
    extends ConsumerState<CheckoutVouchersSection> {
  CheckoutVoucherEvaluation? _eval;
  bool _loading = true;
  String? _error;
  bool _didAutoSelect = false;
  String _lastEvaluateKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant CheckoutVouchersSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final keyChanged = oldWidget.evaluateKey != widget.evaluateKey;
    final typeChanged = oldWidget.orderType != widget.orderType;
    final cartChanged = oldWidget.cartId != widget.cartId;
    if (typeChanged || keyChanged || cartChanged) {
      if (typeChanged || cartChanged) _didAutoSelect = false;
      _load();
    }
  }

  Future<void> _load() async {
    final key = '${widget.cartId ?? ''}|${widget.evaluateKey}';
    if (_loading && key == _lastEvaluateKey && _eval != null) return;
    _lastEvaluateKey = key;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final eval = await ref.read(vouchersRepositoryProvider).evaluate(
            cartId: widget.cartId,
            orderType: widget.orderType,
          );
      if (!mounted) return;
      setState(() {
        _eval = eval;
        _loading = false;
      });
      if (!_didAutoSelect) {
        _didAutoSelect = true;
        final autoId = eval.autoSelectedId;
        if (autoId != null &&
            (widget.selectedVoucherId == null ||
                widget.selectedVoucherId!.isEmpty)) {
          widget.onSelected(autoId);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
        _eval = CheckoutVoucherEvaluation.empty;
      });
    }
  }

  String _titleFor(String id) =>
      widget.voucherTitles[id] ?? 'Voucher';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vouchers',
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
              .copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
        ),
        SizedBox(height: 10.h),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        else if (_error != null)
          Text(
            _error!,
            style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
          )
        else ...[
          if ((_eval?.applicable.isEmpty ?? true) &&
              (_eval?.notApplicable.isEmpty ?? true))
            Text(
              'No vouchers for this order',
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
            ),
          if (_eval != null && _eval!.applicable.isNotEmpty) ...[
            Text(
              'Applicable',
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            ..._eval!.applicable.map((v) {
              final selected = widget.selectedVoucherId == v.voucherId;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _EvalTile(
                  title: _titleFor(v.voucherId),
                  subtitle:
                      'Save BHD ${v.estimatedSaving}${v.autoSelect ? ' · Best value' : ''}',
                  selected: selected,
                  onTap: () {
                    if (selected) {
                      widget.onSelected(null);
                    } else {
                      widget.onSelected(v.voucherId);
                    }
                  },
                ),
              );
            }),
            if (widget.selectedVoucherId != null)
              TextButton(
                onPressed: () => widget.onSelected(null),
                child: const Text('Clear voucher'),
              ),
          ],
          if (_eval != null && _eval!.notApplicable.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'Not applicable',
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            ..._eval!.notApplicable.map(
              (v) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _EvalTile(
                  title: _titleFor(v.voucherId),
                  subtitle: v.reason,
                  selected: false,
                  dimmed: true,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _EvalTile extends StatelessWidget {
  const _EvalTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    this.onTap,
    this.dimmed = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Opacity(
        opacity: dimmed ? 0.6 : 1,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall(
                      color: dimmed
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 18.sp),
          ],
        ),
      ),
    );
    if (onTap == null) return tile;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: tile,
    );
  }
}
