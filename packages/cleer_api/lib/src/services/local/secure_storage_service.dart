import 'dart:convert';

import 'package:cleer_core/cleer_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService(const FlutterSecureStorage());
}

class SecureStorageService {
  final FlutterSecureStorage _storage;
  SecureStorageService(this._storage);

  // Constants for Key Management
  static const String _flwTokenKey = "FLW_ACCESS_TOKEN";
  static const String _tempPassPrefix = "TEMP_PASS_";
  static const String _hiddenUsernamePrefix = "HIDDEN_USER_";
  static const String _lastNudgeKey = "LAST_NOTIFICATION_NUDGE_TIME";
  static const String _passportKey = "USER_PASSPORT";

  // --- Passport Methods ---
  Future<void> savePassport(AuthIdentity identity) async {
    final jsonString = jsonEncode(identity.toJson());
    await _storage.write(key: _passportKey, value: jsonString);
  }

  Future<AuthIdentity?> getCachedPassport() async {
    final jsonString = await _storage.read(key: _passportKey);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return AuthIdentity.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearPassport() async {
    await _storage.delete(key: _passportKey);
  }

  // --- Flutterwave OAuth Methods ---
  Future<void> saveFlutterwaveToken(String token) async {
    await _storage.write(key: _flwTokenKey, value: token);
  }

  Future<String?> getFlutterwaveToken() async =>
      await _storage.read(key: _flwTokenKey);

  Future<void> clearFlutterwaveToken() async =>
      await _storage.delete(key: _flwTokenKey);

  // --- Temporary Password Methods ---
  Future<void> saveTempPassword(String phoneNumber, String password) async {
    await _storage.write(key: "$_tempPassPrefix$phoneNumber", value: password);
  }

  Future<String?> getTempPassword(String phoneNumber) async {
    return await _storage.read(key: "$_tempPassPrefix$phoneNumber");
  }

  Future<void> deleteTempPassword(String phoneNumber) async {
    await _storage.delete(key: "$_tempPassPrefix$phoneNumber");
  }

  // --- Hidden Username (UUID) Methods ---
  Future<void> saveHiddenUsername(String phoneNumber, String username) async {
    await _storage.write(
      key: "$_hiddenUsernamePrefix$phoneNumber",
      value: username,
    );
  }

  Future<String?> getHiddenUsername(String phoneNumber) async {
    return await _storage.read(key: "$_hiddenUsernamePrefix$phoneNumber");
  }

  Future<void> deleteHiddenUsername(String phoneNumber) async {
    await _storage.delete(key: "$_hiddenUsernamePrefix$phoneNumber");
  }

  // --- Notification Nudge Methods ---
  Future<void> saveLastNotificationNudgeTime(DateTime time) async {
    await _storage.write(key: _lastNudgeKey, value: time.toIso8601String());
  }

  Future<DateTime?> getLastNotificationNudgeTime() async {
    final value = await _storage.read(key: _lastNudgeKey);
    return value != null ? DateTime.tryParse(value) : null;
  }
}
