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

  // --- Flutterwave OAuth Methods ---
  Future<void> saveFlutterwaveToken(String token) async {
    await _storage.write(key: _flwTokenKey, value: token);
  }

  Future<String?> getFlutterwaveToken() async => await _storage.read(key: _flwTokenKey);

  Future<void> clearFlutterwaveToken() async => await _storage.delete(key: _flwTokenKey);

  // --- Temporary Password Methods (Moved from AuthUseCase) ---
  Future<void> saveTempPassword(String phoneNumber, String password) async {
    await _storage.write(key: "$_tempPassPrefix$phoneNumber", value: password);
  }

  Future<String?> getTempPassword(String phoneNumber) async {
    return await _storage.read(key: "$_tempPassPrefix$phoneNumber");
  }

  Future<void> deleteTempPassword(String phoneNumber) async {
    await _storage.delete(key: "$_tempPassPrefix$phoneNumber");
  }
}