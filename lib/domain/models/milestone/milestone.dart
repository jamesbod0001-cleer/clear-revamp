import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone.freezed.dart';

@freezed
abstract class Milestone with _$Milestone {
  const factory Milestone({
    required String? id,
    required int order,
    required String name,
    required double amount,
    required DateTime expectedReleaseDate,
    Agreement? agreement,
  }) = _Milestone;
}
