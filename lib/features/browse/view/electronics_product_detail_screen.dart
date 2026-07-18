import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
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

class _ElectronicsProductDetailScreenState
    extends ConsumerState<ElectronicsProductDetailScreen> {
  int _quantity = 1;
  int _selectedStorage = 0;
  int _selectedColor = 0;

  ElectronicsProduct get _product => ElectronicsData.productById(widget.productId);

  int get _unitPrice {
    final base = int.tryParse(_product.price) ?? 0;
    final storageExtra = _product.storageOptions.isNotEmpty
        ? _product.storageOptions[_selectedStorage].extraPrice
        : 0;
    return base + storageExtra;
  }

  String get _displayPrice => (_unitPrice * _quantity).toString();

  @override
  Widget build(BuildContext context) {
    final title = _product.detailTitle ?? _product.name;
    final subtitle = _product.detailSubtitle ??
        '★ ${_product.rating} · ${_product.specs}';
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F2),
      body: Column(
        children: [
          SizedBox(
            height: top + 260.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: ElectronicsTokens.mint),
                Positioned(
                  top: top + 12.h,
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
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: ElectronicsTokens.text,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '📱',
                    style: TextStyle(
                      fontSize: 64.sp,
                      height: 1,
                      color: ElectronicsTokens.deepGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.inter(
                          color: ElectronicsTokens.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                          height: 27 / 22,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'BHD $_unitPrice',
                      style: GoogleFonts.inter(
                        color: ElectronicsTokens.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        height: 22 / 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    color: ElectronicsTokens.muted,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                    height: 16 / 13,
                  ),
                ),
                if (_product.storageOptions.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Text(
                    'STORAGE',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      color: ElectronicsTokens.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      height: 15 / 12,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Figma: single horizontal row of storage pills.
                  Row(
                    children: [
                      for (var i = 0; i < _product.storageOptions.length; i++) ...[
                        if (i > 0) SizedBox(width: 8.w),
                        ElectronicsOptionChip(
                          label: _product.storageOptions[i].label,
                          selected: _selectedStorage == i,
                          onTap: () => setState(() => _selectedStorage = i),
                        ),
                      ],
                    ],
                  ),
                ],
                if (_product.colorOptions.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Text(
                    'COLOR',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      color: ElectronicsTokens.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      height: 15 / 12,
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
                  SizedBox(height: 14.h),
                  ElectronicsHighlightsCard(highlights: _product.highlights),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: ElectronicsTokens.border)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 55.h,
                child: Row(
                  children: [
                    Container(
                      width: 92.w,
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F7F2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: ElectronicsTokens.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                              child: Text(
                                '−',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: ElectronicsTokens.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22.sp,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '$_quantity',
                            style: GoogleFonts.inter(
                              color: ElectronicsTokens.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Text(
                                '+',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: ElectronicsTokens.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22.sp,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 55.h,
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(shellProvider.notifier)
                                .openScheduledCartWithItems();
                            context.goHome(tab: 2, scheduledCart: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElectronicsTokens.green,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Add to cart · BHD $_displayPrice',
                            style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              height: 19 / 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
