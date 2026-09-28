import 'package:cleer_core/cleer_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'report_issue_state.freezed.dart';

enum ReportIssueStep {
  form,
  success,
}

@freezed
abstract class ReportIssueState with _$ReportIssueState {
  const factory ReportIssueState({
    @Default(ReportIssueStep.form) ReportIssueStep currentStep,
    required ReportIssueFormData formData,
  }) = _ReportIssueState;
}

@freezed
abstract class ReportIssueFormData with _$ReportIssueFormData {
  /// Maximum number of evidence files permitted for a dispute
  static const int maxEvidenceFilesLimit = 5;

  const factory ReportIssueFormData({
    required String disputeId,
    DisputeReason? reason,
    @Default('') String description,
    @Default([]) List<XFile> evidenceFiles,
    @Default([]) List<String> evidenceKeys,
  }) = _ReportIssueFormData;

  factory ReportIssueFormData.empty() =>
      const ReportIssueFormData(disputeId: '');
}

extension ReportIssueFormDataX on ReportIssueFormData {
  bool get isValid => reason != null && description.trim().length >= 3;

  /// Helper to check if the max evidence file limit has been reached
  bool get hasReachedMaxEvidence =>
      evidenceFiles.length >= ReportIssueFormData.maxEvidenceFilesLimit;

  /// Remaining evidence file allowance
  int get remainingFileAllowance =>
      ReportIssueFormData.maxEvidenceFilesLimit - evidenceFiles.length;
}
