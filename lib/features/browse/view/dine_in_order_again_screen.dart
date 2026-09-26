import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/browse_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/browse/model/dine_in_data.dart';
import 'package:yjeek_app/features/browse/view/widgets/browse_widgets.dart';
import 'package:yjeek_app/features/browse/view/widgets/dine_in_widgets.dart';
import 'package:yjeek_app/features/home/model/home_ui_mapper.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

class DineInOrderAgainScreen extends ConsumerStatefulWidget {
  const DineInOrderAgainScreen({super.key, this.bottomNavIndex = 0});

  final int bottomNavIndex;

  @override
  ConsumerState<DineInOrderAgainScreen> createState() =>
      _DineInOrderAgainScreenState();
}

class _LoadedVisit {
  const _LoadedVisit({required this.visit, this.visitedAt});

  final DineInVisit visit;
  final DateTime? visitedAt;
}

class _DineInOrderAgainScreenState extends ConsumerState<DineInOrderAgainScreen> {
  String _selectedFilter = DineInData.orderAgainFilters.first;
  List<_LoadedVisit> _visits = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final orders = await ref.read(ordersRepositoryProvider).listOrders(
            category: OrderCategoryFilter.dineIn,
          );
      final visits = <_LoadedVisit>[];
      for (final summary in orders) {
        var restaurantId = summary.vendorId;
        var restaurantName = summary.vendor;
        var itemsSummary = summary.subtitle;
        var total = summary.price.replaceFirst('BHD ', '');
        var visitedAt = summary.createdAt;

        final order =
            await ref.read(ordersRepositoryProvider).getOrder(summary.id);

        if (order != null) {
          final vendor = order['vendor'];
          if (vendor is Map) {
            if (restaurantId == null || restaurantId.isEmpty) {
              restaurantId = vendor['id']?.toString();
            }
            restaurantName =
                vendor['name']?.toString() ?? summary.vendor;
          }

          final items = order['items'];
          if (items is List && items.isNotEmpty) {
            final names = <String>[];
            for (final row in items) {
              if (row is Map) {
                final name = row['name']?.toString();
                if (name != null && name.isNotEmpty) names.add(name);
              }
            }
            if (names.isNotEmpty) {
              itemsSummary = names.take(2).join(', ');
              if (names.length > 2) itemsSummary = '$itemsSummary…';
            }
          }

          final totalRaw = order['totalAmount'];
          total = totalRaw is num
              ? totalRaw.toStringAsFixed(3)
              : summary.price.replaceFirst('BHD ', '');

          visitedAt ??=
              DateTime.tryParse(order['createdAt']?.toString() ?? '');
        }

        if (restaurantId == null || restaurantId.isEmpty) continue;

        final when = _formatVisitMeta(visitedAt);
        final base = HomeBrandStyle.forName(restaurantName);

        visits.add(
          _LoadedVisit(
            visitedAt: visitedAt,
            visit: DineInVisit(
              restaurantId: restaurantId,
              restaurantName: restaurantName,
              itemsSummary: itemsSummary,
              visitMeta: when,
              total: total,
              gradientStart: base,
              gradientEnd: const Color(0xFF15302B),
            ),
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _visits = visits;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _visits = const [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not load dine-in visits'),
          action: SnackBarAction(label: 'Retry', onPressed: _load),
        ),
      );
    }
  }

  static String _formatVisitMeta(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = local.day.toString().padLeft(2, '0');
    final month = months[local.month - 1];
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$day $month ${local.year} · $hh:$mm';
  }

  bool _matchesMealFilter(DateTime? at, String filter) {
    if (at == null) return filter == 'All';
    final hour = at.toLocal().hour;
    return switch (filter) {
      'Lunch' => hour >= 11 && hour < 16,
      'Dinner' => hour >= 16 && hour < 23,
      'Cafes' => hour >= 5 && hour < 11,
      _ => true,
    };
  }

  List<DineInVisit> get _filteredVisits {
    if (_selectedFilter == 'All') {
      return _visits.map((v) => v.visit).toList();
    }
    return _visits
        .where((v) => _matchesMealFilter(v.visitedAt, _selectedFilter))
        .map((v) => v.visit)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrowseTopBar(title: BrowseStrings.orderAgain),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
            child: Text(
              BrowseStrings.recentDineInVisits,
              style: AppTextStyles.bodySmall(color: AppColors.textSecondary)
                  .copyWith(
                fontSize: 13.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: BrowseFilterChips(
              options: DineInData.orderAgainFilters,
              selected: _selectedFilter,
              onSelected: (v) => setState(() => _selectedFilter = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _filteredVisits.isEmpty
                    ? Center(
                        child: Text(
                          'No dine-in visits yet',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                        itemCount: _filteredVisits.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final visit = _filteredVisits[index];
                          return DineInVisitCard(
                            visit: visit,
                            onBookAgain: () => context.push(
                              BrowseRoutes.dineInMenu(
                                restaurantId: visit.restaurantId,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar:
          ShellBottomNavBar(currentIndex: widget.bottomNavIndex),
    );
  }
}
