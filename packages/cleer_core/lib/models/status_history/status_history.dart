import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/milestone/milestone_enums.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_history.freezed.dart';

@freezed
abstract class StatusHistory with _$StatusHistory {
  const factory StatusHistory({
    required String entityId,
    required String entityType,
    required String context,
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
    if (context != 'CORE_STATUS') return null; // Safety check
    return AgreementStatus.values.firstWhereOrNull(
      (e) =>
          e.name.toLowerCase() == newStatus.replaceAll('_', '').toLowerCase(),
    );
  }

  MilestoneStatus? get parsedMilestoneStatus {
    if (context != 'CORE_STATUS') return null; // Safety check
    return MilestoneStatus.values.firstWhereOrNull(
      (e) =>
          e.name.toLowerCase() == newStatus.replaceAll('_', '').toLowerCase(),
    );
  }

  PhysicalDeliveryContextStatus? get parsedPhysicalDeliveryStatus {
    if (context != 'DELIVERY_STATUS') return null; // Safety check
    return PhysicalDeliveryContextStatus.values.firstWhereOrNull(
      (e) =>
          e.name.toLowerCase() == newStatus.replaceAll('_', '').toLowerCase(),
    );
  }
}
