import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EnterCardOtpStep extends HookConsumerWidget {
  const EnterCardOtpStep({super.key, required this.agreementId});
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = ref.read(
      paymentOrchestratorViewModelProvider(agreementId).notifier,
    );

    final otpController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isOtpValid = useState(false);

    useEffect(() {
      void listener() {
        final text = otpController.text.trim();
        isOtpValid.value = text.length >= 4 && text.length <= 6;
      }

      otpController.addListener(listener);
      return () => otpController.removeListener(listener);
    }, [otpController]);

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
            StepHeader(title: l10n.verifyYourPayment),
            Gap(Dimens.spacing.sp40),
            CustomTextFormField(
              controller: otpController,
              labelText: l10n.otp,
              textInputType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (value) {
                if (value == null || value.trim().length < 4) {
                  return l10n.invalidOtp;
                }
                return null;
              },
            ),
            Gap(Dimens.spacing.sp32),
            PrimaryButton(
              onPressed: isOtpValid.value
                  ? () {
                      if (formKey.currentState?.validate() ?? false) {
                        viewModel.submitCardOtp(otpController.text.trim());
                      }
                    }
                  : null,
              child: Text(l10n.verifyPayment),
            ),
            Gap(Dimens.spacing.sp48),
          ],
        ),
      ),
    );
  }
}
