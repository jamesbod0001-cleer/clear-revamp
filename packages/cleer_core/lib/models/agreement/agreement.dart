import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:cleer_core/models/payout_destination/payout_destination.dart';
import 'package:cleer_core/models/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreement.freezed.dart';

@freezed
abstract class Agreement with _$Agreement {
  const Agreement._();

  const factory Agreement({
    required String? id,
    required String shortCode,
    required double amount,
    required String currency,
    required DisbursementType disbursementType,
    required AgreementCategory category,
    DateTime? expectedReleaseDate,
    required String description,
    required InitiatorRole initiatorRole,
    @Default(AgreementStatus.draft) AgreementStatus status,
    List<String>? participants,
    String? lastUpdatedBy,
    PayoutDestination? payoutDestination,
    User? initiator,
    User? sender,
    User? recipient,
    DateTime? createdAt,
  }) = _Agreement;

  String get shareLink => 'https://cleerpayments.com/a/$shortCode';
}
