import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/charge/charge.dart';
import 'package:cleer/domain/models/payment_method/payment_method.dart';
import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/domain/use_cases/flutterwave/flutterwave_use_case.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/create_payment_method_params.dart';
import 'package:cleer/domain/use_cases/flutterwave/params/list_charges_params.dart';
import 'package:cleer/domain/use_cases/transaction/transaction_use_case.dart';
import 'package:cleer/domain/use_cases/user/user_use_case.dart';
import 'package:cleer/ui/payment_orchestrator/state/payment_orchestrator_state.dart';
import 'package:command_it/command_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_orchestrator_view_model.g.dart';

@riverpod
class PaymentOrchestratorViewModel extends _$PaymentOrchestratorViewModel {
  final _log = AmplifyLogger("PaymentOrchestratorViewModel");

  @override
  FutureOr<PaymentOrchestratorState> build(String agreementId) async {
    final agreement = await _fetchAgreement(agreementId);
    await ref.read(flutterwaveSavedPaymentMethodsProvider.future);
    generateUSSDCode = Command.createAsync<Bank, String>(
      _generateUSSDCode,
      initialValue: '',
      errorFilter: const LocalErrorFilter(),
    );
    removeCard = Command.createAsyncNoResult<String>(
      _removeCard,
      errorFilter: const LocalErrorFilter(),
    );
    generateVirtualAccount = Command.createAsyncNoParamNoResult(
      _generateVirtualAccount,
      errorFilter: const LocalErrorFilter(),
    );
    return PaymentOrchestratorState(agreement: agreement);
  }

  Future<Agreement> _fetchAgreement(String agreementId) async {
    final agreementResult = await ref
        .read(agreementUseCaseProvider.notifier)
        .getAgreement(agreementId);
    if (agreementResult.isError()) {
      _log.error(
        'Error retrieving agreement',
        agreementResult.exceptionOrNull(),
      );
    }
    return agreementResult.getOrThrow();
  }

  late Command<Bank, String> generateUSSDCode;
  late Command<String, void> removeCard;
  late Command<void, void> generateVirtualAccount;

  Future<void> payWithOpay() async {
    state = AsyncData(state.value!.copyWith(currentStep: .continueWithOpay));
    final hasOpay = ref.read(hasOpayMethodProvider);

    if (hasOpay) {
      _log.info('Opay payment method already exists');
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _log.info('Creating payment method');
      final result = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .createPaymentMethod(CreatePaymentMethodParams.opay());
      return result.fold(
        (success) {
          _log.info('Payment method created successfully');
          return state.value!;
        },
        (failure) {
          _log.error('Error creating payment method', failure);
          throw failure;
        },
      );
    });
  }

  Future<void> continueToOpay() async {
    _log.info('Attempting to continue to Opay');
    state = AsyncValue.data(
      state.value!.copyWith(currentStep: .securingYourPayment),
    );
    state = await AsyncValue.guard(() async {
      _log.info('Getting Opay payment method');
      final opayPaymentMethod = ref.read(opayMethodProvider);
      await _createCharge(opayPaymentMethod!);
      return state.value!;
    });
  }

  Future<String> _generateUSSDCode(Bank bank) async {
    state = await AsyncValue.guard(() async {
      if (state.value!.ongoingCharge != null) {
        _log.info('Cancelling previous ongoing transaction');
        await cancelTransaction(state.value!.ongoingCharge!.id);
        state = AsyncData(state.value!.copyWith(ongoingCharge: null));
      }
      _log.info('Getting bank ussd payment method');
      final hasBankUSSD = ref.read(hasBankUSSDMethodProvider(bank.code));
      PaymentMethod? bankUSSDPaymentMethod;
      if (!hasBankUSSD) {
        final createPaymentMethodResult = await ref
            .read(flutterwaveUseCaseProvider.notifier)
            .createPaymentMethod(
              CreatePaymentMethodParams.ussd(accountBankCode: bank.code),
            );
        createPaymentMethodResult.fold(
          (paymentMethod) {
            bankUSSDPaymentMethod = paymentMethod;
            _log.info('Payment method created successfully');
          },
          (failure) {
            _log.error('Error creating payment method', failure);
            throw failure;
          },
        );
      } else {
        bankUSSDPaymentMethod = ref.read(bankUSSDMethodProvider(bank.code));
      }

      await _createCharge(bankUSSDPaymentMethod!);
      return state.value!;
    });
    return state.value!.ongoingCharge!.action.mapOrNull(
          displayInstruction: (instruction) => instruction.note,
        ) ??
        '';
  }

  Future<void> _generateVirtualAccount() async {
    state = await AsyncValue.guard(() async {
      _log.info('Generating virtual account');
      final result = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .initiatePayWithBankTransfer(state.value!.agreement);

      if (result.isError()) {
        _log.error(
          'Error generating virtual account',
          result.exceptionOrNull(),
        );
        throw result.exceptionOrNull()!;
      }
      return state.value!.copyWith(ongoingVirtualAccount: result.getOrThrow());
    });
  }

  Future<void> securePaymentWithNewCard(
    String cardNumber,
    String expiryMonth,
    String expiryYear,
    String cvv, {
    required bool saveCard,
  }) async {
    state = AsyncData(state.value!.copyWith(currentStep: .securingYourPayment));
    state = await AsyncValue.guard(() async {
      _log.info('Creating payment method');
      final createPaymentMethodResult = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .createPaymentMethod(
            CreatePaymentMethodParams.card(
              cardNumber: cardNumber,
              expiryMonth: expiryMonth,
              expiryYear: expiryYear,
              cvv: cvv,
            ),
            save: saveCard,
          );
      if (createPaymentMethodResult.isError()) {
        _log.error(
          'Error creating payment method',
          createPaymentMethodResult.exceptionOrNull(),
        );
        throw createPaymentMethodResult.exceptionOrNull()!;
      }
      final paymentMethod = createPaymentMethodResult.getOrThrow();
      await _createCharge(paymentMethod);
      return state.value!;
    });
  }

  Future<void> securePaymentWithSavedCard(PaymentMethod paymentMethod) async {
    state = AsyncData(state.value!.copyWith(currentStep: .securingYourPayment));
    state = await AsyncValue.guard(() async {
      await _createCharge(paymentMethod);
      return state.value!;
    });
  }

  Future<void> _removeCard(String paymentMethodId) async {
    state = await AsyncValue.guard(() async {
      _log.info('Removing payment method');
      final user = ref.read(userProvider);
      final result = await ref
          .read(userUseCaseProvider.notifier)
          .updateUserProfile(
            user.value!.copyWith(
              flutterwavePaymentMethodIds: user
                  .value!
                  .flutterwavePaymentMethodIds
                  .where(
                    (flutterwavePaymentMethodId) =>
                        flutterwavePaymentMethodId != paymentMethodId,
                  )
                  .toList(),
            ),
          );
      return await result.fold(
        (user) {
          _log.info('Payment method removed successfully');
          return state.value!;
        },
        (failure) {
          _log.error('Error removing payment method', failure);
          throw failure;
        },
      );
    });
  }

  Future<void> _createCharge(PaymentMethod paymentMethod) async {
    _log.info('Attempting to create charge');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _log.info('Creating charge');
      final result = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .createCharge(
            agreement: state.value!.agreement,
            paymentMethod: paymentMethod,
          );
      await result.fold(
        (charge) async {
          _log.info('Charge created successfully');
          state = AsyncData(state.value!.copyWith(ongoingCharge: charge));
          _log.info('Handling charge next action');
          await charge.action.when(
            none: () {
              _log.info('No action required');
              verifyTransaction();
            },
            redirect: (String url) {
              _log.info('Redirecting to $url');
              state = AsyncData(
                state.value!.copyWith(
                  currentStep: PaymentOrchestratorStep.authorizing,
                ),
              );
            },
            otp: () {
              _log.info('OTP required');
            },
            pin: () {
              _log.info('PIN required');
            },
            bankTransfer:
                (String accountNumber, String bankName, DateTime? expiry) {},
            qrCode: (String imageUrl) {},
            displayInstruction: (String note) {},
          );
        },
        (failure) {
          _log.error('Error creating charge', failure);
          throw failure;
        },
      );
      return state.value!;
    });
  }

  Future<PaymentOrchestratorState> _verifyChargeTransaction() async {
    _log.info('Attempting to verify charge transaction');
    final chargeResult = await ref
        .read(flutterwaveUseCaseProvider.notifier)
        .getCharge(state.value!.ongoingCharge!.id);
    final charge = chargeResult.getOrThrow();
    final transactionResult = await ref
        .read(transactionUseCaseProvider.notifier)
        .getTransactionByFlutterwaveId(charge.id);
    final transactionOption = transactionResult.getOrThrow();

    if (transactionOption.isNone()) {
      throw Exception("Transaction record missing");
    }
    final transaction = transactionOption.toNullable()!;

    if (transaction.status == .successful) {
      _log.info('Transaction already marked successful (likely by webhook)');

      // Just refresh the agreement to get the latest state from the backend
      final updatedAgreement = await _fetchAgreement(state.value!.agreement.id!);
      return state.value!.copyWith(agreement: updatedAgreement);
    }

    switch (charge.status) {
      case ChargeStatus.succeeded:
        if (charge.amount < transaction.amount) {
          throw Exception("Amount mismatch");
        }
        await ref
            .read(transactionUseCaseProvider.notifier)
            .updateTransaction(transaction.copyWith(status: .successful))
            .then((r) => r.getOrThrow());
        final updatedAgreement = await ref
            .read(agreementUseCaseProvider.notifier)
            .markAgreementAsFunded(charge.agreementId)
            .then((r) => r.getOrThrow());
        return state.value!.copyWith(
          // currentStep: .paymentSecuredSuccessfully,
          agreement: updatedAgreement,
        );
      case ChargeStatus.pending:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ChargeStatus.failed:
        _log.warn('Transaction ${charge.status.name}');
        await ref
            .read(transactionUseCaseProvider.notifier)
            .updateTransaction(transaction.copyWith(status: .failed))
            .then((r) => r.getOrThrow());
        return state.value!.copyWith(currentStep: .paymentNotSecured);
      case ChargeStatus.voided:
        _log.warn('Transaction ${charge.status.name}');
        await ref
            .read(transactionUseCaseProvider.notifier)
            .updateTransaction(transaction.copyWith(status: .cancelled))
            .then((r) => r.getOrThrow());
        return state.value!.copyWith(currentStep: .paymentNotSecured);
      case ChargeStatus.unknown:
        _log.error('Unknown charge status received');
        throw Exception("Received unknown transaction status from provider");
    }
  }

  Future<PaymentOrchestratorState> _verifyVirtualAccountTransaction() async {
    /// TODO: I need to come back and have a look at this thing when flutterwave is life
    /// And also do not forget to add the IDEMPOTENCY CHECK in case the webhook changed it to successful first
    _log.info('Attempting to verify virtual account transaction');
    final listChargesResult = await ref
        .read(flutterwaveUseCaseProvider.notifier)
        .listCharges(
          ListChargesParams(
            virtualAccountId: state.value!.ongoingVirtualAccount!.id,
          ),
        );
    final charges = listChargesResult.getOrThrow();

    /// TODO: I need to add what to do when there a no charges (yet)
    _log.info('Found ${charges.length} charges');
    final transactionOption =
        (await ref
                .read(transactionUseCaseProvider.notifier)
                .getTransactionByFlutterwaveId(
                  state.value!.ongoingVirtualAccount!.id,
                ))
            .getOrThrow();
    if (transactionOption.isNone()) {
      throw Exception("Transaction record missing");
    }
    final transaction = transactionOption.toNullable()!;
    final succeededCharges = charges.where(
      (charge) => charge.status == .succeeded,
    );
    _log.info('Found ${succeededCharges.length} succeeded charges');
    final totalAmount = succeededCharges.fold(
      0.0,
      (sum, charge) => sum + charge.amount,
    );
    if (totalAmount < transaction.amount) {
      /// TODO: I need to add what to do when the total money hasn't been sent (yet)
      _log.info(
        'Amount mismatch - expected: ${transaction.amount}, actual: $totalAmount',
      );
      throw Exception("Amount mismatch");
    } else {
      await ref
          .read(transactionUseCaseProvider.notifier)
          .updateTransaction(transaction.copyWith(status: .successful))
          .then((r) => r.getOrThrow());
      final updatedAgreement = await ref
          .read(agreementUseCaseProvider.notifier)
          .markAgreementAsFunded(state.value!.agreement.id!)
          .then((r) => r.getOrThrow());
      return state.value!.copyWith(
        // currentStep: .paymentSecuredSuccessfully,
        agreement: updatedAgreement,
      );
    }
  }

  Future<void> verifyTransaction() async {
    state = AsyncValue.data(
      state.value!.copyWith(currentStep: .waitingForConfirmation),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value!.ongoingCharge != null) {
        return await _verifyChargeTransaction();
      } else if (state.value!.ongoingVirtualAccount != null) {
        return await _verifyVirtualAccountTransaction();
      } else {
        _log.error('No ongoing transaction');
        throw Exception("No ongoing transaction");
      }
    });
  }

  Future<void> cancelAgreement() async {
    if (state.value!.currentStep != PaymentOrchestratorStep.paymentNotSecured) {
      state = AsyncData(state.value!.copyWith(currentStep: .paymentNotSecured));
      _log.info('Attempting to cancel ongoing transaction');
      if (state.value!.ongoingCharge != null) {
        _log.info('Cancelling ongoing transaction');
        if (state.value!.currentStep == .payWithUSSD) {
          await cancelTransaction(state.value!.ongoingCharge!.id);
        }
      }
      if (state.value!.ongoingVirtualAccount != null) {
        if (state.value!.currentStep == .payWithBankTransfer) {
          _log.info('Cancelling transaction');
          await cancelTransaction(state.value!.ongoingVirtualAccount!.id);
        }
      }
    }
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _log.info('Cancelling agreement');
      if (state.value!.agreement.initiatorRole == .sender) {
        _log.info('Initiator is sender, cancelling agreement');
        final result = await ref
            .read(agreementUseCaseProvider.notifier)
            .updateAgreement(
              state.value!.agreement.copyWith(status: .cancelled),
            );
        return result.fold(
          (updatedAgreement) {
            return state.value!.copyWith(agreement: updatedAgreement);
          },
          (failure) {
            throw failure;
          },
        );
      } else {
        _log.info('Initiator is recipient, cancelling transaction');
        throw UnimplementedError();
      }
    });
  }

  Future<void> changePaymentMethod() async {
    final oldState = state.value!;
    state = AsyncData(
      state.value!.copyWith(
        currentStep: .choosePaymentMethod,
        ongoingCharge: null,
        ongoingVirtualAccount: null,
      ),
    );
    _log.info('Attempting to change payment method');
    if (oldState.ongoingCharge != null) {
      _log.info('Cancelling ongoing transaction');
      if (oldState.currentStep == .payWithUSSD) {
        await cancelTransaction(oldState.ongoingCharge!.id);
      }
    }
    if (oldState.ongoingVirtualAccount != null) {
      if (oldState.currentStep == .payWithBankTransfer) {
        _log.info('Cancelling transaction');
        await cancelTransaction(oldState.ongoingVirtualAccount!.id);
      }
    }
  }

  void retryPayment() async {
    state = AsyncData(
      state.value!.copyWith(
        currentStep: .choosePaymentMethod,
        ongoingCharge: null,
        ongoingVirtualAccount: null,
      ),
    );
  }

  Future<void> cancelTransaction(String flutterwaveId) async {
    _log.info('Cancelling transaction');
    final transactionResult = await ref
        .read(transactionUseCaseProvider.notifier)
        .getTransactionByFlutterwaveId(flutterwaveId);
    final transactionOption = transactionResult.getOrThrow();

    if (transactionOption.isNone()) {
      throw Exception("Transaction record missing");
    }
    final transaction = transactionOption.toNullable()!;
    await ref
        .read(transactionUseCaseProvider.notifier)
        .updateTransaction(transaction.copyWith(status: .cancelled))
        .then((r) => r.getOrThrow());
  }

  void goTo(PaymentOrchestratorStep step) {
    state = AsyncData(state.value!.copyWith(currentStep: step));
  }
}
