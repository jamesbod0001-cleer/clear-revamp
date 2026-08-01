import 'package:cleer_core/cleer_core.dart';
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'FLUTTERWAVE_ENCRYPTION_KEY_SANDBOX')
  static final String _flutterwaveEncryptionKeySandbox = _Env._flutterwaveEncryptionKeySandbox;

  @EnviedField(varName: 'FLUTTERWAVE_ENCRYPTION_KEY_LIVE')
  static final String _flutterwaveEncryptionKeyLive = _Env._flutterwaveEncryptionKeyLive;

  static String get flutterwaveEncryptionKey {
    return AppConfig.isLive
        ? _flutterwaveEncryptionKeyLive
        : _flutterwaveEncryptionKeySandbox;
  }
}
