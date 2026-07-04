import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_delivery_information_view_model.g.dart';

@riverpod
class ReviewDeliveryInformationViewModel
    extends _$ReviewDeliveryInformationViewModel {
  final _log = AmplifyLogger("ReviewDeliveryInformationViewModel");

  @override
  FutureOr<void> build(String agreementId) {}

  Future<void> confirm() async {
    _log.info(
      'Attempting to confirm shared delivery details for agreement: $agreementId',
    );

    // Prevent premature disposal when the parent widget unmounts this card
    final keepAliveLink = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      final agreementResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .getAgreement(agreementId);

      if (agreementResult.isError()) {
        _log.error('Error getting agreement $agreementId');
        state = AsyncValue.error(
          agreementResult.exceptionOrNull()!,
          StackTrace.current,
        );
        return;
      }

      final agreement = agreementResult.getOrNull()!;
      _log.info('Successfully retrieved agreement $agreementId');

      final updateAgreementResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .updateAgreement(
            agreement.copyWith(
              status: .readyForRelease,
              physicalDeliveryContext: agreement.physicalDeliveryContext!
                  .copyWith(status: .inTransit),
            ),
          );

      updateAgreementResult.fold(
        (updatedAgreement) {
          _log.info(
            'Successfully confirmed shared delivery details for agreement $agreementId',
          );
        },
        (failure) {
          _log.error(
            'Error confirming shared delivery details for $agreementId',
            failure,
          );
          state = AsyncValue.error(failure, StackTrace.current);
        },
      );
    } catch (e, stack) {
      _log.error('Unexpected crash in skip flow', e);
      state = AsyncValue.error(e, stack);
    } finally {
      // Safely release the provider lock so Riverpod can clean it up
      keepAliveLink.close();
    }
  }
}
