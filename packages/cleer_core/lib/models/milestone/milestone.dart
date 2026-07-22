import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer_core/models/milestone/milestone_enums.dart';
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
    DateTime? releaseEligibleAt,
    Agreement? agreement,
    List<String>? participants,
    String? lastUpdatedBy,
  }) = _Milestone;
}
