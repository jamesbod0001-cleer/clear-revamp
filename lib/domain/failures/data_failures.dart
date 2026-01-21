import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_failures.freezed.dart';

@freezed
abstract class DataFailure with _$DataFailure {
  const factory DataFailure.unauthorizedException() = UnauthorizedException;
  const factory DataFailure.notFound() = NotFound;
  const factory DataFailure.unknown({String? code, String? message}) =
      UnknownDataFailure;

  const factory DataFailure.conditionalCheckFailed() =
      ConditionalCheckFailedException;
}
