import 'package:cleer/data/repositories/network/network_repository.dart';
import 'package:cleer/domain/models/enums/app_connection_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<AppConnectionStatus> connectionStatus(Ref ref) {
  return ref.watch(networkRepositoryProvider).connectionStatus;
}