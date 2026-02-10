import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreement.freezed.dart';

@freezed
abstract class Agreement with _$Agreement {
  const factory Agreement({
    required String id,
    required double amount,
    required String currency,
    required DisbursementType disbursementType,
    required String category,
    required DateTime expectedReleaseDate,
    required String description,
    required PayoutDestination payoutDestination,
    // required String recipientAccountNumber,
    // required String recipientBankCode,
    required InitiatorRole initiatorRole,
    User? initiator,
    @Default(AgreementStatus.draft) AgreementStatus status,
    DateTime? createdAt,
  }) = _Agreement;
}
