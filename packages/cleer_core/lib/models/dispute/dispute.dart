import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer_core/models/dispute/dispute_enums.dart';
import 'package:cleer_core/models/milestone/milestone.dart';
import 'package:cleer_core/models/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispute.freezed.dart';

@freezed
abstract class Dispute with _$Dispute {
  const factory Dispute({
    required String? id,
    Agreement? agreement,
    Milestone? milestone,
    User? raisedBy,
    required DisputeReason reason,
    required String description,
    List<String>? evidenceKeys,
    @Default(DisputeStatus.open) DisputeStatus status,
    List<String>? participants,
    String? lastUpdatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Dispute;
}
