import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_payout_destination_params.freezed.dart';

@freezed
abstract class GetPayoutDestinationParams with _$GetPayoutDestinationParams {
  const factory GetPayoutDestinationParams({
    required String accountNumber,
    required String bankCode,
  }) = _GetPayoutDestinationParams;
}
