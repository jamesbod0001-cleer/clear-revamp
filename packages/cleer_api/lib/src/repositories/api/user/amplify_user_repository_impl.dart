import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer_api/src/mappers/user_mappers.dart';
import 'package:cleer_api/src/repositories/api/mixins/amplify_api_repository_mixin.dart';
import 'package:cleer_api/src/services/api/amplify_user_service_client.dart';

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
  Future<ResultDart<User, DataFailure>> updateDeviceToken(
    String userId,
    String? token,
  ) async {
    return performDataOperation<User>(
      operation: () async {
        final currentUser = await _amplifyUserServiceClient.queryUser(userId);
        final updatedUser = currentUser.copyWith(deviceToken: token);
        final response = await _amplifyUserServiceClient.updateUser(updatedUser);
        return response.toDomain();
      },
      operationName: 'UpdateDeviceToken',
      targetId: userId,
    );
  }

  @override
  Future<ResultDart<User, DataFailure>> getUser(String id) async {
    return await performDataOperation<User>(
      operation: () async {
        final response = await _amplifyUserServiceClient.queryUser(id);
        return response.toDomain();
      },
      operationName: 'GetUser',
      targetId: id,
    );
  }

  @override
  Stream<User> observeUserUpdates(String id) {
    return _amplifyUserServiceClient
        .observeUserUpdates(id)
        .handleError((error) => log.error('Stream error for user $id', error))
        .where((event) => event.data != null)
        .map((event) => event.data!.toDomain());
  }
}
