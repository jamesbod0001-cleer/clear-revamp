import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/milestone/milestone_enums.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone.freezed.dart';

@freezed
abstract class Milestone with _$Milestone {
  const factory Milestone({
    required String? id,
    required int order,
    required String name,
    required double amount,
    required MilestoneStatus status,
    required DateTime expectedReleaseDate,
    Agreement? agreement,
    List<String>? participants,
    String? lastUpdatedBy,
  }) = _Milestone;
}

extension MilestoneListX on List<Milestone> {
  /// Returns the currently active milestone, or the first milestone if all are pending or all are released.
  /// Assumes the list is already sorted by order.
  Milestone? get currentlyRunning {
    return firstWhereOrNull(
          (milestone) =>
              milestone.status != MilestoneStatus.pending &&
              milestone.status != MilestoneStatus.released,
        ) ??
        firstOrNull;
  }
}
