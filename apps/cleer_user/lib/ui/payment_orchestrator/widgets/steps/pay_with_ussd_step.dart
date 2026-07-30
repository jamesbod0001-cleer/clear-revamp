import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/ui/core/extensions/error_ui_extensions.dart';
import 'package:cleer_core/models/bank/bank.dart';
import 'package:cleer/ui/core/extensions/string_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/bottom_sheets/bank_picker_bottom_sheet.dart';
import 'package:cleer_ui/widgets/custom_text_form_field.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/step_header.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PayWithUSSDStep extends HookConsumerWidget {
  const PayWithUSSDStep({super.key, required this.agreementId});
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
    final viewModel = ref.read(
      paymentOrchestratorViewModelProvider(agreementId).notifier,
    );
    final ValueNotifier<Bank?> selectedBank = useState<Bank?>(null);
    final bankController = useTextEditingController(
      text: selectedBank.value?.name,
    );

    final ussdCommand = viewModel.generateUSSDCode;
    useEffect(() {
      void listener() {
        if (ussdCommand.errors.value != null) {
          debugPrint("Command Error: ${ussdCommand.errors.value?.error}");
        }
      }

      ussdCommand.errors.addListener(listener);
      return () => ussdCommand.errors.removeListener(listener);
    }, [ussdCommand]);

    useEffect(() {
      bankController.text = selectedBank.value?.name ?? '';
      if (selectedBank.value != null) {
        // viewModel.cancelTransaction();
        viewModel.generateUSSDCode.clearErrors();
        viewModel.generateUSSDCode.runAsync(selectedBank.value);
      }
      return null;
    }, [selectedBank.value]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;
        viewModel.changePaymentMethod(); // Going back to change payment method
      },
      child: Column(
        children: [
          StepHeader(title: l10n.continueWithOpay),
          Gap(Dimens.spacing.sp40),
          CustomTextFormField(
            controller: bankController,
            labelText: l10n.selectBank,
            readOnly: true,
            onTap: () => _showBankPickerBottomSheet(
              context,
              selectedBank,
            ),
            suffixIcon: IconButton(
              onPressed: () => _showBankPickerBottomSheet(
                context,
                selectedBank,
              ),
              icon: PhosphorIcon(
                PhosphorIcons.caretDown(),
                color: context.color.blue700,
              ),
            ),
          ),
          Gap(Dimens.spacing.sp24),
          ValueListenableBuilder<bool>(
            valueListenable: viewModel.generateUSSDCode.isRunning,
            builder: (context, isRunning, _) {
              if (isRunning) {
                return SizedBox(
                  height: Dimens.size.s100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ValueListenableBuilder<CommandResult<Bank?, String>>(
                valueListenable: viewModel.generateUSSDCode.results,
                builder: (BuildContext context, result, Widget? child) {
                  if (result.isRunning) {
                    return SizedBox(
                      height: Dimens.size.s100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // 2. Check if the execution failed or if there is no data
                  if (result.hasError || !result.hasData) {
                    return SizedBox.shrink();
                  }
                  final ussd = result.data?.extractUssd;
                  if (ussd == null || ussd.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      Container(
                        padding: .symmetric(
                          horizontal: Dimens.padding.p20,
                          vertical: Dimens.padding.p16,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.color.infoLight,
                          borderRadius: .circular(Dimens.radius.r15),
                        ),
                        child: Column(
                          mainAxisSize: .min,
                          children: [
                            Text(
                              l10n.dial,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: Color(0xFF2F2F2F).withValues(alpha: .75),
                              ),
                            ),
                            Gap(Dimens.spacing.sp12),
                            FittedBox(
                              child: Text(
                                ussd,
                                style: context.typo.headlineSmall.copyWith(
                                  color: context.color.blue700,
                                  decoration: .underline,
                                  decorationStyle: .dotted,
                                  decorationColor: context.color.blue700,
                                  decorationThickness: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(Dimens.spacing.sp32),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.color.grey800,
                          padding: .symmetric(vertical: Dimens.padding.p12),
                          tapTargetSize: .shrinkWrap,
                          visualDensity: .compact,
                        ),
                        onPressed: () => viewModel.verifyTransaction(),
                        child: Text(l10n.iHaveCompletedTheUSSDPayment),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Gap(Dimens.spacing.sp54),
        ],
      ),
    );
  }

  void _showBankPickerBottomSheet(
    BuildContext context,
    ValueNotifier<Bank?> selectedBank,
  ) => BankPickerBottomSheet.show(
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
    }
  });
}
