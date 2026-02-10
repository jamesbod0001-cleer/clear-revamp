import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/user/user_repository.dart';
import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/failures/payment_failures.dart';
import 'package:cleer/domain/models/virtual_account/virtual_account.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_payment_method_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_virtual_account_params.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutterwave_use_case.g.dart';

@riverpod
class FlutterwaveUseCase extends _$FlutterwaveUseCase {
  late final FlutterwaveRepository _flutterwaveRepository;
  late final UserRepository _userRepository;

  final _log = AmplifyLogger("FlutterwaveUseCase");

  @override
  void build() {
    _flutterwaveRepository = ref.watch(flutterwaveRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    return;
  }

  // Future<ResultDart<void, Object>> createPaymentMethod(
  //   CreatePaymentMethodParams params,
  // ) async {
  //   _log.info(
  //     'Attempting to create payment method with type: ${params.runtimeType}',
  //   );
  //   final result = await _flutterwaveRepository.createPaymentMethod(params);
  //   return await result.fold(
  //     (paymentMethod) async {
  //       _log.info(
  //         'Successfully created payment method with id: ${paymentMethod.id}',
  //       );
  //       final User user = ref.watch(userProvider).requireValue!;
  //
  //       final updatedUser = user.copyWith(
  //         flutterwavePaymentMethodIds: [
  //           ...user.flutterwavePaymentMethodIds,
  //           paymentMethod.id,
  //         ],
  //       );
  //       _log.info(
  //         'Updating user profile with new payment method id: ${paymentMethod.id}',
  //       );
  //       return await _userRepository
  //           .updateUserProfile(updatedUser)
  //           .fold(
  //             (updatedUser) {
  //               _log.info(
  //                 'Successfully updated user profile with new payment method id: ${paymentMethod.id}',
  //               );
  //               return Success.unit();
  //             },
  //             (failure) {
  //               _log.error(
  //                 'Error updating user profile with new payment method id: ${paymentMethod.id}',
  //                 failure,
  //               );
  //               return Failure(failure);
  //             },
  //           );
  //     },
  //     (failure) {
  //       _log.error(
  //         'Error creating payment method with type: ${params.runtimeType}',
  //         failure,
  //       );
  //       return Failure(failure);
  //     },
  //   );
  // }

  Future<ResultDart<void, Object>> createPaymentMethod(
    CreatePaymentMethodParams params,
  ) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      _log.error('User state is missing during update');
      return Failure(DataFailure.notFound());
    }
    _log.info(
      'Attempting to create payment method with type: ${params.runtimeType}',
    );
    final paymentMethodResult = await _flutterwaveRepository
        .createPaymentMethod(params);

    if (paymentMethodResult.isError()) {
      _log.error(
        'Flutterwave creation of payment method failed',
        paymentMethodResult.exceptionOrNull(),
      );
      return Failure(paymentMethodResult.exceptionOrNull()!);
    }

    final paymentMethod = paymentMethodResult.getOrThrow();
    _log.info(
      'Successfully created payment method with id: ${paymentMethod.id}',
    );

    final updatedUser = user.copyWith(
      flutterwavePaymentMethodIds: [
        ...user.flutterwavePaymentMethodIds,
        paymentMethod.id,
      ],
    );

    _log.info(
      'Updating user profile with new payment method id: ${paymentMethod.id}',
    );
    final updateResult = await _userRepository.updateUserProfile(updatedUser);

    return updateResult.fold(
      (success) {
        _log.info(
          'Successfully updated user profile with new payment method id: ${paymentMethod.id}',
        );
        return Success.unit();
      },
      (failure) {
        _log.error(
          'Error updating user profile with new payment method id: ${paymentMethod.id}',
          failure,
        );
        return Failure(failure);
      },
    );
  }

  Future<ResultDart<VirtualAccount, PaymentFailure>> createVirtualAccount(
    CreateVirtualAccountParams params,
  ) async {
    _log.info('Attempting to create virtual account with params: $params');
    final result = await _flutterwaveRepository.createVirtualAccount(params);
    result.fold(
      (virtualAccount) {
        _log.info(
          'Successfully created virtual account with id: ${virtualAccount.id}',
        );
      },
      (failure) {
        _log.error(
          'Error creating virtual account with params: $params',
          failure,
        );
      },
    );
    return result;
  }
}
