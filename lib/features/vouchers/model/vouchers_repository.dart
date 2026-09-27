import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/vouchers/model/voucher_models.dart';

class VouchersRepository {
  const VouchersRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /customer/vouchers?status=active|used|expired
  Future<List<CustomerVoucher>> fetchVouchers({required String status}) async {
    final response = await _apiClient.getJson(
      '/customer/vouchers?status=${Uri.encodeQueryComponent(status)}',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const [];
    final items = data['items'];
    if (items is! List) return const [];
    final out = <CustomerVoucher>[];
    for (final raw in items) {
      if (raw is Map<String, dynamic>) {
        out.add(CustomerVoucher.fromJson(raw));
      }
    }
    return out;
  }

  /// POST /customer/checkout/vouchers/evaluate
  Future<CheckoutVoucherEvaluation> evaluate({
    String? cartId,
    String? orderType,
  }) async {
    final body = <String, dynamic>{
      if (cartId != null && cartId.isNotEmpty) 'cartId': cartId,
      if (orderType != null && orderType.isNotEmpty) 'orderType': orderType,
    };
    final response = await _apiClient.postJson(
      '/customer/checkout/vouchers/evaluate',
      body,
      bearerToken: _token,
    );
    if (!response.ok) {
      throw Exception(response.message ?? 'Could not evaluate vouchers');
    }
    final data = response.data;
    if (data == null) return CheckoutVoucherEvaluation.empty;
    return CheckoutVoucherEvaluation.fromJson(data);
  }
}
