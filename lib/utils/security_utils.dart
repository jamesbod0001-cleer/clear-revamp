import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class PaymentSecurityUtils {
  /// Generates a random 12-character alphanumeric nonce
  static String generateNonce() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
      12,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// AES-256-GCM Encryption for Flutterwave v4
  static Future<String> encryptAESGCM(String plainText, String encryptionKey, String nonce) async {
    final algorithm = AesGcm.with256bits();

    // FIX: Verify if your key is Base64 or raw String
    // Try utf8.encode if base64Decode is producing the wrong length
    final Uint8List keyBytes = encryptionKey.length == 32
        ? utf8.encode(encryptionKey)
        : base64Decode(encryptionKey);

    if (keyBytes.length != 32) {
      throw Exception("Encryption key must be exactly 32 bytes. Current: ${keyBytes.length}");
    }

    final secretKey = await algorithm.newSecretKeyFromBytes(keyBytes);
    final nonceBytes = utf8.encode(nonce);

    final secretBox = await algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonceBytes,
    );

    // COMBINE: Ciphertext + MAC (Tag)
    // This mimics the 'encryptedData' result from Node.js/WebCrypto
    final combined = Uint8List.fromList([
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return base64Encode(combined);
  }
}
