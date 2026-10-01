import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/vouchers/model/voucher_models.dart';
import 'package:yjeek_app/features/vouchers/widgets/voucher_card.dart';

class VoucherDetailScreen extends ConsumerStatefulWidget {
  const VoucherDetailScreen({super.key, required this.voucherId});

  final String voucherId;

  @override
  ConsumerState<VoucherDetailScreen> createState() =>
      _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends ConsumerState<VoucherDetailScreen> {
  CustomerVoucher? _voucher;
  bool _loading = true;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final v = _voucher;
    if (v == null) return;
    final diff = v.validTo.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    for (final status in ['active', 'used', 'expired']) {
      final list = await ref.read(vouchersRepositoryProvider).fetchVouchers(
            status: status,
          );
      CustomerVoucher? found;
      for (final v in list) {
        if (v.id == widget.voucherId) {
          found = v;
          break;
        }
      }
      if (found != null) {
        if (!mounted) return;
        setState(() {
          _voucher = found;
          _loading = false;
        });
        _tick();
        return;
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  String _countdownLabel() {
    if (_remaining <= Duration.zero) return 'Expired';
    final d = _remaining;
    if (d.inDays > 0) {
      return '${d.inDays}d ${d.inHours.remainder(24)}h ${d.inMinutes.remainder(60)}m left';
    }
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s left';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s left';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const NavBackHeader(
            title: 'Voucher',
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _voucher == null
                    ? Center(
                        child: Text(
                          'Voucher not found',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView(
                        padding: EdgeInsets.all(20.w),
                        children: [
                          if (_voucher!.status.toLowerCase() == 'active')
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              margin: EdgeInsets.only(bottom: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                _countdownLabel(),
                                style: AppTextStyles.labelMedium(
                                  color: const Color(0xFF7A5E12),
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          VoucherCard(voucher: _voucher!),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
