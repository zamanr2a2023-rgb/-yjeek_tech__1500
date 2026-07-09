import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/features/home/view/widgets/home_widgets.dart';
import 'package:yjeek_app/features/navigation/model/navigation_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/routes/app_router.dart';

class ExclusiveOffersScreen extends ConsumerStatefulWidget {
  const ExclusiveOffersScreen({super.key});

  @override
  ConsumerState<ExclusiveOffersScreen> createState() =>
      _ExclusiveOffersScreenState();
}

class _ExclusiveOffersScreenState extends ConsumerState<ExclusiveOffersScreen> {
  int _filterIndex = 0;

  static const _filters = [
    NavigationStrings.filterAll,
    NavigationStrings.filterFood,
    NavigationStrings.filterGroceries,
    NavigationStrings.filterFashion,
  ];

  List<BrowseOffer> get _filteredOffers {
    if (_filterIndex == 0) return NavigationData.browseOffers;
    final category = OfferCategory.values[_filterIndex];
    return NavigationData.browseOffers
        .where((offer) => offer.category == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NavBackHeader(
            title: NavigationStrings.exclusiveOffersTitle,
            subtitle: NavigationStrings.exclusiveOffersSubtitle,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            child: HorizontalFilterChips(
              labels: _filters,
              selectedIndex: _filterIndex,
              style: FilterChipStyle.offers,
              spacing: 10,
              onChanged: (index) => setState(() => _filterIndex = index),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: _filteredOffers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return ExclusiveOfferListCard(
                  offer: _filteredOffers[index],
                  onAdd: () {
                    ref.read(shellProvider.notifier).addToCart();
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            context.pop();
            return;
          }
          context.goHome(tab: index);
        },
      ),
    );
  }
}
