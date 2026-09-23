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
}
