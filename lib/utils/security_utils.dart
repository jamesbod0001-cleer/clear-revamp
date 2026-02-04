import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

class PaymentSecurityUtils {
  /// Generates a random 12-character alphanumeric nonce
  static String generateNonce() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// AES-256-GCM Encryption for Flutterwave v4
  static Future<String> encryptAESGCM(String plainText, String encryptionKey, String nonce) async {
    final algorithm = AesGcm.with256bits();

    // 1. Decode the Secret Key (Flutterwave sends it as Base64)
    final keyBytes = base64Decode(encryptionKey);
    final secretKey = await algorithm.newSecretKeyFromBytes(keyBytes);

    // 2. Prepare the Nonce (IV)
    final nonceBytes = utf8.encode(nonce);

    // 3. Encrypt
    final secretBox = await algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonceBytes,
    );

    // 4. Return the ciphertext as Base64 (Standard Flutterwave requirement)
    // Note: secretBox.cipherText contains the data, secretBox.mac contains the tag.
    // Flutterwave usually expects the combined output or just ciphertext depending on the SDK.
    // Based on their JS example: return btoa(ciphertext)
    return base64Encode(secretBox.cipherText);
  }
}