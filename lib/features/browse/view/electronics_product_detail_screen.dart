import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/electronics_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class ElectronicsProductDetailScreen extends ConsumerStatefulWidget {
  const ElectronicsProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
    this.bottomNavIndex = 0,
  });

  final String storeId;
  final String productId;
  final int bottomNavIndex;

  @override
  ConsumerState<ElectronicsProductDetailScreen> createState() =>
      _ElectronicsProductDetailScreenState();
}

class _ElectronicsProductDetailScreenState extends ConsumerState<ElectronicsProductDetailScreen> {
  int _quantity = 1;
  int _selectedStorage = 0;
  int _selectedColor = 0;

  ElectronicsStore get _store => ElectronicsData.storeById(widget.storeId);
  ElectronicsProduct get _product => ElectronicsData.productById(widget.productId);

  String get _displayPrice {
    final base = int.tryParse(_product.price) ?? 0;
    final storageExtra = _product.storageOptions.isNotEmpty
        ? _product.storageOptions[_selectedStorage].extraPrice
        : 0;
    return ((base + storageExtra) * _quantity).toString();
  }

  @override
  Widget build(BuildContext context) {
    final title = _product.detailTitle ?? _product.name;
    final subtitle = _product.detailSubtitle ??
        '★ ${_product.rating} · ${_product.specs}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 280.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_store.gradientStart, _store.gradientEnd],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.smartphone_outlined,
                      size: 120.sp,
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 16.w,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '‹',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 16.w,
                  child: Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.more_horiz, size: 20.sp),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.titleMedium().copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                        ),
                      ),
                    ),
                    Text(
                      'BHD ${_product.price}',
                      style: AppTextStyles.titleSmall(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                ),
                if (_product.storageOptions.isNotEmpty) ...[
                  SizedBox(height: 18.h),
                  Text(
                    'STORAGE',
                    style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (var i = 0; i < _product.storageOptions.length; i++)
                        ElectronicsOptionChip(
                          label: _product.storageOptions[i].label,
                          selected: _selectedStorage == i,
                          onTap: () => setState(() => _selectedStorage = i),
                        ),
                    ],
                  ),
                ],
                if (_product.colorOptions.isNotEmpty) ...[
                  SizedBox(height: 18.h),
                  Text(
                    'COLOR',
                    style: AppTextStyles.labelSmall(color: AppColors.textSecondary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ElectronicsColorSwatches(
                    options: _product.colorOptions,
                    selectedIndex: _selectedColor,
                    onSelected: (v) => setState(() => _selectedColor = v),
                  ),
                ],
                if (_product.highlights.isNotEmpty) ...[
                  SizedBox(height: 18.h),
                  ElectronicsHighlightsCard(highlights: _product.highlights),
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
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      _qtyButton(Icons.remove, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      SizedBox(
                        width: 28.w,
                        child: Text(
                          '$_quantity',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMedium().copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      _qtyButton(Icons.add, () => setState(() => _quantity++)),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(shellProvider.notifier).openScheduledCartWithItems();
                      context.goHome(tab: 2, scheduledCart: true);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Add to cart · BHD $_displayPrice',
                        style: AppTextStyles.labelMedium(color: AppColors.white).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
      ),
    );
  }
}
