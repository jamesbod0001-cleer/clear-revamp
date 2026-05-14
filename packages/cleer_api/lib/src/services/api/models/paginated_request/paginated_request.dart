import 'package:amplify_flutter/amplify_flutter.dart';

class PaginatedRequest<T extends Model> {
  final int? limit;
  QueryPredicate? where;
  GraphQLRequest<PaginatedResult<T>>? nextRequest;

  PaginatedRequest({this.limit, this.where, this.nextRequest});
}
