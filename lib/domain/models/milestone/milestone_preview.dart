import 'package:cleer/domain/models/milestone/milestone_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone_preview.freezed.dart';

@freezed
abstract class MilestonePreview with _$MilestonePreview {
  const factory MilestonePreview({
    required String id,
    required int order,
    required String name,
    required double amount,
    required DateTime expectedReleaseDate,
  }) = _MilestonePreview;
}
