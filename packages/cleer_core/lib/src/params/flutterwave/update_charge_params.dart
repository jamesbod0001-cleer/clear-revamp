import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_charge_params.freezed.dart';

@freezed
abstract class UpdateChargeParams with _$UpdateChargeParams {
  const factory UpdateChargeParams.pin({
    required String pin,
  }) = _PinUpdateParams;

  const factory UpdateChargeParams.otp({
    required String otp,
  }) = _OtpUpdateParams;
}
