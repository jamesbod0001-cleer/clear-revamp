import 'package:freezed_annotation/freezed_annotation.dart';

part 'resolve_account_params.freezed.dart';

@freezed
abstract class ResolveAccountParams with _$ResolveAccountParams {
  const factory ResolveAccountParams({
    required String bankCode,
    required String accountNumber,
  }) = _ResolveAccountParams;
}
