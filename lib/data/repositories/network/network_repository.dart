import 'package:cleer/data/repositories/network/network_repository_impl.dart';
import 'package:cleer/data/services/network/network_service_client.dart';
import 'package:cleer/domain/models/enums/app_connection_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_repository.g.dart';

@riverpod
NetworkRepository networkRepository(Ref ref) => NetworkRepositoryImpl(
  networkServiceClient: ref.watch(networkServiceClientProvider),
);

abstract class NetworkRepository {
  Stream<AppConnectionStatus> get connectionStatus;
}
