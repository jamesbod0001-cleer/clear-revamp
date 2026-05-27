import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_api/src/mappers/activity_mappers.dart';
import 'package:cleer_api/src/services/api/amplify_activity_service_client.dart';
import 'package:cleer_core/models/paginated_list/paginated_list.dart';
import 'package:result_dart/result_dart.dart';
import 'package:cleer_api/src/repositories/api/mixins/amplify_api_repository_mixin.dart';

class AmplifyActivityRepositoryImpl
    with AmplifyApiRepositoryMixin
    implements ActivityRepository {
  final AmplifyActivityServiceClient _amplifyActivityServiceClient;

  AmplifyActivityRepositoryImpl({
    required AmplifyActivityServiceClient amplifyActivityServiceClient,
  }) : _amplifyActivityServiceClient = amplifyActivityServiceClient;

  @override
  AmplifyLogger get log => AmplifyLogger('AmplifyActivityRepositoryImpl');

  @override
  Future<ResultDart<PaginatedList<Activity>, DataFailure>> getUserActivities({
    required String userId,
    dynamic nextRequest,
  }) async {
    return await performDataOperation<PaginatedList<Activity>>(
      operation: () async {
        final response = await _amplifyActivityServiceClient
            .queryListUserActivities(
              userId: userId,
              limit: 20,
              nextRequest: nextRequest,
            );
        return PaginatedList(
          items: response.items
              .whereType<amplify_model.Activity>()
              .map((e) => e.toDomain())
              .toList(),
          hasNextPage: response.hasNextResult,
          nextRequest: response.requestForNextResult,
        );
      },
      operationName: 'GetUserActivities',
    );
  }

  @override
  Stream<Activity> observeUserActivityCreates({required String userId}) {
    return _amplifyActivityServiceClient
        .observeUserActivityCreates(userId: userId)
        .handleError((error) => log.error('Stream error for activity', error))
        .where((event) => event.data != null)
        .map((event) {
          log.info('New event: Activity created: ${event.data}');
          return event.data!.toDomain();
        });
  }
}
