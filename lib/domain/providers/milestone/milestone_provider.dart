import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/repositories/api/milestone/milestone_repository.dart';
import 'package:cleer/domain/models/milestone/milestone.dart';
import 'package:cleer/domain/models/status_history/status_history.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/utils/riverpod_extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'milestone_provider.g.dart';

@Riverpod(keepAlive: true)
class AgreementMilestones extends _$AgreementMilestones {
  StreamSubscription? _updateSub;

  final _log = AmplifyLogger('AgreementMilestones');

  @override
  FutureOr<List<Milestone>> build(String agreementId) async {
    final userId = ref.watch(
      userProfileProvider.select((user) => user.value?.id),
    );
    if (userId == null) {
      return [];
    }

    final repository = ref.watch(milestoneRepositoryProvider);

    _setupSubscription(agreementId);

    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        _log.info('🔄 Milestones Sync: Refreshing for $agreementId');
        final result = await repository.getMilestonesByAgreement(agreementId);
        state = AsyncData(_sort(result.getOrThrow()));
      },
      onReconnectRequired: () => _setupSubscription(agreementId),
    );

    ref.onDispose(() => _updateSub?.cancel());

    final result = await repository.getMilestonesByAgreement(agreementId);
    return _sort(result.getOrThrow());
  }

  void _setupSubscription(String agreementId) {
    _updateSub?.cancel();
    _updateSub = ref
        .read(milestoneRepositoryProvider)
        .observeAgreementMilestonesUpdates(agreementId)
        .listen((updatedItem) {
          final current = state.value ?? [];
          final newList = current
              .map((item) => item.id == updatedItem.id ? updatedItem : item)
              .toList();
          state = AsyncData(_sort(newList));
        });
  }

  List<Milestone> _sort(List<Milestone> list) =>
      list..sort((a, b) => a.order.compareTo(b.order));
}

@riverpod
class MilestoneStatusHistory extends _$MilestoneStatusHistory {
  StreamSubscription? _createSub;

  @override
  FutureOr<List<StatusHistory>> build(String milestoneId) async {
    ref.cacheFor(const Duration(minutes: 5));

    final userId = ref.watch(
      userProfileProvider.select((user) => user.value?.id),
    );
    if (userId == null) {
      return [];
    }

    _setupSubscription(milestoneId);

    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        final result = await ref
            .read(milestoneRepositoryProvider)
            .getMilestoneStatusHistory(milestoneId);
        state = AsyncData(_sort(result.getOrThrow()));
      },
      onReconnectRequired: () => _setupSubscription(milestoneId),
    );

    ref.onDispose(() => _createSub?.cancel());

    final result = await ref
        .read(milestoneRepositoryProvider)
        .getMilestoneStatusHistory(milestoneId);
    return _sort(result.getOrThrow());
  }

  void _setupSubscription(String milestoneId) {
    _createSub?.cancel();
    _createSub = ref
        .read(milestoneRepositoryProvider)
        .observeMilestoneStatusHistoryCreates(milestoneId)
        .listen((createdItem) {
          final current = state.value ?? [];
          state = AsyncData(_sort([...current, createdItem]));
        });
  }

  List<StatusHistory> _sort(List<StatusHistory> list) =>
      list..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
}
