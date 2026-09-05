import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/payment_method/payment_method.dart';
import 'package:cleer_core/models/virtual_account/virtual_account.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer_core/utils/reference_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_html/html.dart' as html;

part 'flutterwave_use_case.g.dart';

@Riverpod(keepAlive: true)
class FlutterwaveUseCase extends _$FlutterwaveUseCase {
  late final FlutterwaveRepository _flutterwaveRepository;
  late final UserRepository _userRepository;
  late final TransactionRepository _transactionRepository;

  final _log = AmplifyLogger("FlutterwaveUseCase");

  @override
  void build() {
    _flutterwaveRepository = ref.watch(flutterwaveRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    _transactionRepository = ref.watch(transactionRepositoryProvider);
    return;
  }

  Future<ResultDart<String, DataFailure>> _ensureCustomerId(User user) async {
    if (user.flutterwaveCustomerId.isNotEmpty) {
      return Success(user.flutterwaveCustomerId);
    }
    _log.info('Flutterwave customer ID is empty for user: ${user.id}. Creating customer...');
    final createCustomerResult = await _flutterwaveRepository.createCustomer(
      params: CreateCustomerParams(
        firstName: user.firstName,
        lastName: user.lastName,
        phoneNumber: user.phoneNumber,
      ),
      userId: user.id,
    );
    return createCustomerResult.fold(
      (customer) async {
        _log.info('Successfully created customer with ID: ${customer.id}');
        final updatedUser = user.copyWith(flutterwaveCustomerId: customer.id);
        await _userRepository.updateUserProfile(updatedUser);
        return Success(customer.id);
      },
      (failure) {
        _log.error('Failed to create customer for user: ${user.id}', failure);
        return Failure(failure);
      },
    );
  }

  Future<ResultDart<PaymentMethod, DataFailure>> createPaymentMethod(
      CreatePaymentMethodParams params, {
        bool save = true,
      }) async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing during update');
      return Failure(DataFailure.notFound());
    }

    final customerIdResult = await _ensureCustomerId(user);
    if (customerIdResult.isError()) {
      return Failure(customerIdResult.exceptionOrNull()!);
    }
    final customerId = customerIdResult.getOrThrow();

    _log.info(
      'Attempting to create payment method with type: ${params.runtimeType}',
    );
    final paymentMethodResult = await _flutterwaveRepository
        .createPaymentMethod(
      params.copyWith(customerId: customerId),
    );

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

    if (!save) return Success(paymentMethod);

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
        return Success(paymentMethod);
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

  Future<ResultDart<VirtualAccount, DataFailure>> createVirtualAccount(
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

  Future<ResultDart<VirtualAccount, DataFailure>> initiatePayWithBankTransfer(
      Agreement agreement,
      ) async {
    final User? user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing during update');
      return Failure(DataFailure.notFound());
    }

    final customerIdResult = await _ensureCustomerId(user);
    if (customerIdResult.isError()) {
      return Failure(customerIdResult.exceptionOrNull()!);
    }
    final customerId = customerIdResult.getOrThrow();

    // Calculate fee breakdown
    final cleerFee = FeeCalculator.calculateCleerFee(agreement.amount);
    final chargeAmount = FeeCalculator.calculateChargeAmount(agreement.amount);

    _log.info('Attempting to create virtual account');
    final createVirtualAccountResult = await _flutterwaveRepository
        .createVirtualAccount(
      CreateVirtualAccountParams.dynamic(
        reference: ReferenceGenerator.generate(agreement.id!),
        customerId: customerId,
        amount: chargeAmount,
        meta: {'cleer_agreement_id': agreement.id},
      ),
    );

    return await createVirtualAccountResult.fold(
          (virtualAccount) async {
            // Derive gatewayFee from the gross amount Flutterwave returned
            final gatewayFee = (virtualAccount.amount > chargeAmount)
                ? virtualAccount.amount - chargeAmount
                : FeeCalculator.calculateGatewayFee(chargeAmount);
        _log.info('Successfully created virtual account');
        final transactionResult = await _transactionRepository
            .createTransaction(
          Transaction(
            id: null,
            paymentMethodType: PaymentMethodType.bankTransfer,
            reference: virtualAccount.reference,
            flutterwaveId: virtualAccount.id,
            amount: chargeAmount,  // Base requested: ₦10,000 (matches settlement & webhook)
            cleerFee: cleerFee,    // ₦0
            gatewayFee: gatewayFee,// ₦200 (exact fee added by Flutterwave)
            status: .pending,
            agreement: agreement,
          ),
        );
        return await transactionResult.fold(
              (transaction) {
            _log.info('Successfully created transaction');
            return Success(virtualAccount);
          },
              (failure) {
            _log.error('Error creating transaction', failure);
            return Failure(failure);
          },
        );
      },
          (failure) {
        return Failure(failure);
      },
    );
  }

  String _getPaymentRedirectUrl() {
    if (kIsWeb) {
      return '${html.window.location.origin}/close_payment.html';
    }

    return '${AppConfig.baseUrl}/close_payment.html';
  }

  Future<ResultDart<Charge, DataFailure>> createCharge({
    required Agreement agreement,
    required PaymentMethod paymentMethod,
  }) async {
    final User? user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state is missing during update');
      return Failure(DataFailure.notFound());
    }

    final customerIdResult = await _ensureCustomerId(user);
    if (customerIdResult.isError()) {
      return Failure(customerIdResult.exceptionOrNull()!);
    }
    final customerId = customerIdResult.getOrThrow();

    // Calculate fee breakdown
    final cleerFee = FeeCalculator.calculateCleerFee(agreement.amount);
    final chargeAmount = FeeCalculator.calculateChargeAmount(agreement.amount);
    final gatewayFee = FeeCalculator.calculateGatewayFee(chargeAmount);

    _log.info('Attempting to create charge');

    final chargeResult = await _flutterwaveRepository.createCharge(
      CreateChargeParams(
        agreementId: agreement.id!,
        amount: chargeAmount,
        customerId: customerId,
        paymentMethodId: paymentMethod.id,
        redirectUrl: _getPaymentRedirectUrl(),
      ),
    );

    return await chargeResult.fold(
          (charge) async {
        final transactionResult = await _transactionRepository
            .createTransaction(
          Transaction(
            id: null,
            paymentMethodType: paymentMethod.type,
            reference: charge.reference,
            flutterwaveId: charge.id,
            amount: charge.amount,
            cleerFee: cleerFee,
            gatewayFee: gatewayFee,
            flutterwavePaymentMethodId: paymentMethod.id,
            status: .pending,
            agreement: agreement,
          ),
        );
        return await transactionResult.fold(
              (transaction) {
            _log.info('Successfully created transaction');
            return Success(charge);
          },
              (failure) {
            _log.error('Error creating transaction', failure);
            return Failure(failure);
          },
        );
      },
          (failure) {
        _log.error('Error creating charge', failure);
        return Failure(failure);
      },
    );
  }

  Future<ResultDart<Charge, DataFailure>> updateCharge({
    required String chargeId,
    required UpdateChargeParams params,
  }) async {
    _log.info('Attempting to update charge with id: $chargeId');
    final result = await _flutterwaveRepository.updateCharge(
      chargeId: chargeId,
      params: params,
    );
    result.fold(
      (charge) {
        _log.info('Successfully updated charge with id: $chargeId');
      },
      (failure) {
        _log.error('Error updating charge with id: $chargeId', failure);
      },
    );
    return result;
  }

  Future<ResultDart<Charge, DataFailure>> getCharge(String id) async {
    _log.info('Attempting to retrieve charge with id: $id');
    final result = await _flutterwaveRepository.getCharge(id);
    result.fold(
          (charge) {
        _log.info('Successfully retrieved charge with id: $id');
      },
          (failure) {
        _log.error('Error retrieving charge with id: $id', failure);
      },
    );
    return result;
  }

  Future<ResultDart<List<Charge>, DataFailure>> listCharges(
      ListChargesParams params,
      ) async {
    _log.info('Attempting to list charges with params: $params');
    final result = await _flutterwaveRepository.listCharges(params);
    result.fold(
          (charges) {
        _log.info('Successfully listed charges');
      },
          (failure) {
        _log.error('Error listing charges', failure);
      },
    );
    return result;
  }

  Future<ResultDart<String, DataFailure>> resolveAccount(
      ResolveAccountParams params,
      ) async {
    _log.info('Attempting to resolve account with params: $params');
    final result = await _flutterwaveRepository.resolveAccount(params);
    result.fold(
          (account) {
        _log.info('Successfully resolved account');
        return Success(account);
      },
          (failure) {
        _log.error('Error resolving account', failure);
        return Failure(failure);
      },
    );
    return result;
  }
}
