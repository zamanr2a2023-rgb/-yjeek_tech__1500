import 'package:flutter/material.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/features/cart/model/cart_flow_data.dart';

class DeliveryAddressSnapshot {
  const DeliveryAddressSnapshot({
    required this.id,
    required this.label,
    required this.subtitle,
    this.phone,
    this.isDefault = false,
    this.area,
    this.city,
    this.dropOffPreferences = const [],
  });

  final String id;
  final String label;
  final String subtitle;
  final String? phone;
  final bool isDefault;
  final String? area;
  final String? city;
  final List<String> dropOffPreferences;

  CartDeliveryAddress toCartAddress({bool selected = false}) {
    return CartDeliveryAddress(
      id: id,
      label: label,
      subtitle: subtitle,
      phone: phone,
      icon: CustomerAddress.iconForLabel(label),
      selected: selected,
    );
  }
}

/// Full address model for Account → Saved addresses / Add-Edit.
class CustomerAddress {
  const CustomerAddress({
    required this.id,
    required this.label,
    required this.displayLabel,
    required this.formattedLine,
    this.block,
    this.road,
    this.building,
    this.flat,
    this.area,
    this.city,
    this.phone,
    this.additionalDirections,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String id;
  final String label; // HOME | WORK | OTHER | APARTMENT
  final String displayLabel;
  final String formattedLine;
  final String? block;
  final String? road;
  final String? building;
  final String? flat;
  final String? area;
  final String? city;
  final String? phone;
  final String? additionalDirections;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  IconData get icon => iconForLabel(label);

  static IconData iconForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('home')) return Icons.home_outlined;
    if (lower.contains('work')) return Icons.work_outline;
    return Icons.location_on_outlined;
  }

  static String apiLabelFromUi(String ui) {
    return switch (ui.toLowerCase()) {
      'home' => 'HOME',
      'work' => 'WORK',
      'apartment' => 'APARTMENT',
      _ => 'OTHER',
    };
  }

  static String uiLabelFromApi(String? api) {
    return switch ((api ?? '').toUpperCase()) {
      'HOME' => 'Home',
      'WORK' => 'Work',
      'APARTMENT' => 'Other',
      'OTHER' => 'Other',
      _ => (api == null || api.isEmpty) ? 'Other' : api,
    };
  }

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final labelApi = json['label']?.toString();
    final area = (json['area'] as String?)?.trim();
    final city = (json['city'] as String?)?.trim();
    final block = (json['block'] as String?)?.trim();
    final road = (json['road'] as String?)?.trim();
    final building = (json['building'] as String?)?.trim();
    final flat = (json['flat'] as String?)?.trim();
    final line1 = (json['line1'] as String?)?.trim();

    final displayLabel = uiLabelFromApi(labelApi);

    final parts = <String>[];
    if (flat != null && flat.isNotEmpty) {
      parts.add(flat.toLowerCase().startsWith('flat') ||
              flat.toLowerCase().startsWith('apt') ||
              flat.toLowerCase().startsWith('apartment')
          ? flat
          : 'Apartment $flat');
    }
    if (building != null && building.isNotEmpty) {
      parts.add(building.toLowerCase().startsWith('bldg') ||
              building.toLowerCase().startsWith('building')
          ? building
          : 'Bldg $building');
    }
    if (road != null && road.isNotEmpty) {
      parts.add(road.toLowerCase().startsWith('road') ? road : 'Road $road');
    }
    if (area != null && area.isNotEmpty) {
      parts.add(area.contains('District') || area.contains('district')
          ? area
          : '$area District');
    } else if (city != null && city.isNotEmpty) {
      parts.add(city);
    }

    final formatted = parts.isNotEmpty
        ? parts.join(', ')
        : (line1?.isNotEmpty == true
            ? line1!
            : [block, road, building, flat, area, city]
                .whereType<String>()
                .where((s) => s.isNotEmpty)
                .join(', '));

    return CustomerAddress(
      id: id,
      label: (labelApi ?? 'OTHER').toUpperCase(),
      displayLabel: displayLabel,
      formattedLine: formatted.isEmpty ? 'Saved address' : formatted,
      block: block,
      road: road,
      building: building,
      flat: flat,
      area: area,
      city: city,
      phone: json['phone']?.toString(),
      additionalDirections:
          (json['additionalDirections'] as String?)?.trim(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] == true,
    );
  }
}

class AddressesRepository {
  const AddressesRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /addresses — cart-friendly snapshots.
  Future<List<DeliveryAddressSnapshot>> listAddresses() async {
    final all = await listCustomerAddresses();
    return all
        .map(
          (a) => DeliveryAddressSnapshot(
            id: a.id,
            label: a.area != null && a.area!.isNotEmpty
                ? '${a.displayLabel} · ${a.area}'
                : a.displayLabel,
            subtitle: a.formattedLine,
            phone: a.phone,
            isDefault: a.isDefault,
            area: a.area,
            city: a.city,
          ),
        )
        .toList();
  }

  Future<DeliveryAddressSnapshot?> defaultAddress() async {
    final all = await listAddresses();
    if (all.isEmpty) return null;
    return all.firstWhere((a) => a.isDefault, orElse: () => all.first);
  }

  /// GET /addresses — full models for account screens.
  Future<List<CustomerAddress>> listCustomerAddresses() async {
    if (!_storage.hasSession) return const [];
    final response = await _apiClient.getJson(
      '/addresses',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! List) return const [];
    final out = <CustomerAddress>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = CustomerAddress.fromJson(raw);
      if (mapped.id.isNotEmpty) out.add(mapped);
    }
    return out;
  }

  /// GET /addresses/:id
  Future<CustomerAddress?> getAddress(String id) async {
    final response = await _apiClient.getJson(
      '/addresses/$id',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    final mapped = CustomerAddress.fromJson(data);
    return mapped.id.isEmpty ? null : mapped;
  }

  /// POST /addresses
  Future<ApiResponse> createAddress(Map<String, dynamic> body) {
    return _apiClient.postJson(
      '/addresses',
      body,
      bearerToken: _token,
    );
  }

  /// PATCH /addresses/:id
  Future<ApiResponse> updateAddress(String id, Map<String, dynamic> body) {
    return _apiClient.patchJson(
      '/addresses/$id',
      body,
      bearerToken: _token,
    );
  }

  /// DELETE /addresses/:id
  Future<ApiResponse> deleteAddress(String id) {
    return _apiClient.deleteJson(
      '/addresses/$id',
      bearerToken: _token,
    );
  }

  /// PATCH /addresses/:id/default
  Future<ApiResponse> setDefaultAddress(String id) {
    return _apiClient.patchJson(
      '/addresses/$id/default',
      const {},
      bearerToken: _token,
    );
  }

  /// GET /addresses/check-range?vendorId=&addressId=
  Future<bool> checkInRange({
    required String vendorId,
    required String addressId,
  }) async {
    final response = await _apiClient.getJson(
      '/addresses/check-range?vendorId=${Uri.encodeQueryComponent(vendorId)}'
      '&addressId=${Uri.encodeQueryComponent(addressId)}',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is Map<String, dynamic>) {
      return data['inRange'] == true ||
          data['deliverable'] == true ||
          data['withinRange'] == true;
    }
    // If API fails open, allow delivery (backend may omit flag).
    return response?['success'] == true;
  }
}
