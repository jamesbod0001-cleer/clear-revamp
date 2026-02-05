import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_charge_params.freezed.dart';

@freezed
abstract class CreateChargeParams with _$CreateChargeParams {
  const factory CreateChargeParams({
    required double amount,
    required String reference,
    required String customerId,
    Map<String, dynamic>? meta,
    required String paymentMethodId,
    String? redirectUrl,
    @Default(false) bool recurring,
    String? orderId,
    String? merchantVatAmount,
  }) = _CreateChargeParams;
}
