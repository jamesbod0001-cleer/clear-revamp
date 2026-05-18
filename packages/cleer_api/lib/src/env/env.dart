import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'FLUTTERWAVE_ENCRYPTION_KEY')
  static final String flutterwaveEncryptionKey = _Env.flutterwaveEncryptionKey;
}
