import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/features/cart/model/zood_promo.dart';

final zoodPromoProvider = FutureProvider.autoDispose<ZoodPromo?>((ref) async {
  return ref.read(zoodRepositoryProvider).fetchPromo();
});
