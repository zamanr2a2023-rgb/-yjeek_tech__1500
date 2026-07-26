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
      icon: _iconForLabel(label),
      selected: selected,
    );
  }

  static IconData _iconForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('home')) return Icons.home_outlined;
    if (lower.contains('work')) return Icons.work_outline;
    return Icons.apartment_outlined;
  }
}

class AddressesRepository {
  const AddressesRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final StorageService _storage;

  String? get _token => _storage.token;

  /// GET /addresses
  Future<List<DeliveryAddressSnapshot>> listAddresses() async {
    if (!_storage.hasSession) return const [];
    final response = await _apiClient.getJson(
      '/addresses',
      bearerToken: _token,
    );
    final data = response?['data'];
    if (data is! List) return const [];
    final out = <DeliveryAddressSnapshot>[];
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final mapped = _fromJson(raw);
      if (mapped != null) out.add(mapped);
    }
    return out;
  }

  Future<DeliveryAddressSnapshot?> defaultAddress() async {
    final all = await listAddresses();
    if (all.isEmpty) return null;
    return all.firstWhere((a) => a.isDefault, orElse: () => all.first);
  }

  static DeliveryAddressSnapshot? _fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) return null;
    final labelRaw = (json['label'] as String?)?.trim();
    final area = (json['area'] as String?)?.trim();
    final city = (json['city'] as String?)?.trim();
    final label = (labelRaw != null && labelRaw.isNotEmpty)
        ? (area != null && area.isNotEmpty ? '$labelRaw · $area' : labelRaw)
        : (area != null && area.isNotEmpty
            ? area
            : (city ?? 'Saved address'));
    final line1 = (json['line1'] as String?)?.trim();
    final building = (json['building'] as String?)?.trim();
    final flat = (json['flat'] as String?)?.trim();
    final road = (json['road'] as String?)?.trim();
    final subtitleParts = <String>[
      if (line1 != null && line1.isNotEmpty) line1,
      if (line1 == null || line1.isEmpty) ...[
        if (road != null && road.isNotEmpty) 'Road $road',
        if (building != null && building.isNotEmpty) 'Bldg $building',
        if (flat != null && flat.isNotEmpty) 'Flat $flat',
      ],
    ];
    final prefsRaw = json['dropOffPreferences'];
    final prefs = <String>[];
    if (prefsRaw is List) {
      for (final p in prefsRaw) {
        final s = p?.toString();
        if (s != null && s.isNotEmpty) prefs.add(s);
      }
    }
    return DeliveryAddressSnapshot(
      id: id,
      label: label,
      subtitle: subtitleParts.isEmpty ? (city ?? '') : subtitleParts.join(', '),
      phone: json['phone']?.toString(),
      isDefault: json['isDefault'] == true,
      area: area,
      city: city,
      dropOffPreferences: prefs,
    );
  }
}
