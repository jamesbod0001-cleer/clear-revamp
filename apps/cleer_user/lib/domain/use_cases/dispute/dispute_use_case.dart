import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/milestone/milestone_enums.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dispute_use_case.g.dart';

@Riverpod(keepAlive: true)
class DisputeUseCase extends _$DisputeUseCase {
  late final DisputeRepository _disputeRepository;
  late final AgreementRepository _agreementRepository;
  late final MilestoneRepository _milestoneRepository;

  final _log = AmplifyLogger("DisputeUseCase");

  @override
  void build() {
    _disputeRepository = ref.watch(disputeRepositoryProvider);
    _agreementRepository = ref.watch(agreementRepositoryProvider);
    _milestoneRepository = ref.watch(milestoneRepositoryProvider);
  }

  Future<ResultDart<Dispute, DataFailure>> createDispute(
    Dispute dispute,
  ) async {
    final targetAgreementId = dispute.agreement?.id;
    _log.info('Creating dispute for agreement: $targetAgreementId');
    final user = ref.read(userProfileProvider).value;
    if (user == null || targetAgreementId == null) {
      _log.error('User or agreement is missing');
      return Failure(DataFailure.notFound());
    }

    final result = await _disputeRepository.createDispute(dispute);

    return result.fold(
      (createdDispute) async {
        _log.info('Successfully created dispute: ${createdDispute.id}');

        if (dispute.milestone != null) {
          _log.info('Updating milestone status to disputed: ${dispute.milestone!.id}');
          await _milestoneRepository.updateMilestone(
            dispute.milestone!.copyWith(status: MilestoneStatus.disputed),
            currentUserId: user.id,
          );
        } else if (dispute.agreement != null) {
          _log.info('Updating agreement status to disputed: $targetAgreementId');
          await _agreementRepository.updateAgreement(
            dispute.agreement!.copyWith(status: AgreementStatus.disputed),
            currentUserId: user.id,
          );
        }

        return Success(createdDispute);
      },
      (failure) {
        _log.error('Error creating dispute', failure);
        return Failure(failure);
      },
    );
  }
}
