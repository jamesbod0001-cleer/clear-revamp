import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:cleer_core/models/milestone/milestone_preview.dart';
import 'package:cleer_core/models/user/user_preview.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreement_preview.freezed.dart';

@freezed
abstract class AgreementPreview with _$AgreementPreview {
  const factory AgreementPreview({
    required String shortCode,
    required double amount,
    required String currency,
    required DisbursementType disbursementType,
    required AgreementCategory category,
    DateTime? expectedReleaseDate,
    required String description,
    required InitiatorRole initiatorRole,
    required AgreementStatus status,

    UserPreview? initiator,
    UserPreview? sender,
    UserPreview? recipient,

    String? recipientBankName,
    String? recipientAccountName,
    String? recipientAccountNumber,

    List<MilestonePreview>? milestones,
  }) = _AgreementPreview;
}
