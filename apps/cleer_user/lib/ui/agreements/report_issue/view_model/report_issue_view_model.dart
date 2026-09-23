import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/domain/use_cases/dispute/dispute_use_case.dart';
import 'package:cleer/domain/use_cases/milestone/milestone_use_case.dart';
import 'package:cleer/domain/use_cases/storage/storage_use_case.dart';
import 'package:cleer/ui/agreements/report_issue/state/report_issue_state.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:command_it/command_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'report_issue_view_model.g.dart';

@riverpod
class ReportIssueViewModel extends _$ReportIssueViewModel {
  final _log = AmplifyLogger("ReportIssueViewModel");

  late Command<int, void> pickEvidenceFilesCommand;

  @override
  FutureOr<ReportIssueState> build(String agreementId) {
    pickEvidenceFilesCommand = Command.createAsyncNoResult(
      _pickEvidenceFiles,
      errorFilter: const LocalErrorFilter(),
    );

    final disputeId = const Uuid().v4();
    return ReportIssueState(
      formData: ReportIssueFormData(disputeId: disputeId),
    );
  }

  void onReasonChanged(DisputeReason reason) {
    if (state.hasValue) {
      _log.info('Reason changed to: ${reason.id}');
      final currentFormData = state.value!.formData;
      state = AsyncValue.data(
        state.value!.copyWith(
          formData: currentFormData.copyWith(reason: reason),
        ),
      );
    }
  }

  void onDescriptionChanged(String description) {
    if (state.hasValue) {
      final currentFormData = state.value!.formData;
      state = AsyncValue.data(
        state.value!.copyWith(
          formData: currentFormData.copyWith(description: description),
        ),
      );
    }
  }

  Future<void> _pickEvidenceFiles(int remainingLimit) async {
    if (!state.hasValue) return;

    _log.info('Picking evidence files (remaining limit: $remainingLimit)');
    final pickResult = await ref
        .read(storageUseCaseProvider.notifier)
        .pickFiles(
          PickFilesParams(
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png',
              'pdf',
              'doc',
              'docx',
              'mp4',
              'mov',
            ],
            allowMultiple: true,
            limit: remainingLimit,
          ),
        );

    pickResult.fold(
      (files) {
        _log.info('Picked ${files.length} evidence files');
        if (state.hasValue) {
          final currentFormData = state.value!.formData;
          final updatedFiles = [
            ...currentFormData.evidenceFiles,
            ...files,
          ].take(ReportIssueFormData.maxEvidenceFilesLimit).toList();

          state = AsyncValue.data(
            state.value!.copyWith(
              formData: currentFormData.copyWith(evidenceFiles: updatedFiles),
            ),
          );
        }
      },
      (failure) {
        if (failure is CanceledStorageFailure) {
          _log.info('User canceled picking files');
          return;
        }
        _log.error('Error picking evidence files', failure);
        throw failure;
      },
    );
  }

  void removeEvidenceFile(int index) {
    if (state.hasValue) {
      final currentFormData = state.value!.formData;
      final updatedFiles = [...currentFormData.evidenceFiles]..removeAt(index);
      state = AsyncValue.data(
        state.value!.copyWith(
          formData: currentFormData.copyWith(evidenceFiles: updatedFiles),
        ),
      );
    }
  }

  Future<bool> submitReportIssue() async {
    _log.info('Submitting dispute report for agreement: $agreementId');
    if (!state.hasValue || !state.value!.formData.isValid) {
      return false;
    }

    final formData = state.value!.formData;
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User profile not available for dispute submission');
      return false;
    }

    final keepAliveLink = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      var agreement = ref.read(agreementDetailsProvider(agreementId)).value;
      if (agreement == null) {
        _log.info('Fetching agreement details for: $agreementId');
        final agreementResult = await ref
            .read(agreementUseCaseProvider.notifier)
            .getAgreement(agreementId);
        agreement = agreementResult.getOrNull();
      }

      if (agreement == null) {
        _log.error('Agreement not available for dispute submission');
        state = AsyncValue.error(DataFailure.notFound(), StackTrace.current);
        return false;
      }

      List<String> uploadedKeys = [];

      if (formData.evidenceFiles.isNotEmpty) {
        _log.info('Uploading ${formData.evidenceFiles.length} evidence files');
        final uploadTasks = formData.evidenceFiles.asMap().entries.map((
          entry,
        ) async {
          final index = entry.key + 1;
          final file = entry.value;
          final path =
              'agreements/${agreement!.id}/disputes/${formData.disputeId}/evidence/${DateTime.now().millisecondsSinceEpoch}_${index}_${file.name}';

          final uploadResult = await ref
              .read(storageUseCaseProvider.notifier)
              .uploadFile(file: file, fullPath: path);

          if (uploadResult.isError()) {
            throw uploadResult.exceptionOrNull()!;
          }
          return uploadResult.getOrNull()!;
        });

        uploadedKeys = await Future.wait(uploadTasks);
        _log.info(
          'Successfully uploaded ${uploadedKeys.length} evidence files',
        );
      }

      Milestone? activeMilestone;
      if (agreement.activeMilestoneId != null) {
        _log.info('Fetching active milestone: ${agreement.activeMilestoneId}');
        final milestoneResult = await ref
            .read(milestoneUseCaseProvider.notifier)
            .getMilestone(agreement.activeMilestoneId!);
        if (milestoneResult.isSuccess()) {
          activeMilestone = milestoneResult.getOrNull();
        }
      }

      final dispute = Dispute(
        id: formData.disputeId,
        agreement: agreement,
        milestone: activeMilestone,
        raisedBy: user,
        reason: formData.reason!,
        description: formData.description.trim(),
        evidenceKeys: uploadedKeys,
        status: DisputeStatus.open,
        participants: agreement.participants,
      );

      final createDisputeResult = await ref
          .read(disputeUseCaseProvider.notifier)
          .createDispute(dispute);

      if (createDisputeResult.isError()) {
        _log.error(
          'Error creating dispute mutation',
          createDisputeResult.exceptionOrNull(),
        );
        state = AsyncValue.error(
          createDisputeResult.exceptionOrNull()!,
          StackTrace.current,
        );
        return false;
      }

      _log.info('Successfully submitted dispute for agreement $agreementId');
      state = AsyncValue.data(
        ReportIssueState(
          currentStep: ReportIssueStep.success,
          formData: ReportIssueFormData(disputeId: const Uuid().v4()),
        ),
      );
      return true;
    } catch (e, stack) {
      _log.error('Error in submitReportIssue flow', e);
      state = AsyncValue.error(e, stack);
      return false;
    } finally {
      keepAliveLink.close();
    }
  }
}
