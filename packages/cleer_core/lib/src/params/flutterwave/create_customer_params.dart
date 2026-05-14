import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_customer_params.freezed.dart';

@freezed
abstract class CreateCustomerParams with _$CreateCustomerParams {
  const factory CreateCustomerParams({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? middleName,
    Map<String, dynamic>? meta,
  }) = _CreateCustomerParams;
}
