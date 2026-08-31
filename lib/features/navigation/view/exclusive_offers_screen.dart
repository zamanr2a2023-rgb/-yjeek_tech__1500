import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/providers/shell_provider.dart';
import 'package:yjeek_app/features/cart/model/cart_repository.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';
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
  List<BrowseOffer> _offers = [];
  bool _loading = true;
  String? _error;
  String? _addingProductId;

  List<String> get _filters => [
        NavigationStrings.filterAll,
        NavigationStrings.filterFood,
        NavigationStrings.filterGroceries,
        NavigationStrings.filterFashion,
      ];

  /// Maps UI chips → GET /offers?category= slug.
  static const _categorySlugs = <String?>[
    null,
    'food',
    'groceries',
    'fashion',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final slug = _categorySlugs[_filterIndex];
      final offers = await ref
          .read(offersRepositoryProvider)
          .fetchOffers(categorySlug: slug);
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _offers = const [];
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onFilterChanged(int index) async {
    if (index == _filterIndex) return;
    setState(() => _filterIndex = index);
    await _load();
  }

  Future<void> _addOffer(BrowseOffer offer) async {
    final productId = offer.productId;
    if (productId == null || productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This offer has no product to add')),
      );
      return;
    }
    if (_addingProductId != null) return;
    setState(() => _addingProductId = productId);
    try {
      final repo = ref.read(cartRepositoryProvider);
      final useScheduled = offer.category == OfferCategory.groceries ||
          offer.category == OfferCategory.fashion;
      if (useScheduled) {
        Future<void> addScheduled({bool replaceCart = false}) async {
          final snap = await repo.addScheduledProduct(
            productId: productId,
            replaceCart: replaceCart,
          );
          if (!mounted) return;
          if (snap == null || !snap.hasItems) {
            throw Exception('Could not add to cart');
          }
          ref.read(shellProvider.notifier).openScheduledCartWithItems();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${offer.name} added to cart'),
              duration: const Duration(seconds: 1),
            ),
          );
          context.goHome(tab: 2, scheduledCart: true);
        }

        try {
          await addScheduled();
        } on ScheduledVendorLimitException {
          if (!mounted) return;
          showCartNewCartDialog(
            context,
            onConfirm: () => addScheduled(replaceCart: true),
          );
        }
        return;
      }

      await repo.addProduct(
        type: CartOrderType.delivery,
        productId: productId,
      );
      if (!mounted) return;
      ref.read(shellProvider.notifier).markCartDirty();
      ref.read(shellProvider.notifier).openCartWithItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${offer.name} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
      context.goHome(tab: 2, cartHasItems: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _addingProductId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavBackHeader(
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
              onChanged: _loading ? (_) {} : _onFilterChanged,
            ),
          ),
          Expanded(child: _buildBody()),
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

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null && _offers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B756E)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_offers.isEmpty) {
      return const Center(
        child: Text(
          'No offers in this category yet',
          style: TextStyle(color: Color(0xFF6B756E)),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: _offers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final offer = _offers[index];
          final busy = _addingProductId == offer.productId;
          return ExclusiveOfferListCard(
            offer: offer,
            onAdd: busy ? null : () => _addOffer(offer),
          );
        },
      ),
    );
  }
}
