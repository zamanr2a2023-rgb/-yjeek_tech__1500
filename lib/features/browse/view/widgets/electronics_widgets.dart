import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/model/electronics_data.dart';

const Color _kGreen = Color(0xFF2E9E4D);
const Color _kMuted = Color(0xFF6B756E);
const Color _kText = Color(0xFF1A1A1A);
const Color _kBorder = Color(0xFFE0E6E0);
const Color _kTile = Color(0xFFDBE8DE);
const Color _kStar = Color(0xFFD98C1A);
const Color _kMint = Color(0xFFE3F2EB);
const Color _kDeepGreen = Color(0xFF127036);

class ElectronicsToolbar extends StatelessWidget {
  const ElectronicsToolbar({
    super.key,
    required this.isGridView,
    required this.onViewChanged,
    this.freeDeliveryOnly = false,
    this.onFreeDeliveryChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final bool freeDeliveryOnly;
  final ValueChanged<bool>? onFreeDeliveryChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('⇅ Sort'),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => onFreeDeliveryChanged?.call(!freeDeliveryOnly),
          child: _chip(
            'Free delivery',
            selected: freeDeliveryOnly,
          ),
        ),
        const Spacer(),
        Container(
          width: 72.w,
          height: 34.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _kBorder, width: 1.2),
          ),
          child: Row(
            children: [
              _viewSeg(
                label: '≡',
                active: !isGridView,
                onTap: () => onViewChanged(false),
              ),
              _viewSeg(
                label: '▦',
                active: isGridView,
                onTap: () => onViewChanged(true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, {bool selected = false}) {
    return Container(
      height: 29.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F5E9) : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: selected ? _kGreen : _kBorder,
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: selected ? _kGreen : _kText,
          fontWeight: FontWeight.w600,
          fontSize: 12.5.sp,
          height: 15 / 12.5,
        ),
      ),
    );
  }

  Widget _viewSeg({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34.h,
          decoration: BoxDecoration(
            color: active ? _kGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active ? AppColors.white : _kMuted,
              fontWeight: FontWeight.w700,
              fontSize: active ? 18.sp : 15.sp,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class ElectronicsStoreListCard extends StatelessWidget {
  const ElectronicsStoreListCard({
    super.key,
    required this.store,
    this.onTap,
  });

  final ElectronicsStore store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: _kTile,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                '🏪',
                style: TextStyle(fontSize: 24.sp, height: 1),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: _kText,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      height: 18 / 15,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '★ ${store.rating}',
                          style: GoogleFonts.inter(
                            color: _kStar,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5.sp,
                            height: 15 / 12.5,
                          ),
                        ),
                        TextSpan(
                          text: ' (${store.reviewCount}) · ${store.distance}',
                          style: GoogleFonts.inter(
                            color: _kMuted,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            height: 15 / 12,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    store.categories,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: _kMuted,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 15 / 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, size: 20.sp, color: _kMuted),
          ],
        ),
      ),
    );
  }
}

class ElectronicsStoreGridCard extends StatelessWidget {
  const ElectronicsStoreGridCard({
    super.key,
    required this.store,
    this.onTap,
  });

  final ElectronicsStore store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 72.h,
              decoration: BoxDecoration(
                color: _kTile,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text('🏪', style: TextStyle(fontSize: 28.sp, height: 1)),
            ),
            SizedBox(height: 10.h),
            Text(
              store.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _kText,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                height: 17 / 14,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '★ ${store.rating} · ${store.distance}',
              style: GoogleFonts.inter(
                color: _kStar,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              store.categories,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _kMuted,
                fontWeight: FontWeight.w400,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElectronicsStoreTopBar extends StatelessWidget {
  const ElectronicsStoreTopBar({
    super.key,
    required this.store,
    this.onBack,
  });

  final ElectronicsStore store;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // Figma hd: padding 4/20/8, gap 12, back + title/subtitle, trailing ⋯.
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  '‹',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                    height: 24 / 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    store.name,
                    style: GoogleFonts.inter(
                      color: _kText,
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                      height: 24 / 20,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${store.productCount} products',
                    style: GoogleFonts.inter(
                      color: _kMuted,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 15 / 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElectronicsProductRow extends StatelessWidget {
  const ElectronicsProductRow({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
  });

  final ElectronicsProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 12.w, 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color: _kTile,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Text(
                product.id.contains('buds') ||
                        product.id.contains('sound')
                    ? '🎧'
                    : product.id.contains('band')
                        ? '⌚'
                        : '📱',
                style: TextStyle(fontSize: 24.sp, height: 1),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      color: _kText,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      height: 18 / 15,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.specs,
                    style: GoogleFonts.inter(
                      color: _kMuted,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 15 / 12,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '★ ${product.rating}',
                    style: GoogleFonts.inter(
                      color: _kStar,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      height: 15 / 12,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        'BHD ${product.price}',
                        style: GoogleFonts.inter(
                          color: _kText,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          height: 18 / 15,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        SizedBox(width: 6.w),
                        Text(
                          'BHD ${product.originalPrice}',
                          style: GoogleFonts.inter(
                            color: _kMuted,
                            fontWeight: FontWeight.w400,
                            fontSize: 11.sp,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: _kMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onAdd ?? onTap,
              // Figma: mint circle #E3F2EB, dark green + #127036
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: _kMint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+',
                  style: GoogleFonts.inter(
                    color: _kDeepGreen,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 19 / 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElectronicsOptionChip extends StatelessWidget {
  const ElectronicsOptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Intrinsic width only — do not expand to full row width.
    return GestureDetector(
      onTap: onTap,
      child: UnconstrainedBox(
        child: Container(
          height: 29.h,
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          decoration: BoxDecoration(
            color: selected ? _kGreen : AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: selected ? _kGreen : _kBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: selected ? AppColors.white : _kText,
              fontWeight: FontWeight.w600,
              fontSize: 12.5.sp,
              height: 15 / 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class ElectronicsColorSwatches extends StatelessWidget {
  const ElectronicsColorSwatches({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ElectronicsColorOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: 10.w),
          GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: options[i].color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedIndex == i ? _kGreen : _kBorder,
                  width: selectedIndex == i ? 2 : 1.2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ElectronicsHighlightsCard extends StatelessWidget {
  const ElectronicsHighlightsCard({
    super.key,
    required this.highlights,
  });

  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Highlights',
          style: GoogleFonts.inter(
            color: _kText,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            height: 18 / 15,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < highlights.length; i++) ...[
                if (i > 0) SizedBox(height: 10.h),
                Text(
                  '• ${highlights[i]}',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    color: _kText,
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    height: 16 / 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ElectronicsFilterChips extends StatelessWidget {
  const ElectronicsFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final option = options[index];
          final active = option == selected;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              height: 29.h,
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? _kGreen : AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: active ? _kGreen : _kBorder),
              ),
              child: Text(
                option,
                style: GoogleFonts.inter(
                  color: active ? AppColors.white : _kText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5.sp,
                  height: 15 / 12.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Exposed tokens for product detail screen.
abstract final class ElectronicsTokens {
  static const green = _kGreen;
  static const muted = _kMuted;
  static const text = _kText;
  static const border = _kBorder;
  static const mint = _kMint;
  static const deepGreen = _kDeepGreen;
}
