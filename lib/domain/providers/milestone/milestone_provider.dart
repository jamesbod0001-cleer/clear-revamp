import 'package:cleer/data/repositories/api/milestone/milestone_repository.dart';
import 'package:cleer/domain/models/milestone/milestone.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'milestone_provider.g.dart';

@Riverpod(keepAlive: true)
class AgreementMilestones extends _$AgreementMilestones {
  @override
  FutureOr<List<Milestone>> build(String agreementId) async {
    ref.watch(userProvider);
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
