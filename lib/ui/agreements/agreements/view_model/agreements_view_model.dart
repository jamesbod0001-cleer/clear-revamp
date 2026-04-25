import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/ui/agreements/agreements/state/agreements_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agreements_view_model.g.dart';

@Riverpod(keepAlive: true)
class AgreementsViewModel extends _$AgreementsViewModel {
  @override
  AgreementsState build() {
    // Initial state
    return const AgreementsState();
  }

  void setTabIndex(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void setFilter(OngoingAgreementFilter filter) {
    state = state.copyWith(ongoingFilter: filter);
  }
}

// --- DERIVED LIST PROVIDER ---
// Because fetching the data relies on async Domain providers,
// we keep the actual filtering as a separate derived provider that "watches" your ViewModel.
@riverpod
AsyncValue<List<Agreement>> agreementsScreenList(Ref ref) {
  // Watch the filter from your ViewModel!
  final filter = ref.watch(
    agreementsViewModelProvider.select((s) => s.ongoingFilter),
  );

  // Watch the base data
  final agreementsState = ref.watch(userOngoingAgreementsProvider);

  if (agreementsState.isLoading || agreementsState.hasError) {
    return agreementsState;
  }

  // Apply the logic using the Domain's business rules
  switch (filter) {
    case OngoingAgreementFilter.all:
      return AsyncData(agreementsState.value ?? []);
    case OngoingAgreementFilter.needsAction:
      return AsyncData(ref.watch(needsActionAgreementsProvider));
    case OngoingAgreementFilter.awaitingOtherParty:
      return AsyncData(ref.watch(awaitingOtherPartyAgreementsProvider));
  }
}
