import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/repositories/api/user/amplify_user_repository_impl.dart';
import 'package:cleer/data/services/api/amplify_user_service_client.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/user/user.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(Ref ref) => AmplifyUserRepositoryImpl(
  amplifyUserServiceClient: ref.watch(amplifyUserServiceClientProvider),
);

abstract class UserRepository {
  Future<ResultDart<User, DataFailure>> getOrCreateUserProfile(User user);
  Future<ResultDart<User, DataFailure>> updateUserProfile(User user);
  Stream<User> watchUser(String id);
}
