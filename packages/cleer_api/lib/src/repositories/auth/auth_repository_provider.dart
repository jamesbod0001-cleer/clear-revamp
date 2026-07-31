import 'package:cleer_api/src/services/auth/amplify_auth_service_client.dart';
import 'package:cleer_core/cleer_core.dart';
import 'amplify_auth_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AmplifyAuthRepositoryImpl(
  amplifyAuthServiceClient: ref.watch(amplifyAuthServiceClientProvider),
);
