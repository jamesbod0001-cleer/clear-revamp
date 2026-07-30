import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<AppConnectionStatus> connectionStatus(Ref ref) {
  return ref.watch(networkRepositoryProvider).connectionStatus;
}

@riverpod
bool isOffline(Ref ref) {
  return ref.watch(connectionStatusProvider).maybeWhen(
        data: (status) => status.isDisconnected,
        orElse: () => false,
      );
}
