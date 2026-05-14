import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'FLUTTERWAVE_IS_LIVE')
  static final bool flutterwaveIsLive = _Env.flutterwaveIsLive;

  @EnviedField(varName: 'FLUTTERWAVE_CLIENT_ID')
  static final String flutterwaveClientId = _Env.flutterwaveClientId;

  @EnviedField(varName: 'FLUTTERWAVE_CLIENT_SECRET')
  static final String flutterwaveClientSecret = _Env.flutterwaveClientSecret;

  @EnviedField(varName: 'FLUTTERWAVE_ENCRYPTION_KEY')
  static final String flutterwaveEncryptionKey = _Env.flutterwaveEncryptionKey;

  @EnviedField(varName: 'FLUTTERWAVE_PUBLIC_KEY')
  static final String flutterwavePublicKey = _Env.flutterwavePublicKey;

  @EnviedField(varName: 'FLUTTERWAVE_SECRET_KEY')
  static final String flutterwaveSecretKey = _Env.flutterwaveSecretKey;
}
