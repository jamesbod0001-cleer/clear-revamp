import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_failures.freezed.dart';

@freezed
abstract class StorageFailure with _$StorageFailure {
  const factory StorageFailure.storageAccessDeniedException() =
      StorageAccessDeniedException;
  const factory StorageFailure.canceled() = CanceledStorageFailure;
  const factory StorageFailure.unknown({String? code, String? message}) =
      UnknownStorageFailure;
}
