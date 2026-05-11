import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
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
  StreamSubscription? _updateSub;

  final _log = AmplifyLogger('UserOngoingAgreements');

  @override
  FutureOr<List<Agreement>> build() async {
    final user = await ref.watch(userProfileProvider.future);
    if (user == null) return [];

    final repository = ref.watch(agreementRepositoryProvider);

    // Initial setup
    _setupSubscription();

    // The "Self-Healing" Listener
    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        _log.info('🔄 Agreements Sync: Fetching latest list');
        final result = await repository.getUserOngoingAgreements();
        state = AsyncData(_sort(result.getOrThrow()));
      },
      onReconnectRequired: () {
        _log.info('📡 Agreements Recovery: Restarting Stream');
        _setupSubscription();
      },
    );

    ref.onDispose(() => _updateSub?.cancel());

    final result = await repository.getUserOngoingAgreements();
    return _sort(result.getOrThrow());
  }

  void _setupSubscription() {
    _updateSub?.cancel();
    _updateSub = ref
        .read(agreementRepositoryProvider)
        .observeUserAgreementsUpdates()
        .listen(_handleUpdate);
  }

  Future<void> _handleUpdate(Agreement incompleteItem) async {
    final repository = ref.read(agreementRepositoryProvider);
    final agreementResult = await repository.getAgreement(incompleteItem.id!);

    if (agreementResult.isError()) return;
    final updatedItem = agreementResult.getOrNull()!;

    final currentList = state.value ?? [];
    final oldItem = currentList.singleWhereOrNull(
      (i) => i.id == updatedItem.id,
    );

    final isOngoing = _isOngoing(updatedItem.status);
    final isTerminal = _isTerminal(updatedItem.status);

    List<Agreement> newList;

    if (oldItem == null) {
      if (!isOngoing) return;
      newList = [updatedItem, ...currentList];
    } else {
      if (isOngoing) {
        newList = currentList
            .map((i) => i.id == updatedItem.id ? updatedItem : i)
            .toList();
      } else if (isTerminal) {
        newList = currentList.where((i) => i.id != updatedItem.id).toList();
      } else {
        newList = currentList;
      }
    }
    state = AsyncData(_sort(newList));
  }

  // Helpers to keep build() clean
  List<Agreement> _sort(List<Agreement> list) =>
      list..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

  bool _isOngoing(AgreementStatus? s) => const [
    AgreementStatus.awaitingFunding,
    AgreementStatus.awaitingRecipient,
    AgreementStatus.funded,
    AgreementStatus.inProgress,
    AgreementStatus.readyForRelease,
  ].contains(s);

  bool _isTerminal(AgreementStatus? s) => const [
    AgreementStatus.released,
    AgreementStatus.rejected,
    AgreementStatus.cancelled,
  ].contains(s);
}

@riverpod
class AgreementStatusHistory extends _$AgreementStatusHistory {
  StreamSubscription? _createSub;

  @override
  FutureOr<List<StatusHistory>> build(String agreementId) async {
    // Keep in memory for 5 mins of inactivity
    ref.cacheFor(const Duration(minutes: 5));

    final userId = ref.watch(
      userProfileProvider.select((user) => user.value?.id),
    );
    if (userId == null) {
      return [];
    }

    _setupSubscription(agreementId);

    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        final result = await ref
            .read(agreementRepositoryProvider)
            .getAgreementStatusHistory(agreementId);
        state = AsyncData(_sort(result.getOrThrow()));
      },
      onReconnectRequired: () => _setupSubscription(agreementId),
    );

    ref.onDispose(() => _createSub?.cancel());

    final result = await ref
        .read(agreementRepositoryProvider)
        .getAgreementStatusHistory(agreementId);
    return _sort(result.getOrThrow());
  }

  void _setupSubscription(String agreementId) {
    _createSub?.cancel();
    _createSub = ref
        .read(agreementRepositoryProvider)
        .observeAgreementStatusHistoryCreates(agreementId)
        .listen((newItem) {
          final current = state.value ?? [];
          state = AsyncData(_sort([...current, newItem]));
        });
  }

  List<StatusHistory> _sort(List<StatusHistory> list) =>
      list..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
}

@riverpod
List<Agreement> needsActionAgreements(Ref ref) {
  final agreements = ref.watch(userOngoingAgreementsProvider).value ?? [];
  final currentUser = ref.watch(userProfileProvider).value;

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
  final currentUser = ref.watch(userProfileProvider).value;

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
