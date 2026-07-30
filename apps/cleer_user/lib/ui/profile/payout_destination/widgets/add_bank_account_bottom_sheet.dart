import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer/ui/core/extensions/error_ui_extensions.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer_ui/widgets/form_error.dart';
import 'package:cleer/ui/profile/payout_destination/view_model/payout_destination_view_model.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class AddBankAccountBottomSheet extends HookConsumerWidget {
  const AddBankAccountBottomSheet({super.key});

  static Future<PayoutDestination?> show(BuildContext context) =>
      CustomBottomSheet.show<PayoutDestination>(
        context: context,
        isDismissible: true,
        child: const AddBankAccountBottomSheet(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    ProviderListenable;
    ref.watch(getBanksProvider(CountryCode.NG));

    ref.watch(payoutDestinationViewModelProvider);
    final viewModel = ref.read(payoutDestinationViewModelProvider.notifier);
    final resolveAccountCommand =
        viewModel.resolveAccountForPayoutDestinationCommand;
    final createPayoutDestinationCommand =
        viewModel.createPayoutDestinationCommand;

    final ValueNotifier<Bank?> selectedBank = useState<Bank?>(null);
    final bankController = useTextEditingController(
      text: selectedBank.value?.name,
    );

    final TextEditingController accountNumberController =
        useTextEditingController();
    useListenable(accountNumberController);

    bool isFormValid =
        (selectedBank.value != null) &&
        (accountNumberController.text.length == 10);

    useEffect(() {
      createPayoutDestinationCommand.listen((
        PayoutDestination? payoutDestination,
        _,
      ) {
        if (payoutDestination != null) {
          if (context.mounted) {
            context.pop(payoutDestination);
          }
        }
      });
      createPayoutDestinationCommand.errors.listen((error, _) {
        if (error != null) {
          debugPrint(
            "Command Error: ${createPayoutDestinationCommand.errors.value?.error}",
          );
          if (context.mounted) {
            context.pop();
          }
        }
      });
      return null;
    }, [createPayoutDestinationCommand]);

    useEffect(() {
      // Feed the live text to the ViewModel so the loop knows what to look for
      viewModel.updateResolutionTargets(
        selectedBank.value?.code,
        accountNumberController.text,
      );

      if (isFormValid) {
        resolveAccountCommand.clearErrors();
        // The loop inside handles the 500ms delay, so we run instantly here
        resolveAccountCommand.run(
          ResolveAccountParams(
            bankCode: selectedBank.value!.code,
            accountNumber: accountNumberController.text,
          ),
        );
      } else {
        // Eager reset if they hit backspace
        resolveAccountCommand.clearErrors();
        resolveAccountCommand.value = '';
        createPayoutDestinationCommand.value = null;
      }
      return null;
    }, [isFormValid, selectedBank.value, accountNumberController.text]);

    // useEffect(() {
    //   resolveAccountCommand.clearErrors();
    //   // createPayoutDestinationCommand.clearErrors();
    //   if (isFormValid) {
    //     resolveAccountCommand.run(
    //       ResolveAccountParams(
    //         bankCode: selectedBank.value!.code,
    //         accountNumber: accountNumberController.text,
    //       ),
    //     );
    //   } else {
    //     resolveAccountCommand.value = '';
    //     createPayoutDestinationCommand.value = null;
    //   }
    //   return null;
    // }, [isFormValid, selectedBank.value, accountNumberController.text]);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text(l10n.addBankAccount, style: context.typo.headlineSmall),
              Gap(Dimens.spacing.sp24),
              ValueListenableBuilder(
                valueListenable:
                    viewModel.resolveAccountForPayoutDestinationCommand.errors,
                builder: (BuildContext context, error, Widget? child) {
                  final isOffline = ref.watch(isOfflineProvider);
                  if (isOffline) return const SizedBox.shrink();
                  return FormError(
                    hasError: error != null,
                    errorMessage: (error?.error is UnknownDataFailure)
                        ? (error?.error as UnknownDataFailure).message
                        : error?.error.toString(),
                  );
                },
              ),
              CustomTextFormField(
                controller: bankController,
                labelText: l10n.selectBank,
                readOnly: true,
                onTap: () => _showBankPickerBottomSheet(
                  context,
                  selectedBank,
                  bankController,
                ),
                suffixIcon: IconButton(
                  onPressed: () => _showBankPickerBottomSheet(
                    context,
                    selectedBank,
                    bankController,
                  ),
                  icon: PhosphorIcon(
                    PhosphorIcons.caretDown(),
                    color: context.color.blue700,
                  ),
                ),
              ),
              Gap(Dimens.spacing.sp16),
              CustomTextFormField(
                controller: accountNumberController,
                labelText: l10n.accountNumber,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputType: .number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.fieldRequired('account number');
                  }
                  if (value.length != 10) {
                    return l10n.enterAValid10DigitsAccountNumber;
                  }
                  return null;
                },
              ),
              Consumer(
                builder: (context, ref, _) {
                  final isOffline = ref.watch(isOfflineProvider);
                  if (!isOffline) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: Dimens.padding.p16),
                    child: AppErrorState(
                      isOffline: true,
                      onRetry: () {},
                      variant: AppErrorStateVariant.minimal,
                      message:
                          l10n.pleaseCheckYourInternetConnectionAndTryAgain,
                    ),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: resolveAccountCommand.isRunning,
                builder: (BuildContext context, bool isRunning, Widget? child) {
                  if (!isFormValid) {
                    return const SizedBox.shrink();
                  }

                  if (isRunning) {
                    return Padding(
                      padding: EdgeInsets.only(top: Dimens.padding.p16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ValueListenableBuilder(
                    valueListenable: resolveAccountCommand,
                    builder:
                        (
                          BuildContext context,
                          String resolveAccountName,
                          Widget? child,
                        ) {
                          if (resolveAccountName.isEmpty) {
                            return SizedBox.shrink();
                          }
                          return Column(
                            mainAxisSize: .min,
                            children: [
                              Gap(Dimens.spacing.sp16),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: Dimens.padding.p2,
                                    ),
                                    child: PhosphorIcon(
                                      PhosphorIcons.checkCircle(.fill),
                                      color: Color(0xFF1A8244),
                                      size: Dimens.size.s16,
                                    ),
                                  ),
                                  Gap(Dimens.spacing.sp8),
                                  Text(
                                    resolveAccountName,
                                    style: context.typo.bodyMedium.copyWith(
                                      color: context.color.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                  );
                },
              ),
              Gap(Dimens.spacing.sp32),
              Container(
                padding: .all(Dimens.padding.p8),
                decoration: BoxDecoration(
                  color: context.color.grayComponent,
                  borderRadius: BorderRadius.circular(Dimens.radius.r8),
                ),
                child: Row(
                  crossAxisAlignment: .start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: Dimens.padding.p3),
                      child: PhosphorIcon(
                        PhosphorIcons.info(),
                        color: context.color.grey800,
                      ),
                    ),
                    Gap(Dimens.spacing.sp12),
                    Expanded(
                      child: Text(
                        l10n.fundsAreOnlyPaidOutToVerifiedBankAccountsInYourName,
                        style: context.typo.bodyMedium.copyWith(
                          color: context.color.grey800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(Dimens.spacing.sp40),
              ValueListenableBuilder(
                valueListenable: resolveAccountCommand,
                builder:
                    (
                      BuildContext context,
                      String resolveAccountName,
                      Widget? child,
                    ) {
                      return PrimaryButton(
                        onPressed:
                            /// TODO: For now just let users be ale to create payout destination, come back and fix this when flutterwave is active
                            (isFormValid && resolveAccountName.isEmpty)
                            // (isFormValid && resolveAccountName.isNotEmpty)
                            ? () => createPayoutDestinationCommand.run(
                                PayoutDestination(
                                  accountNumber: accountNumberController.text,
                                  bankCode: selectedBank.value!.code,
                                  bankName: selectedBank.value!.name,
                                  accountName: resolveAccountName,
                                ),
                              )
                            : null,
                        child: Text(l10n.addAccount),
                      );
                    },
              ),
              Gap(Dimens.spacing.sp20),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: createPayoutDestinationCommand.isRunning,
          builder: (BuildContext context, bool isRunning, Widget? child) {
            if (isRunning) {
              return Positioned.fill(
                child: Material(
                  color: context.color.background,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            return ValueListenableBuilder(
              valueListenable: createPayoutDestinationCommand,
              builder:
                  (
                    BuildContext context,
                    PayoutDestination? payoutDestination,
                    Widget? child,
                  ) {
                    if (payoutDestination != null) {
                      return Positioned.fill(
                        child: Material(
                          color: context.color.background,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
            );
          },
        ),
      ],
    );
  }

  void _showBankPickerBottomSheet(
    BuildContext context,
    ValueNotifier<Bank?> selectedBank,
    TextEditingController bankController,
  ) =>
      BankPickerBottomSheet.show(
        context,
        child: Consumer(
          builder: (context, ref, _) {
            // Watch your app's specific feature provider here
            final banksAsync = ref.watch(getBanksProvider(.NG));

            return BankPickerBottomSheet(
              banks: banksAsync.value ?? [],
              isLoading: banksAsync.isLoading,
              errorState: banksAsync.hasError
                  ? banksAsync.error!.toErrorState(
                      ref,
                      variant: .card,
                      onRetry: () => ref.invalidate(getBanksProvider(.NG)),
                    )
                  : null,
            );
          },
        ),
      ).then((bank) {
        if (bank != null) {
          selectedBank.value = bank;
          bankController.text = bank.name;
        }
      });
}
