import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/ui/agreements/create_agreement/state/create_agreement_state.dart';
import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:cleer_core/models/bank/bank.dart';
import 'package:cleer_core/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/providers/payout_destination/payout_destination_provider.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/agreement_numpad_overlay.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/agreement_split_milestones_overlay.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/disbursement_type_selector.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/linked_bank_accounts_bottom_sheet.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/recipient_identity_tile.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/add_bank_account_trigger.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/payout_destination_card.dart';
import 'package:cleer_ui/widgets/menu_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementSetupStep extends HookConsumerWidget {
  const AgreementSetupStep({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(createAgreementViewModelProvider(type));
    final viewModel = ref.read(createAgreementViewModelProvider(type).notifier);

    String formattedAmount =
        state.value?.formData.amount != null &&
            state.value!.formData.amount.isNotEmpty
        ? NumberFormat(
            '#,###.##',
          ).format(double.parse(state.value!.formData.amount))
        : '';

    final TextEditingController amountController = useTextEditingController(
      text: formattedAmount,
    );

    final ValueNotifier<Bank?> selectedBank = useState<Bank?>(
      state.value?.formData.recipientBank,
    );
    final bankController = useTextEditingController(
      text: selectedBank.value?.name,
    );
    final TextEditingController accountNumberController =
        useTextEditingController(
          text: state.value?.formData.recipientAccountNumber,
        );

    final selectedPayoutDestination = useState<PayoutDestination?>(null);

    final ValueNotifier<DisbursementType?> selectedDisbursementType =
        useState<DisbursementType?>(state.value?.formData.disbursementType);

    useEffect(() {
      bankController.text = selectedBank.value?.name ?? '';
      return null;
    }, [selectedBank.value]);

    useEffect(() {
      if (amountController.text == '') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAgreementNumpadOverlay(
            context,
            amountController,
            isAutomaticallyOpened: true,
            ref: ref,
          );
        });
      }
      return null;
    }, [amountController]);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.onFormChanged(
            state.value!.formData.copyWith(
              amount: amountController.text.replaceAll(',', ''),
              recipientBank: selectedBank.value,
              recipientAccountNumber: accountNumberController.text,
            ),
          );
        });
        return null;
      },
      [amountController.text, selectedBank.value, accountNumberController.text],
    );

    useEffect(() {
      if (selectedPayoutDestination.value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.onFormChanged(
            state.value!.formData.copyWith(
              payoutDestination: selectedPayoutDestination.value,
            ),
          );
        });
      }
      return null;
    }, [selectedPayoutDestination.value]);

    bool isRecipientDetailsValid =
        selectedBank.value != null && accountNumberController.text.length == 10;

    final resolveRecipientDetailsCommand =
        viewModel.resolveRecipientDetailsCommand;

    // useEffect(() {
    //   // 1. Instantly clear old errors and old values the millisecond they type
    //   resolveRecipientDetailsCommand.clearErrors();
    //   resolveRecipientDetailsCommand.value = null;
    //
    //   Timer? debounceTimer;
    //
    //   if (isRecipientDetailsValid) {
    //     // Wait 500ms before hitting the API.
    //     debounceTimer = Timer(const Duration(milliseconds: 500), () {
    //       resolveRecipientDetailsCommand.run();
    //     });
    //   }
    //
    //   // Cleanup the timer
    //   return () => debounceTimer?.cancel();
    // }, [selectedBank.value, accountNumberController.text]);

    useEffect(() {
      resolveRecipientDetailsCommand.clearErrors();
      if (isRecipientDetailsValid) {
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        // viewModel.resolveRecipientDetails();
        resolveRecipientDetailsCommand.run();
        // });
      } else {
        resolveRecipientDetailsCommand.value = null;
      }
      return null;
    }, [selectedBank.value, accountNumberController.text]);

    final formData = state.value?.formData;
    final resolution = formData?.recipientResolution;

    bool isFormComplete() {
      return switch (type) {
        AgreementType.send =>
          (formData?.amount.isNotEmpty ?? false) &&
              (formData?.recipientAccountNumber.length == 10) &&
              (formData?.recipientBank != null) &&
              (formData?.disbursementType != null) &&
              (resolution != null),
        AgreementType.request =>
          (formData?.amount.isNotEmpty ?? false) &&
              (formData?.payoutDestination != null) &&
              (formData?.disbursementType != null),
      };
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;

        // If didPop is false, we are on Step 2 or 3.
        // Just move the internal state back.
        viewModel.moveStepBack();
      },
      child: Form(
        onChanged: () {
          viewModel.onFormChanged(
            state.value!.formData.copyWith(
              amount: amountController.text.replaceAll(',', ''),
              recipientBank: selectedBank.value,
              recipientAccountNumber: accountNumberController.text,
            ),
          );
        },
        child: ResponsiveLayout(
          mobile: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Dimens.of(context).edgeInsetsScreenHorizontal,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Gap(Dimens.spacing.sp12),
                    CustomTextFormField(
                      controller: amountController,
                      labelText: l10n.amount,
                      readOnly: true,
                      onTap: () => _showAgreementNumpadOverlay(
                        context,
                        amountController,
                        ref: ref,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(right: Dimens.padding.p8),
                        child: Text(
                          l10n.nairaSign,
                          style: context.typo.bodyLarge.copyWith(
                            color: context.color.grey600,
                          ),
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => _showAgreementNumpadOverlay(
                          context,
                          amountController,
                          ref: ref,
                        ),
                        icon: PhosphorIcon(
                          PhosphorIcons.numpad(),
                          color: context.color.blue700,
                        ),
                      ),
                    ),
                    Gap(Dimens.spacing.sp40),

                    _PaymentDestinationSection(
                      type: type,
                      formData: formData,
                      bankController: bankController,
                      accountNumberController: accountNumberController,
                      selectedBank: selectedBank,
                      selectedPayoutDestination: selectedPayoutDestination,
                    ),
                    Gap(Dimens.spacing.sp40),

                    _DisbursementTypeSection(
                      selectedType: selectedDisbursementType.value,
                      onChanged: (value) {
                        selectedDisbursementType.value = value;
                        viewModel.onFormChanged(
                          state.value!.formData.copyWith(
                            disbursementType: value,
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: .end,
                    children: [
                      Gap(Dimens.spacing.sp30),
                      PrimaryButton(
                        onPressed: isFormComplete()
                            ? () =>
                                  _handleNextStep(context, viewModel, formData)
                            : null,
                        child: Text(l10n.next),
                      ),
                      Gap(Dimens.spacing.sp20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          desktop: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Dimens.of(context).edgeInsetsScreenHorizontal.copyWith(
                  top: context.isTablet
                      ? Dimens.spacing.sp20
                      : Dimens.spacing.sp28,
                  bottom: Dimens.spacing.sp20,
                ),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: .centerLeft,
                    child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius: .circular(Dimens.radius.r4),
                      child: Row(
                        mainAxisSize: .min,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.arrowLeft(),
                            color: context.color.blue700,
                            size: Dimens.size.s20,
                          ),
                          Gap(Dimens.spacing.sp8),
                          Text(
                            l10n.back,
                            style: context.typo.bodyMedium.copyWith(
                              color: context.color.blue700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: Dimens.of(context).edgeInsetsScreenHorizontal,
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        flex: context.isTablet ? 421 : 572,
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.color.white,
                            borderRadius: .circular(Dimens.radius.r12),
                          ),
                          padding: .all(Dimens.padding.p12),
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              Gap(Dimens.spacing.sp12),
                              InkWell(
                                onTap: () => _showAgreementNumpadOverlay(
                                  context,
                                  amountController,
                                  ref: ref,
                                ),
                                child: Material(
                                  borderRadius: .circular(Dimens.radius.r8),
                                  color: context.color.green150,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.padding.p8,
                                      vertical: Dimens.padding.p4,
                                    ),
                                    child: Row(
                                      mainAxisSize: .min,
                                      children: [
                                        PhosphorIcon(
                                          PhosphorIcons.numpad(.duotone),
                                          color: context.color.green900,
                                          size: Dimens.size.s16,
                                        ),
                                        Gap(Dimens.spacing.sp6),
                                        Text(
                                          l10n.showNumpad,
                                          style: context.typo.bodyMedium
                                              .copyWith(
                                                fontWeight:
                                                    AppFontWeights.regular,
                                                color: context.color.green900,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Gap(Dimens.spacing.sp20),
                              _PaymentDestinationSection(
                                type: type,
                                formData: formData,
                                bankController: bankController,
                                accountNumberController:
                                    accountNumberController,
                                selectedBank: selectedBank,
                                selectedPayoutDestination:
                                    selectedPayoutDestination,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(
                        context.isTablet
                            ? Dimens.spacing.sp40
                            : Dimens.spacing.sp55,
                      ),
                      Expanded(
                        flex: context.isTablet ? 357 : 485,
                        child: Column(
                          children: [
                            _DisbursementTypeSection(
                              selectedType: selectedDisbursementType.value,
                              onChanged: (value) {
                                selectedDisbursementType.value = value;
                                viewModel.onFormChanged(
                                  state.value!.formData.copyWith(
                                    disbursementType: value,
                                  ),
                                );
                              },
                            ),
                            Gap(
                              context.isTablet
                                  ? Dimens.spacing.sp32
                                  : Dimens.spacing.sp54,
                            ),
                            PrimaryButton(
                              onPressed: isFormComplete()
                                  ? () => _handleNextStep(
                                      context,
                                      viewModel,
                                      formData,
                                    )
                                  : null,
                              child: Text(l10n.next),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAgreementNumpadOverlay(
    BuildContext context,
    TextEditingController amountController, {
    bool isAutomaticallyOpened = false,
    required WidgetRef ref,
  }) => showDialog(
    context: context,
    useRootNavigator: context.isMobile,
    fullscreenDialog: true,
    useSafeArea: false,
    animationStyle: .new(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 200),
    ),
    builder: (context) => AgreementNumpadOverlay(
      initialAmount: amountController.text.replaceAll(',', ''),
      type: type,
      onSubmitted: (value) {
        amountController.text = NumberFormat(
          '#,###.##',
        ).format(double.parse(value));
        ref
            .read(createAgreementViewModelProvider(type).notifier)
            .onFormChanged(
              ref
                  .watch(createAgreementViewModelProvider(type))
                  .value!
                  .formData
                  .copyWith(amount: value),
            );
      },
      isAutomaticallyOpened: isAutomaticallyOpened,
    ),
  );

  void _handleNextStep(
    BuildContext context,
    CreateAgreementViewModel viewModel,
    CreateAgreementFormData? formData,
  ) {
    if (formData?.disbursementType == DisbursementType.milestones) {
      showDialog(
        context: context,
        useRootNavigator: context.isMobile,
        fullscreenDialog: true,
        useSafeArea: false,
        animationStyle: AnimationStyle(
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 200),
        ),
        builder: (context) => AgreementSplitMilestonesOverlay(type: type),
      );
    } else {
      viewModel.moveToNextStep();
    }
  }
}

class _PaymentDestinationSection extends ConsumerWidget {
  const _PaymentDestinationSection({
    required this.type,
    required this.formData,
    required this.bankController,
    required this.accountNumberController,
    required this.selectedBank,
    required this.selectedPayoutDestination,
  });

  final AgreementType type;
  final CreateAgreementFormData? formData;
  final TextEditingController bankController;
  final TextEditingController accountNumberController;
  final ValueNotifier<Bank?> selectedBank;
  final ValueNotifier<PayoutDestination?> selectedPayoutDestination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        MenuSectionHeader(
          title: type == AgreementType.send
              ? l10n.recipientDetails
              : l10n.payoutDestination,
        ),
        Visibility(
          visible: type == AgreementType.send,
          replacement: Builder(
            builder: (context) {
              final userPayoutDestinationsState = ref.watch(
                userPayoutDestinationsProvider,
              );

              return userPayoutDestinationsState.when(
                data: (List<PayoutDestination> payoutDestinations) {
                  if (payoutDestinations.isEmpty) {
                    return AddBankAccountTrigger.card(
                      onResult: (payoutDestination) {
                        selectedPayoutDestination.value = payoutDestination;
                      },
                    );
                  } else {
                    if (formData?.payoutDestination != null) {
                      final payoutDestination = formData!.payoutDestination!;
                      return PayoutDestinationCard(
                        payoutDestination: payoutDestination,
                        action: GestureDetector(
                          onTap: () => _showLinkedBankAccountsBottomSheet(
                            context,
                            selectedPayoutDestination,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.change,
                            style: context.typo.bodyLink.copyWith(
                              color: context.color.blue700,
                              decorationColor: context.color.blue700,
                            ),
                          ),
                        ),
                      );
                    }
                    return Align(
                      alignment: .centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: context.color.transparent,
                          foregroundColor: context.color.blue700,
                          minimumSize: const Size(0, 0),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _showLinkedBankAccountsBottomSheet(
                          context,
                          selectedPayoutDestination,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.images.bank.image(
                              width: Dimens.size.s23,
                              height: Dimens.size.s23,
                            ),
                            Gap(Dimens.spacing.sp5),
                            Text(
                              l10n.selectPayoutDestination,
                              style: context.typo.bodyLink.copyWith(
                                color: context.color.blue700,
                                decorationColor: context.color.blue700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                error: (Object error, StackTrace stackTrace) {
                  return const SizedBox.shrink();
                },
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
          child: Column(
            mainAxisSize: .min,
            children: [
              CustomTextFormField(
                controller: bankController,
                labelText: l10n.selectBank,
                readOnly: true,
                onTap: () => _showBankPickerBottomSheet(context, selectedBank),
                suffixIcon: IconButton(
                  onPressed: () =>
                      _showBankPickerBottomSheet(context, selectedBank),
                  icon: PhosphorIcon(
                    PhosphorIcons.caretDown(),
                    color: context.color.blue700,
                  ),
                ),
              ),
              Gap(Dimens.spacing.sp20),
              CustomTextFormField(
                controller: accountNumberController,
                labelText: l10n.accountNumber,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputType: TextInputType.number,
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
              RecipientIdentityTile(type: type),
            ],
          ),
        ),
      ],
    );
  }

  void _showBankPickerBottomSheet(
    BuildContext context,
    ValueNotifier<Bank?> selectedBank,
  ) =>
      BankPickerBottomSheet.show(
        context,
        child: Consumer(
          builder: (context, ref, _) {
            final banksAsync = ref.watch(getBanksProvider(.NG));

            return BankPickerBottomSheet(
              banks: banksAsync.value ?? [],
              isLoading: banksAsync.isLoading,
              errorMessage: banksAsync.hasError
                  ? banksAsync.error.toString()
                  : null,
            );
          },
        ),
      ).then((bank) {
        if (bank != null) {
          selectedBank.value = bank;
        }
      });

  void _showLinkedBankAccountsBottomSheet(
    BuildContext context,
    ValueNotifier<PayoutDestination?> selectedPayoutDestination,
  ) => LinkedBankAccountsBottomSheet.show(context).then((payoutDestination) {
    if (payoutDestination != null) {
      selectedPayoutDestination.value = payoutDestination;
    }
  });
}

class _DisbursementTypeSection extends StatelessWidget {
  const _DisbursementTypeSection({
    required this.selectedType,
    required this.onChanged,
  });

  final DisbursementType? selectedType;
  final ValueChanged<DisbursementType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        MenuSectionHeader(title: l10n.howWillThePaymentBeReleased),
        DisbursementTypeSelector(
          selectedType: selectedType,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
