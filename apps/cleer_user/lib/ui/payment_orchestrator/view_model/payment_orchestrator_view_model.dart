import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/domain/use_cases/flutterwave/flutterwave_use_case.dart';
import 'package:cleer/domain/use_cases/transaction/transaction_use_case.dart';
import 'package:cleer/domain/use_cases/user/user_use_case.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/payment_method/payment_method.dart';
import 'package:cleer_core/models/transaction/transaction_enums.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/payment_orchestrator/state/payment_orchestrator_state.dart';
import 'package:collection/collection.dart';
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

    // Real-time Agreement Stream Listener
    ref.listen(agreementDetailsProvider(agreementId), (previous, next) {
      if (next.hasValue && next.value != null) {
        final updatedAgreement = next.value!;
        _log.info('📡 Real-time agreement update received: ${updatedAgreement.status}');
        if (state.hasValue && state.value != null) {
          state = AsyncData(state.value!.copyWith(agreement: updatedAgreement));
        }
      }
    });

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
      final savedMethods = await ref.read(
        flutterwaveSavedPaymentMethodsProvider.future,
      );

      final opayPaymentMethod = savedMethods.firstWhereOrNull(
        (m) => m.type == PaymentMethodType.opay,
      );

      if (opayPaymentMethod == null) {
        throw Exception("Opay payment method not found after creation.");
      }
      await _createCharge(opayPaymentMethod);
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
      final user = ref.read(userProfileProvider);
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
          await _handleChargeAction(charge);
        },
        (failure) {
          _log.error('Error creating charge', failure);
          throw failure;
        },
      );
      return state.value!;
    });
  }

  Future<void> _handleChargeAction(Charge charge) async {
    state = AsyncData(state.value!.copyWith(ongoingCharge: charge));
    _log.info('Handling charge next action: ${charge.action}');

    await charge.action.when(
      none: () async {
        _log.info('No action required. Verifying transaction...');
        await verifyTransaction();
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
        state = AsyncData(
          state.value!.copyWith(
            currentStep: PaymentOrchestratorStep.enterCardOtp,
          ),
        );
      },
      pin: () {
        _log.info('PIN required');
        state = AsyncData(
          state.value!.copyWith(
            currentStep: PaymentOrchestratorStep.enterCardPin,
          ),
        );
      },
      bankTransfer:
          (String accountNumber, String bankName, DateTime? expiry) {},
      qrCode: (String imageUrl) {},
      displayInstruction: (String note) {},
    );
  }

  Future<void> submitCardPin(String pin) async {
    final chargeId = state.value?.ongoingCharge?.id;
    if (chargeId == null) {
      _log.error('No ongoing charge ID to submit PIN for');
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        currentStep: PaymentOrchestratorStep.securingYourPayment,
      ),
    );
    state = await AsyncValue.guard(() async {
      _log.info('Submitting PIN for charge $chargeId');
      final result = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .updateCharge(
            chargeId: chargeId,
            params: UpdateChargeParams.pin(pin: pin),
          );
      return await result.fold(
        (updatedCharge) async {
          _log.info('PIN update succeeded, handling next action');
          await _handleChargeAction(updatedCharge);
          return state.value!;
        },
        (failure) {
          _log.error('Error submitting PIN', failure);
          throw failure;
        },
      );
    });
  }

  Future<void> submitCardOtp(String otp) async {
    final chargeId = state.value?.ongoingCharge?.id;
    if (chargeId == null) {
      _log.error('No ongoing charge ID to submit OTP for');
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        currentStep: PaymentOrchestratorStep.securingYourPayment,
      ),
    );
    state = await AsyncValue.guard(() async {
      _log.info('Submitting OTP for charge $chargeId');
      final result = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .updateCharge(
            chargeId: chargeId,
            params: UpdateChargeParams.otp(otp: otp),
          );
      return await result.fold(
        (updatedCharge) async {
          _log.info('OTP update succeeded, handling next action');
          await _handleChargeAction(updatedCharge);
          return state.value!;
        },
        (failure) {
          _log.error('Error submitting OTP', failure);
          throw failure;
        },
      );
    });
  }

  Future<PaymentOrchestratorState> _verifyChargeTransaction() async {
    _log.info('Attempting to verify charge transaction');

    final chargeId = state.value!.ongoingCharge!.id;
    const maxRetries = 30;
    const retryDelay = Duration(seconds: 3);

    Charge? charge;
    Transaction? transaction;

    for (int i = 0; i < maxRetries; i++) {
      final chargeResult = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .getCharge(chargeId);

      if (chargeResult.isSuccess()) {
        charge = chargeResult.getOrThrow();

        final transactionResult = await ref
            .read(transactionUseCaseProvider.notifier)
            .getTransactionByFlutterwaveId(charge.id);

        final transactionOption = transactionResult.getOrNull();
        if (transactionOption != null && transactionOption.isSome()) {
          transaction = transactionOption.toNullable()!;

          if (transaction.isTerminal) {
            _log.info(
              'Transaction already in terminal state: ${transaction.status.name}',
            );

            if (transaction.status == TransactionStatus.successful) {
              final updatedAgreement = await _fetchAgreement(
                state.value!.agreement.id!,
              );
              return state.value!.copyWith(agreement: updatedAgreement);
            } else {
              return state.value!.copyWith(
                currentStep: PaymentOrchestratorStep.paymentNotSecured,
              );
            }
          }
        }

        if (charge.status != ChargeStatus.pending) {
          _log.info('Charge status resolved to: ${charge.status.name}');
          break;
        }
      }

      if (i < maxRetries - 1) {
        _log.info('Charge is pending. Retrying in 3s... (Attempt ${i + 1}/$maxRetries)');
        await Future.delayed(retryDelay);
      }
    }

    if (charge == null || transaction == null) {
      throw Exception("Transaction record or charge details missing");
    }

    switch (charge.status) {
      case ChargeStatus.succeeded:
        if (charge.amount < transaction.amount) {
          _log.error(
            'Amount mismatch - expected: ${transaction.amount}, got: ${charge.amount}',
          );
          throw Exception("Amount mismatch");
        }

        await ref
            .read(transactionUseCaseProvider.notifier)
            .updateTransaction(transaction.copyWith(status: TransactionStatus.successful))
            .then((r) => r.getOrThrow());

        final updatedAgreement = await ref
            .read(agreementUseCaseProvider.notifier)
            .processFundingSuccess(charge.agreementId)
            .then((r) => r.getOrThrow());

        return state.value!.copyWith(agreement: updatedAgreement);

      case ChargeStatus.pending:
        _log.info('Charge remains pending after retries.');
        return state.value!.copyWith(
          currentStep: PaymentOrchestratorStep.waitingForConfirmation,
        );

      case ChargeStatus.failed:
        _log.warn('Transaction failed at processor');
        await ref
            .read(transactionUseCaseProvider.notifier)
            .updateTransaction(transaction.copyWith(status: TransactionStatus.failed))
            .then((r) => r.getOrThrow());
        return state.value!.copyWith(
          currentStep: PaymentOrchestratorStep.paymentNotSecured,
        );

      case ChargeStatus.voided:
        _log.warn('Transaction voided or cancelled');
        await ref
            .read(transactionUseCaseProvider.notifier)
            .updateTransaction(transaction.copyWith(status: TransactionStatus.cancelled))
            .then((r) => r.getOrThrow());
        return state.value!.copyWith(
          currentStep: PaymentOrchestratorStep.paymentNotSecured,
        );

      case ChargeStatus.unknown:
        _log.error('Unknown charge status received');
        throw Exception("Received unknown transaction status from provider");
    }
  }

  Future<PaymentOrchestratorState> _verifyVirtualAccountTransaction() async {
    _log.info('Attempting to verify virtual account transaction');

    final virtualAccountId = state.value!.ongoingVirtualAccount!.id;
    final transactionOption =
        (await ref
                .read(transactionUseCaseProvider.notifier)
                .getTransactionByFlutterwaveId(virtualAccountId))
            .getOrThrow();

    if (transactionOption.isNone()) {
      throw Exception("Transaction record missing");
    }
    final transaction = transactionOption.toNullable()!;

    if (transaction.isTerminal) {
      _log.info(
        'Bank transfer transaction already in terminal state: ${transaction.status.name}',
      );
      if (transaction.status == TransactionStatus.successful) {
        final updatedAgreement = await _fetchAgreement(
          state.value!.agreement.id!,
        );
        return state.value!.copyWith(agreement: updatedAgreement);
      } else {
        return state.value!.copyWith(
          currentStep: PaymentOrchestratorStep.paymentNotSecured,
        );
      }
    }

    const maxRetries = 30;
    const retryDelay = Duration(seconds: 3);

    Charge? charge;

    for (int i = 0; i < maxRetries; i++) {
      final listChargesResult = await ref
          .read(flutterwaveUseCaseProvider.notifier)
          .listCharges(ListChargesParams(virtualAccountId: virtualAccountId));

      if (listChargesResult.isSuccess()) {
        final charges = listChargesResult.getOrThrow();
        if (charges.isNotEmpty) {
          charge = charges.first;
          if (charge.status != ChargeStatus.pending) {
            _log.info('Bank transfer charge detected with status: ${charge.status.name}');
            break;
          }
        }
      }

      if (i < maxRetries - 1) {
        _log.info('Bank transfer charge not detected yet. Retrying in 3s... (Attempt ${i + 1}/$maxRetries)');
        await Future.delayed(retryDelay);
      }
    }

    if (charge == null) {
      _log.info('No incoming transfer charges found after retries.');
      return state.value!.copyWith(
        currentStep: PaymentOrchestratorStep.payWithBankTransfer,
      );
    }

    if (charge.status == ChargeStatus.succeeded &&
        charge.amount >= transaction.amount) {
      // Update transaction status to successful and replace the Virtual Account ID (van_...)
      // with the actual Flutterwave Charge ID (chg_...) required for refunds.
      await ref
          .read(transactionUseCaseProvider.notifier)
          .updateTransaction(
            transaction.copyWith(
              status: TransactionStatus.successful,
              flutterwaveId: charge.id,
            ),
          )
          .then((r) => r.getOrThrow());

      final updatedAgreement = await ref
          .read(agreementUseCaseProvider.notifier)
          .processFundingSuccess(state.value!.agreement.id!)
          .then((r) => r.getOrThrow());

      return state.value!.copyWith(agreement: updatedAgreement);
    }

    _log.warn('Bank transfer failed or underpaid. Marking transaction failed.');

    await ref
        .read(transactionUseCaseProvider.notifier)
        .updateTransaction(transaction.copyWith(status: TransactionStatus.failed))
        .then((r) => r.getOrThrow());

    return state.value!.copyWith(
      currentStep: PaymentOrchestratorStep.paymentNotSecured,
    );
  }

  Future<void> verifyTransaction() async {
    final keepAliveLink = ref.keepAlive();
    try {
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
    } finally {
      keepAliveLink.close();
    }
  }

  Future<void> _cleanupActivePayments(
    PaymentOrchestratorState stateToUse,
  ) async {
    final charge = stateToUse.ongoingCharge;
    final virtualAccount = stateToUse.ongoingVirtualAccount;
    final currentStep = stateToUse.currentStep;

    // Kill USSD/Card Charge
    if (charge != null && currentStep == PaymentOrchestratorStep.payWithUSSD) {
      await cancelTransaction(charge.id);
    }

    // Kill Bank Transfer
    if (virtualAccount != null &&
        currentStep == PaymentOrchestratorStep.payWithBankTransfer) {
      await cancelTransaction(virtualAccount.id);
    }
  }

  Future<void> handleRejectionFromPaymentFlow() async {
    if (state.value!.currentStep != PaymentOrchestratorStep.paymentNotSecured) {
      state = AsyncData(state.value!.copyWith(currentStep: .paymentNotSecured));
      _log.info('Attempting to cancel ongoing transaction');
      await _cleanupActivePayments(state.value!);
      // if (state.value!.ongoingCharge != null) {
      //   _log.info('Cancelling ongoing transaction');
      //   if (state.value!.currentStep == .payWithUSSD) {
      //     await cancelTransaction(state.value!.ongoingCharge!.id);
      //   }
      // }
      // if (state.value!.ongoingVirtualAccount != null) {
      //   if (state.value!.currentStep == .payWithBankTransfer) {
      //     _log.info('Cancelling transaction');
      //     await cancelTransaction(state.value!.ongoingVirtualAccount!.id);
      //   }
      // }
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
        _log.info('Initiator is recipient, declining (rejecting) agreement');
        final result = await ref
            .read(agreementUseCaseProvider.notifier)
            .updateAgreement(
              state.value!.agreement.copyWith(status: .rejected),
            );
        return result.fold(
          (updatedAgreement) {
            return state.value!.copyWith(agreement: updatedAgreement);
          },
          (failure) {
            throw failure;
          },
        );
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
        selectedUSSDBank: null,
      ),
    );
    _log.info('Attempting to change payment method');
    await _cleanupActivePayments(oldState);
  }

  void retryPayment() async {
    state = AsyncData(
      state.value!.copyWith(
        currentStep: .choosePaymentMethod,
        ongoingCharge: null,
        ongoingVirtualAccount: null,
        selectedUSSDBank: null,
      ),
    );
  }

  void selectUSSDBank(Bank bank) {
    if (state.hasValue && state.value != null) {
      state = AsyncData(state.value!.copyWith(selectedUSSDBank: bank));
    }
    generateUSSDCode.clearErrors();
    generateUSSDCode.runAsync(bank);
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
