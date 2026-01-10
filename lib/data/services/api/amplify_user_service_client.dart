import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_models/User.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer/data/services/amplify_providers.dart';
import 'package:cleer/data/services/api/mixins/api_error_checker.dart';

part 'amplify_user_service_client.g.dart';

@riverpod
AmplifyUserServiceClient amplifyUserServiceClient(Ref ref) =>
    AmplifyUserServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyUserServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyUserServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;

  Future<User> queryUser(String id) async {
    final request = ModelQueries.get(
      User.classType,
      UserModelIdentifier(id: id),
    );
    final response = await _amplifyAPI.query(request: request).response;
    validateResponse(response);
    return response.data!;
  }

  Future<User> createUser(User user) async {
    final request = ModelMutations.create(
      user,
      authorizationMode: APIAuthorizationType.userPools,
    );
    final response = await _amplifyAPI.mutate(request: request).response;
    validateResponse(response);
    return response.data!;
  }

  Stream<GraphQLResponse<User>> observeUserUpdates(String id) {
    final subscriptionRequest = ModelSubscriptions.onUpdate(
      User.classType,
      authorizationMode: APIAuthorizationType.userPools,
      where: User.ID.eq(id),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }
}
