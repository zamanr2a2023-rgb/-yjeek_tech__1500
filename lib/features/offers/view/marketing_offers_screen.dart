import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';
import 'package:yjeek_app/features/browse/browse_routes.dart';
import 'package:yjeek_app/features/location/provider/delivery_location_provider.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/offers/model/marketing_offer_models.dart';
import 'package:yjeek_app/routes/route_names.dart';

class MarketingOffersScreen extends ConsumerStatefulWidget {
  const MarketingOffersScreen({super.key});

  @override
  ConsumerState<MarketingOffersScreen> createState() =>
      _MarketingOffersScreenState();
}

class _MarketingOffersScreenState extends ConsumerState<MarketingOffersScreen> {
  final _items = <MarketingOfferItem>[];
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;
  bool _recordedOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _items.clear();
    });
    await _fetch(page: 1, recordOpened: !_recordedOpen);
    if (mounted && !_recordedOpen) _recordedOpen = true;
  }

  Future<void> _fetch({required int page, bool recordOpened = false}) async {
    final loc = ref.read(deliveryLocationProvider).valueOrNull;
    try {
      final result = await ref.read(marketingOffersRepositoryProvider).fetchItems(
            page: page,
            latitude: loc?.latitude,
            longitude: loc?.longitude,
            withinDeliveryRadius: true,
            recordOpened: recordOpened,
          );
      if (!mounted) return;
      setState(() {
        if (page == 1) {
          _items
            ..clear()
            ..addAll(result.items);
        } else {
          _items.addAll(result.items);
        }
        _page = result.page;
        _hasMore = result.hasMore;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = 'Could not load offers';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    await _fetch(page: _page + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const NavBackHeader(
            title: 'Offers',
            backIconColor: AppColors.textPrimary,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadInitial,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ],
      );
    }
    if (_error != null && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(24.w),
        children: [
          Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: _loadInitial, child: const Text('Retry')),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(24.w),
        children: [
          Text(
            'No offers in your area right now',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return TextButton(
            onPressed: _loadMore,
            child: _loadingMore
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Load more'),
          );
        }
        return _OfferCard(
          item: _items[index],
          onTap: () => context.push(
            BrowseRoutes.vendorMenu(
              vendorId: _items[index].vendorId,
              returnTo: RouteNames.marketingOffers,
            ),
          ),
        );
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.item, required this.onTap});

  final MarketingOfferItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = item.onPromotion ? item.discountedPrice : item.price;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 72.w,
                  height: 72.w,
                  child: AppNetworkImage(
                    url: item.imageUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.onPromotion)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.offerBadgeGreenBg,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Offer',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.offerBadgeGreenText,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    SizedBox(height: 4.h),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (item.vendorName != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        item.vendorName!,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          'BHD ${price.toStringAsFixed(3)}',
                          style: AppTextStyles.labelMedium(
                            color: AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (item.showStrike) ...[
                          SizedBox(width: 8.w),
                          Text(
                            'BHD ${item.originalPrice.toStringAsFixed(3)}',
                            style: AppTextStyles.labelSmall(
                              color: AppColors.textSecondary,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
