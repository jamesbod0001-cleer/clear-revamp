import 'package:cleer/data/repositories/api/agreement/agreement_repository.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:collection/collection.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreement_provider.g.dart';

@Riverpod(keepAlive: true)
class UserOngoingAgreements extends _$UserOngoingAgreements {
  @override
  FutureOr<List<Agreement>> build() async {
    ref.watch(userProvider);
    final repository = ref.watch(agreementRepositoryProvider);

    final updateSub = repository.observeUserAgreementsUpdates().listen((
      incompleteUpdatedItem,
    ) async {
      final updatedItem = await repository
          .getAgreement(incompleteUpdatedItem.id!)
          .getOrThrow();
      final currentList = state.value ?? [];
      final oldItem = currentList.singleWhereOrNull(
        (item) => item.id == updatedItem.id,
      );
      if (oldItem == null) {
        // Meaning it is new to ongoing
        if (updatedItem.status == .awaitingFunding ||
            updatedItem.status == .awaitingRecipient) {
          // It is ongoing
          state = AsyncData(
            [updatedItem, ...currentList]
              ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)),
          );
        }
      } else {
        // Meaning it is already part of ongoing
        if ([
          AgreementStatus.funded,
          AgreementStatus.inProgress,
        ].contains(updatedItem.status)) {
          state = AsyncData(
            currentList
                .map((item) => item.id == updatedItem.id ? updatedItem : item)
                .toList()
              ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)),
          );
        } else if (updatedItem.status == AgreementStatus.released) {
          // Meaning it is completed now
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
