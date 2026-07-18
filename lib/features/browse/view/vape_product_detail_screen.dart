import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/vape_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/vape_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class VapeProductDetailScreen extends ConsumerStatefulWidget {
  const VapeProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final String productId;
  final int bottomNavIndex;

  @override
  ConsumerState<VapeProductDetailScreen> createState() =>
      _VapeProductDetailScreenState();
}

class _VapeProductDetailScreenState extends ConsumerState<VapeProductDetailScreen> {
  int _selectedNicotine = 0;

  VapeStore get _store => VapeData.storeById(widget.storeId);
  VapeProduct get _product => VapeData.productById(widget.productId);

  void _openCart() {
    ref.read(shellProvider.notifier).openVapeCartWithItems();
    context.goHome(tab: 2, vapeCart: true);
  }

  @override
  Widget build(BuildContext context) {
    final specs = _product.detailSpecs ?? _product.specs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          VapeStoreTopBar(
            store: _store,
            title: _product.name,
            onBack: () => context.pop(),
            onCart: _openCart,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              children: [
                Container(
                  width: double.infinity,
                  height: 220.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      colors: [_store.gradientStart, _store.gradientEnd],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  _product.name,
                  style: AppTextStyles.titleMedium().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'BHD ${_product.price}',
                  style: AppTextStyles.titleSmall(color: const Color(0xFF216B2E)).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  specs,
                  style: AppTextStyles.bodySmall(color: const Color(0xFF737873)).copyWith(
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                VapeAgeBanner(
                  detailed: true,
                  message: _product.ageWarningDetail,
                ),
                if (_product.nicotineOptions.isNotEmpty) ...[
                  SizedBox(height: 18.h),
                  Text(
                    VapeData.nicotineStrengthLabel,
                    style: AppTextStyles.labelMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (var i = 0; i < _product.nicotineOptions.length; i++)
                        VapeNicotineChip(
                          label: _product.nicotineOptions[i],
                          selected: _selectedNicotine == i,
                          onTap: () => setState(() => _selectedNicotine = i),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: GestureDetector(
              onTap: _openCart,
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB04F),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Add to cart · BHD ${_product.price}',
                  style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
