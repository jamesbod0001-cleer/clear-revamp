import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_list.freezed.dart';

@freezed
abstract class PaginatedList<T> with _$PaginatedList<T> {
  const factory PaginatedList({
    required List<T> items,
    required bool hasNextPage,
    // We store the 'request' for the next page so the Repository knows how to fetch more
    dynamic nextRequest,
  }) = _PaginatedList;
}
