import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer/data/mappers/user_mappers.dart';
import 'package:cleer/data/repositories/api/mixins/amplify_api_repository_mixin.dart';
import 'package:cleer/data/repositories/api/user/user_repository.dart';
import 'package:cleer/data/services/api/amplify_user_service_client.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/user/user.dart';

class AmplifyUserRepositoryImpl
    with AmplifyApiRepositoryMixin
    implements UserRepository {
  final AmplifyUserServiceClient _amplifyUserServiceClient;

  AmplifyUserRepositoryImpl({
    required AmplifyUserServiceClient amplifyUserServiceClient,
  }) : _amplifyUserServiceClient = amplifyUserServiceClient;

  @override
  AmplifyLogger get log => AmplifyLogger('AmplifyUserRepositoryImpl');

  @override
  Future<ResultDart<User, DataFailure>> getOrCreateUserProfile(
    User user,
  ) async {
    return await performDataOperation<User>(
      operation: () async {
        final response = await _amplifyUserServiceClient.queryUser(user.id);
        return response.toDomain();
      },
      operationName: 'GetUserProfile',
      targetId: user.id,
    ).flatMapError((failure) async {
      if (failure is! NotFound) {
        log.error('Permanent failure during getOrCreateUserProfile: $failure');
        return Failure(failure);
      }

      log.info('User profile does not exist. Creating now...');
      return await performDataOperation<User>(
        operation: () async {
          final response = await _amplifyUserServiceClient.createUser(
            user.toAmplify(),
          );
          return response.toDomain();
        },
        operationName: 'CreateUserProfile',
        targetId: user.id,
      );
    });
  }

  @override
  Future<ResultDart<User, DataFailure>> updateUserProfile(User user) {
    return performDataOperation<User>(
      operation: () async {
        final response = await _amplifyUserServiceClient.updateUser(
          user.toAmplify(),
        );
        return response.toDomain();
      },
      operationName: 'UpdateUserProfile',
      targetId: user.id,
    );
  }

  @override
  Stream<User> watchUser(String id) async* {
    log.info('Starting watch for user: $id');
    final initialResult = await performDataOperation(
      operation: () async {
        final response = await _amplifyUserServiceClient.queryUser(id);
        return response.toDomain();
      },
      operationName: 'InitialWatchFetch',
      targetId: id,
    );
    if (initialResult.isSuccess()) {
      yield initialResult.getOrNull()!;
    }
    yield* _amplifyUserServiceClient
        .observeUserUpdates(id)
        .handleError((error) => log.error('Stream error for user $id', error))
        .where((event) => event.data != null)
        .map((event) => event.data!.toDomain())
        .distinct();
  }
}
