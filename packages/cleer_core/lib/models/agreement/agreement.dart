import 'package:cleer_core/cleer_core.dart';
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
    PhysicalDeliveryContext? physicalDeliveryContext,
    List<String>? participants,
    String? lastUpdatedBy,
    PayoutDestination? payoutDestination,
    User? initiator,
    User? sender,
    User? recipient,
    DateTime? createdAt,
  }) = _Agreement;

  String get shareLink => '${AppConfig.baseUrl}/a/$shortCode';
}
