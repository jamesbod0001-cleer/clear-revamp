import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/paginated_list/paginated_list.dart';
import 'package:result_dart/result_dart.dart';

abstract class ActivityRepository {
  Future<ResultDart<PaginatedList<Activity>, DataFailure>> getUserActivities({
    required String userId,
    dynamic nextRequest,
  });
  Stream<Activity> observeUserActivityCreates({required String userId});
}
