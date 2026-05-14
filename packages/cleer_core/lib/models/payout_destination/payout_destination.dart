import 'package:cleer_core/models/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payout_destination.freezed.dart';

@freezed
abstract class PayoutDestination with _$PayoutDestination {
  const factory PayoutDestination({
    required String accountNumber,
    required String bankCode,
    @Default('NGN') String currency,
    User? user,
    required String bankName,
    required String accountName,
    DateTime? createdAt,
  }) = _PayoutDestination;
}
