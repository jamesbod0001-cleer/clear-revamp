import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/activity/activity_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';

@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    String? id,
    required String userId,
    required ActivityType type,
    required String heading,
    required String supportingText,
    String? formattedAmount,
    String? description,
    @Default(false) isRead,
    String? entityId,
    DateTime? createdAt,
  }) = _Activity;
}
