import 'package:cleer_api/src/repositories/api/flutterwave/amplify_flutterwave_repository_impl.dart';
import 'package:cleer_api/src/services/api/amplify_flutterwave_proxy_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutterwave_repository_provider.g.dart';

@riverpod
FlutterwaveRepository flutterwaveRepository(Ref ref) =>
    AmplifyFlutterwaveRepositoryImpl(
      proxyServiceClient: ref.watch(amplifyFlutterwaveProxyServiceClientProvider),
    );
