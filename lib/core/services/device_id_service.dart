import 'dart:math';

import 'package:yjeek_app/core/services/storage_service.dart';

/// Stable install-scoped device id for referral fraud gates on OTP verify.
class DeviceIdService {
  DeviceIdService(this._storage);

  final StorageService _storage;

  static const _key = 'yjeek_stable_device_id';

  Future<String> getOrCreate() async {
    final existing = _storage.readString(_key);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _generateId();
    await _storage.writeString(_key, id);
    return id;
  }

  String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'yd_$hex';
  }
}
