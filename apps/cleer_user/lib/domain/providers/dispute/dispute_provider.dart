import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/utils/riverpod_extensions.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/utils/riverpod_extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dispute_provider.g.dart';

@Riverpod(retry: noRetry)
class ActiveAgreementDispute extends _$ActiveAgreementDispute {
  StreamSubscription? _updateSub;
  final _log = AmplifyLogger('ActiveAgreementDispute');

  @override
  FutureOr<Dispute?> build(String agreementId) async {
    final repository = ref.watch(disputeRepositoryProvider);

    // Keep in memory for 5 mins of inactivity
    ref.cacheFor(const Duration(minutes: 5));

    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        final result = await repository.getDisputesByAgreement(agreementId);
        result.fold(
          (disputes) => state = AsyncData(_findActiveDispute(disputes)),
          (failure) => state = AsyncError(failure, StackTrace.current),
        );
      },
      onReconnectRequired: () => _setupSubscription(agreementId),
    );

    _setupSubscription(agreementId);

    ref.onDispose(() => _updateSub?.cancel());

    final result = await repository.getDisputesByAgreement(agreementId);
    final disputes = result.getOrNull() ?? [];
    return _findActiveDispute(disputes);
  }

  void _setupSubscription(String agreementId) {
    _updateSub?.cancel();

    _updateSub = ref
        .read(disputeRepositoryProvider)
        .observeAgreementDisputeUpdates(agreementId)
        .listen(
          (_) async {
            final result = await ref
                .read(disputeRepositoryProvider)
                .getDisputesByAgreement(agreementId);
            if (!ref.mounted) return;
            if (result.isSuccess()) {
              state = AsyncData(_findActiveDispute(result.getOrNull()!));
            }
          },
          onError: (e) =>
              _log.error('❌ Active Agreement Dispute Subscription Error', e),
        );
  }

  Dispute? _findActiveDispute(List<Dispute> disputes) {
    for (final dispute in disputes) {
      if (dispute.status == DisputeStatus.open ||
          dispute.status == DisputeStatus.underReview) {
        return dispute;
      }
    }
    return null;
  }
}

@Riverpod(retry: noRetry)
class DisputeStatusHistory extends _$DisputeStatusHistory {
  StreamSubscription? _createSub;
  final _log = AmplifyLogger('DisputeStatusHistory');

  @override
  FutureOr<List<StatusHistory>> build(String disputeId) async {
    ref.cacheFor(const Duration(minutes: 5));

    ref.listenForSubscriptionRecovery(
      onSyncRequired: () async {
        final result = await ref
            .read(disputeRepositoryProvider)
            .getDisputeStatusHistory(disputeId);
        result.fold(
          (list) => state = AsyncData(_sort(list)),
          (failure) => state = AsyncError(failure, StackTrace.current),
        );
      },
      onReconnectRequired: () => _setupSubscription(disputeId),
    );

    _setupSubscription(disputeId);

    ref.onDispose(() => _createSub?.cancel());

    final result = await ref
        .read(disputeRepositoryProvider)
        .getDisputeStatusHistory(disputeId);
    return _sort(result.getOrThrow());
  }

  void _setupSubscription(String disputeId) {
    _createSub?.cancel();

    _createSub = ref
        .read(disputeRepositoryProvider)
        .observeDisputeStatusHistoryCreates(disputeId)
        .listen(
          (event) {
            _log.info('New dispute status history event: ${event.newStatus}');
            final currentList = state.value ?? [];
            state = AsyncData(_sort([...currentList, event]));
          },
          onError: (e) =>
              _log.error('❌ Dispute Status History Subscription Error', e),
        );
  }

  List<StatusHistory> _sort(List<StatusHistory> list) =>
      list..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
}
