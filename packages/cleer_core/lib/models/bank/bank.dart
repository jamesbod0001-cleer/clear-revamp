import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank.freezed.dart';

@freezed
abstract class Bank with _$Bank {
  const factory Bank({
    required String id,
    required String code,
    required String name,
  }) = _Bank;
}
