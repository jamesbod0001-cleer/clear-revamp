import 'package:cleer/data/repositories/api/agreement/agreement_repository.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/status_history/status_history.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/utils/riverpod_extensions.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_provider.g.dart';

@Riverpod(keepAlive: true)
class UserOngoingAgreements extends _$UserOngoingAgreements {
  @override
  FutureOr<List<Agreement>> build() async {
    final user = await ref.watch(userProvider.future);

    if (user == null) {
      return [];
    }
    final repository = ref.watch(agreementRepositoryProvider);

    final updateSub = repository.observeUserAgreementsUpdates().listen((
      incompleteUpdatedItem,
    ) async {
      final agreementResult = await repository.getAgreement(
        incompleteUpdatedItem.id!,
      );
      if (agreementResult.isError()) {
        return;
      }

      final updatedItem = agreementResult.getOrNull()!;
      final currentList = state.value ?? [];
      final oldItem = currentList.singleWhereOrNull(
        (item) => item.id == updatedItem.id,
      );

      // Define what makes an agreement "Ongoing"
      final isOngoingStatus = [
        AgreementStatus.awaitingFunding,
        AgreementStatus.awaitingRecipient,
        AgreementStatus.funded,
        AgreementStatus.inProgress,
        AgreementStatus.readyForRelease,
      ].contains(updatedItem.status);

      // Define what makes an agreement "Dead"
      final isTerminalStatus = [
        AgreementStatus.released,
        AgreementStatus.rejected,
        AgreementStatus.cancelled,
      ].contains(updatedItem.status);

      if (oldItem == null) {
        // It's new to the list. If it's an ongoing state, add it!
        if (isOngoingStatus) {
          state = AsyncData(
            [updatedItem, ...currentList]
              ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)),
          );
        }
      } else {
        // It's already in the list.
        if (isOngoingStatus) {
          // It's still ongoing, so just update the data
          state = AsyncData(
            currentList
                .map((item) => item.id == updatedItem.id ? updatedItem : item)
                .toList()
              ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)),
          );
        } else if (isTerminalStatus) {
          // It reached a final state, remove it from the ongoing list!
          state = AsyncData(
            currentList.where((item) => item.id != updatedItem.id).toList()
              ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)),
          );
        }
      }
    });

    // Clean up when the provider is disposed (or when the user changes)
    ref.onDispose(() {
      updateSub.cancel();
    });

    // Return the initial fetch
    final result = await repository.getUserOngoingAgreements();
    return result.getOrThrow()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }
}

@riverpod
class AgreementStatusHistory extends _$AgreementStatusHistory {
  @override
  FutureOr<List<StatusHistory>> build(String agreementId) async {
    ref.cacheFor(const Duration(minutes: 5));

    final userId = ref.watch(userProvider.select((user) => user.value?.id));
    if (userId == null) {
      return [];
    }

    final repository = ref.watch(agreementRepositoryProvider);

    final createSub = repository
        .observeAgreementStatusHistoryCreates(agreementId)
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
    final result = await repository.getAgreementStatusHistory(agreementId);
    return result.getOrThrow()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }
}

@riverpod
List<Agreement> needsActionAgreements(Ref ref) {
  final agreements = ref.watch(userOngoingAgreementsProvider).value ?? [];
  final currentUser = ref.watch(userProvider).value;

  return agreements.where((agreement) {
    final isPending =
        agreement.status == AgreementStatus.awaitingRecipient ||
        agreement.status == AgreementStatus.awaitingFunding;
    final amINotInitiator = agreement.initiator?.id != currentUser?.id;
    final isSender = agreement.sender?.id == currentUser?.id;

    return (isPending && amINotInitiator) ||
        (agreement.status == .readyForRelease && isSender);
  }).toList();
}

@riverpod
List<Agreement> awaitingOtherPartyAgreements(Ref ref) {
  final agreements = ref.watch(userOngoingAgreementsProvider).value ?? [];
  final currentUser = ref.watch(userProvider).value;

  return agreements.where((agreement) {
    final isPending =
        agreement.status == AgreementStatus.awaitingRecipient ||
        agreement.status == AgreementStatus.awaitingFunding;
    final amIInitiator = agreement.initiator?.id == currentUser?.id;

    final isRecipient = agreement.recipient?.id == currentUser?.id;

    return (isPending && amIInitiator) ||
        (agreement.status == .readyForRelease && isRecipient);
  }).toList();
}
