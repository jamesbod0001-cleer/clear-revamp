import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_charges_params.freezed.dart';

@freezed
abstract class ListChargesParams with _$ListChargesParams {
  const factory ListChargesParams({
    String? status,
    String? reference,
    DateTime? to,
    DateTime? from,
    String? customerId,
    String? virtualAccountId,
    String? paymentMethodId,
    @Default(1) int page,
    @Default(10) int size,
  }) = _ListChargesParams;
}
