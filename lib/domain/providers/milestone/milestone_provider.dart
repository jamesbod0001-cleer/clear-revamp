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
  @override
  FutureOr<List<Milestone>> build(String agreementId) async {
    final userId = ref.watch(userProvider.select((user) => user.value?.id));
    if (userId == null) {
      return [];
    }
    final repository = ref.watch(milestoneRepositoryProvider);

    final updateSub = repository
        .observeAgreementMilestonesUpdates(agreementId)
        .listen((updatedItem) {
          final currentList = state.value ?? [];

          state = AsyncData(
            currentList
                .map((item) => item.id == updatedItem.id ? updatedItem : item)
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order)),
          );
        });

    // Clean up when the provider is disposed (or when the user changes)
    ref.onDispose(() {
      updateSub.cancel();
    });

    // Return the initial fetch
    final result = await repository.getMilestonesByAgreement(agreementId);
    return result.getOrThrow()..sort((a, b) => a.order.compareTo(b.order));
  }
}

@riverpod
class MilestoneStatusHistory extends _$MilestoneStatusHistory {
  @override
  FutureOr<List<StatusHistory>> build(String milestoneId) async {
    ref.cacheFor(const Duration(minutes: 5));

    final userId = ref.watch(userProvider.select((user) => user.value?.id));
    if (userId == null) {
      return [];
    }

    final repository = ref.watch(milestoneRepositoryProvider);

    final createSub = repository
        .observeMilestoneStatusHistoryCreates(milestoneId)
        .listen((createdItem) {
          final currentList = state.value ?? [];

          state = AsyncData(
            [...currentList, createdItem]
              ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)),
          );
        });

    // Clean up when the provider is disposed (or when the user changes)
    ref.onDispose(() {
      createSub.cancel();
    });

    // Return the initial fetch
    final result = await repository.getMilestoneStatusHistory(milestoneId);
    return result.getOrThrow()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }
}
