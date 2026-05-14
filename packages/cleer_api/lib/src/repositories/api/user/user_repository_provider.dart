import 'package:cleer_core/cleer_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/repositories/api/user/amplify_user_repository_impl.dart';
import 'package:cleer_api/src/services/api/amplify_user_service_client.dart';

part 'user_repository_provider.g.dart';

@riverpod
UserRepository userRepository(Ref ref) => AmplifyUserRepositoryImpl(
  amplifyUserServiceClient: ref.watch(amplifyUserServiceClientProvider),
);
