import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/card_summary_tile.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EnterCardPinStep extends HookConsumerWidget {
  const EnterCardPinStep({super.key, required this.agreementId});
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = ref.read(
      paymentOrchestratorViewModelProvider(agreementId).notifier,
    );

    final pinController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isPinValid = useState(false);

    useEffect(() {
      void listener() {
        isPinValid.value = pinController.text.length == 4;
      }

      pinController.addListener(listener);
      return () => pinController.removeListener(listener);
    }, [pinController]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        viewModel.changePaymentMethod();
      },
      child: Form(
        key: formKey,
        child: Column(
          children: [
            StepHeader(title: l10n.enterYourCardPin),
            Gap(Dimens.spacing.sp40),
            const CardSummaryTile(),
            Gap(Dimens.spacing.sp20),
            CustomTextFormField(
              controller: pinController,
              labelText: l10n.cardPin,
              isPassword: true,
              textInputType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.length < 4) {
                  return l10n.invalidPin;
                }
                return null;
              },
            ),
            Gap(Dimens.spacing.sp32),
            PrimaryButton(
              onPressed: isPinValid.value
                  ? () {
                      if (formKey.currentState?.validate() ?? false) {
                        viewModel.submitCardPin(pinController.text);
                      }
                    }
                  : null,
              child: Text(l10n.continueText),
            ),
            Gap(Dimens.spacing.sp48),
          ],
        ),
      ),
    );
  }
}
