import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/mappers/network_mappers.dart';
import 'package:cleer_api/src/services/network/network_service_client.dart';
import 'package:cleer_core/cleer_core.dart';

class NetworkRepositoryImpl extends NetworkRepository {
  final NetworkServiceClient _networkServiceClient;

  NetworkRepositoryImpl({required NetworkServiceClient networkServiceClient})
    : _networkServiceClient = networkServiceClient;

  final _log = AmplifyLogger('NetworkRepositoryImpl');

  @override
  Stream<AppConnectionStatus> get connectionStatus async* {
    try {
      _log.info('Starting connection status stream');
      final initialConnectionStatus = await _networkServiceClient.isConnected;
      _log.info('Initial connection status: $initialConnectionStatus');
      yield initialConnectionStatus
          ? AppConnectionStatus.connected
          : AppConnectionStatus.disconnected;
    } catch (e) {
      _log.error('Error getting initial connection status', e);
      yield AppConnectionStatus.disconnected;
    }
    _log.info('Starting connection status stream');
    yield* _networkServiceClient.onStatusChange.map(
      (status) => status.toDomain(),
    );
  }
}
