import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'milestone_use_case.g.dart';

@Riverpod(keepAlive: true)
class MilestoneUseCase extends _$MilestoneUseCase {
  late final MilestoneRepository _milestoneRepository;

  final _log = AmplifyLogger("MilestoneUseCase");

  @override
  void build() {
    _milestoneRepository = ref.watch(milestoneRepositoryProvider);
    return;
  }

  Future<ResultDart<Milestone, DataFailure>> updateMilestone(
    Milestone milestone,
  ) async {
    _log.info('Attempting to get user');
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing');
      return Failure(DataFailure.notFound());
    }

    _log.info('Updating milestone: $milestone');
    final result = await _milestoneRepository.updateMilestone(
      milestone,
      currentUserId: user.id,
    );
    result.fold(
      (milestone) {
        _log.info('Milestone updated: $milestone');
      },
      (failure) {
        _log.error('Error updating milestone', failure);
        throw failure;
      },
    );
    return result;
  }

  Future<ResultDart<List<Milestone>, DataFailure>> getMilestonesByAgreement(
    String agreementId,
  ) async {
    _log.info('Attempting to get milestones by agreement');
    final result = await _milestoneRepository.getMilestonesByAgreement(
      agreementId,
    );
    result.fold(
      (milestone) {
        _log.info('Successfully retrieved milestones by agreement');
      },
      (failure) {
        _log.error('Error retrieving milestones by agreement', failure);
        return Failure(failure);
      },
    );
    return result;
  }

  Future<ResultDart<Milestone, DataFailure>> getMilestone(String id) async {
    _log.info('Attempting to get milestone');
    final result = await _milestoneRepository.getMilestone(id);
    result.fold(
      (milestone) {
        _log.info('Successfully retrieved milestone');
      },
      (failure) {
        _log.error('Error retrieving milestone', failure);
        return Failure(failure);
      },
    );
    return result;
  }

  Future<ResultDart<Milestone, DataFailure>> releaseFunds(String id) async {
    _log.info('Attempting to get user');
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing');
      return Failure(DataFailure.notFound());
    }

    _log.info('Attempting to release funds for milestone: $id');
    final result = await _milestoneRepository.releaseFunds(
      id,
      currentUserId: user.id,
    );
    result.fold(
      (milestone) {
        _log.info('Successfully released funds for milestone');
      },
      (failure) {
        _log.error('Error releasing funds for milestone', failure);
        return Failure(failure);
      },
    );
    return result;
  }
}
