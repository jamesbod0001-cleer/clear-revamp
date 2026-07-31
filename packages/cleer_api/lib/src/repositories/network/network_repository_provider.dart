import 'package:cleer_api/src/repositories/network/network_repository_impl.dart';
import 'package:cleer_api/src/services/network/network_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_repository_provider.g.dart';

@Riverpod(keepAlive: true)
NetworkRepository networkRepository(Ref ref) => NetworkRepositoryImpl(
  networkServiceClient: ref.watch(networkServiceClientProvider),
);
