import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreements_state.freezed.dart';

enum OngoingAgreementFilter { all, needsAction, awaitingOtherParty }

@freezed
abstract class AgreementsState with _$AgreementsState {
  const factory AgreementsState({
    @Default(0) int selectedTabIndex,
    @Default(OngoingAgreementFilter.all) OngoingAgreementFilter ongoingFilter,
  }) = _AgreementsState;
}
