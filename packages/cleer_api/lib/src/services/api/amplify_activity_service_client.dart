import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/ModelProvider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cleer_api/src/services/amplify_providers.dart';
import 'package:cleer_api/src/services/api/mixins/api_error_checker.dart';

part 'amplify_activity_service_client.g.dart';

@Riverpod(keepAlive: true)
AmplifyActivityServiceClient amplifyActivityServiceClient(Ref ref) =>
    AmplifyActivityServiceClient(amplifyAPI: ref.watch(amplifyAPIProvider));

class AmplifyActivityServiceClient with ApiErrorChecker {
  final APICategory _amplifyAPI;

  AmplifyActivityServiceClient({required APICategory amplifyAPI})
    : _amplifyAPI = amplifyAPI;

  Future<PaginatedResult<Activity>> queryListUserActivities({
    required String userId,
    int limit = 20,
    GraphQLRequest<PaginatedResult<Activity>>? nextRequest,
  }) async {
    if (nextRequest != null) {
      final response = await _amplifyAPI.query(request: nextRequest).response;
      return validateRequiredResponse(response);
    }
    const graphQLDocument = '''
    query ListActivitiesByUser(\$userId: ID!, \$limit: Int, \$nextToken: String) {
      listActivitiesByUser(userId: \$userId, sortDirection: DESC, limit: \$limit, nextToken: \$nextToken) {
        items {
          id
          userId
          type
          heading
          supportingText
          formattedAmount
          description
          isRead
          entityId
          createdAt
        }
        nextToken
      }
    }
  ''';

    final request = GraphQLRequest<PaginatedResult<Activity>>(
      document: graphQLDocument,
      variables: {'userId': userId, 'limit': limit},
      modelType: const PaginatedModelType(Activity.classType),
      decodePath: 'listActivitiesByUser',
    );

    final response = await _amplifyAPI.query(request: request).response;
    return validateRequiredResponse(response);
  }

  Stream<GraphQLResponse<Activity>> observeUserActivityCreates({
    required String userId,
  }) {
    final subscriptionRequest = ModelSubscriptions.onCreate(
      Activity.classType,
      // where: Activity.USERID.eq(userId),
    );
    return _amplifyAPI.subscribe(subscriptionRequest);
  }
}
