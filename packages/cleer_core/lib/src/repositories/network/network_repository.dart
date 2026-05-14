import 'package:cleer_core/cleer_core.dart';

abstract class NetworkRepository {
  Stream<AppConnectionStatus> get connectionStatus;
}
