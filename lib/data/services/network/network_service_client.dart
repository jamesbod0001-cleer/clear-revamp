import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_service_client.g.dart';

@riverpod
InternetConnection internetConnection(Ref ref) => InternetConnection();

@riverpod
NetworkServiceClient networkServiceClient(Ref ref) => NetworkServiceClient(
  internetConnection: ref.watch(internetConnectionProvider),
);

class NetworkServiceClient {
  final InternetConnection _internetConnection;

  NetworkServiceClient({required InternetConnection internetConnection})
    : _internetConnection = internetConnection;

  Future<bool> get isConnected => _internetConnection.hasInternetAccess;

  Stream<InternetStatus> get onStatusChange =>
      _internetConnection.onStatusChange;
}
