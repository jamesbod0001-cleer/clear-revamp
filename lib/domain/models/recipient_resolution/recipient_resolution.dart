import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipient_resolution.freezed.dart';

@freezed
abstract class RecipientResolution with _$RecipientResolution {
  const factory RecipientResolution({
    required String accountName,
    required String accountNumber,
    required String bankCode,
    User? recipient,
    required bool isRegisteredUser,
    PayoutDestination? payoutDestination,
  }) = _RecipientResolution;
}