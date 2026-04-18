import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/milestone/milestone.dart';
import 'package:cleer/domain/models/milestone/milestone_enums.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_history.freezed.dart';

@freezed
abstract class StatusHistory with _$StatusHistory {
  const factory StatusHistory({
    required String entityId,
    required String entityType,
    String? oldStatus,
    required String newStatus,
    String? changedBy,
    DateTime? createdAt,
  }) = _StatusHistory;
}

extension StatusHistoryParsingX on StatusHistory {
  /// Safely converts the backend string (e.g., "AWAITING_FUNDING")
  /// to the Dart enum (AgreementStatus.awaitingFunding)
  AgreementStatus? get parsedAgreementStatus {
    return AgreementStatus.values.firstWhereOrNull(
      (e) =>
          e.name.toLowerCase() == newStatus.replaceAll('_', '').toLowerCase(),
    );
  }

  MilestoneStatus? get parsedMilestoneStatus {
    return MilestoneStatus.values.firstWhereOrNull(
      (e) =>
          e.name.toLowerCase() == newStatus.replaceAll('_', '').toLowerCase(),
    );
  }
}
