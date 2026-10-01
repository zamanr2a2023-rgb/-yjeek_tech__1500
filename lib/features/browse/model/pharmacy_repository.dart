import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/browse/model/pharmacy_order_modes.dart';
import 'package:yjeek_app/features/catalog/model/catalog_cart_payload.dart';

class PharmacyRepository {
  const PharmacyRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /vendors/:id/order-modes?latitude=&longitude=
  Future<PharmacyOrderModes> fetchOrderModes({
    required String vendorId,
    double? latitude,
    double? longitude,
  }) async {
    final params = <String, String>{};
    if (latitude != null) params['latitude'] = latitude.toString();
    if (longitude != null) params['longitude'] = longitude.toString();
    final qs = params.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
    final path = qs.isEmpty
        ? '/vendors/$vendorId/order-modes'
        : '/vendors/$vendorId/order-modes?$qs';
    final response = await _apiClient.getJson(path, bearerToken: _token);
    final data = response?['data'];
    if (data is Map<String, dynamic>) {
      return PharmacyOrderModes.fromJson(data);
    }
    throw StateError('Pharmacy order modes unavailable');
  }

  /// Deliver Now lines go on the delivery cart. Scheduled lines stay on
  /// `POST /cart/scheduled/items`.
  Future<({bool ok, bool vendorConflict, String? message})> addDeliverNow({
    required String productId,
    required int quantity,
    List<String> optionIds = const [],
    List<String> addonIds = const [],
    bool replaceCart = false,
    String? variantId,
  }) async {
    final response = await _apiClient.postJson(
      '/cart/items',
      catalogCartItemBody(
        productId: productId,
        quantity: quantity,
        replaceCart: replaceCart,
        variantId: variantId,
        optionIds: optionIds,
        addonIds: addonIds,
      ),
      bearerToken: _token,
    );
    if (response.ok) return (ok: true, vendorConflict: false, message: null);

    final error = response.json?['error'];
    final details = error is Map ? error['details'] : null;
    final detailCode = details is Map ? details['code']?.toString() : null;
    final code = error is Map ? error['code']?.toString() : null;
    final message = response.message ?? 'Could not add to cart';
    final conflict =
        response.statusCode == 409 ||
        code == 'VENDOR_CART_CONFLICT' ||
        detailCode == 'VENDOR_CART_CONFLICT' ||
        code == 'CONFLICT';
    return (ok: false, vendorConflict: conflict, message: message);
  }
}

final pharmacyRepositoryProvider = Provider<PharmacyRepository>(
  (ref) => PharmacyRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  ),
);
