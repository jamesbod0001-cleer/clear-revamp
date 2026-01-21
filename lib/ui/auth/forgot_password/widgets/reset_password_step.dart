part of 'forgot_password_screen.dart';

class _ResetPasswordStep extends HookConsumerWidget {
  const _ResetPasswordStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);
    final state = ref.watch(forgotPasswordViewModelProvider);

    final String? destination = state.value!.resetPasswordDomainResult
        ?.whenOrNull(confirmationRequired: (destination, _) => destination);

    final TextEditingController codeController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
    final TextEditingController confirmPasswordController =
        useTextEditingController();
    final checklistIsMet = useState(false);
    useListenable(codeController);
    useListenable(passwordController);
    useListenable(confirmPasswordController);

    bool isFormValid =
        codeController.text.length == 6 &&
        (checklistIsMet.value &&
            passwordController.text == confirmPasswordController.text &&
            confirmPasswordController.text.isNotEmpty);

    return Form(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: l10n.enterThe6DigitCodeSentTo,
                  style: context.typo.labelSmall.copyWith(
                    color: context.color.grey600,
                  ),
                ),
                TextSpan(text: ' '),
                TextSpan(text: destination, style: context.typo.labelSmall),
              ],
            ),
          ),
          Gap(Dimens.spacing.sp32),
          FormError(
            hasError: state.hasError,
            errorMessage: state.error != null
                ? getAuthErrorMessage(state.error as AuthFailure, context)
                : null,
          ),
          CustomTextFormField(
            labelText: l10n.sixDigitsCode,
            controller: codeController,
            textInputType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(6)],
            validator: (code) {
              if (code == null || code.isEmpty) {
                return l10n.pleaseEnter6DigitsCode;
              }
              if (code.length != 6) {
                return l10n.enterValid6DigitsCode;
              }
              return null;
            },
          ),
          Gap(Dimens.spacing.sp28),
          CustomTextFormField(
            controller: passwordController,
            labelText: l10n.enterNewPassword,
            isPassword: true,
          ),
          Gap(Dimens.spacing.sp28),
          CustomTextFormField(
            controller: confirmPasswordController,
            labelText: l10n.confirmPassword,
            isPassword: true,
            validator: (value) {
              final confirmPassword = value ?? '';
              if (confirmPassword.isEmpty) {
                return l10n.pleaseEnterYourPassword;
              }
              if (passwordController.text != confirmPassword) {
                return l10n.passwordDoesNotMatch;
              }
              return null;
            },
          ),
          Gap(Dimens.spacing.sp28),
          PasswordValidationChecklist(
            passwordController: passwordController,
            isPasswordValid: (valid) => checklistIsMet.value = valid,
          ),
          const Spacer(),
          Gap(Dimens.spacing.sp40),
          PrimaryButton(
            onPressed: isFormValid
                ? () {
                    viewModel.onFormChanged(
                      state.value!.forgotPasswordFormData.copyWith(
                        code: codeController.text,
                        newPassword: passwordController.text,
                      ),
                    );
                    viewModel.resetPassword();
                  }
                : null,
            child: Text(l10n.resetPassword),
          ),
          Gap(Dimens.spacing.sp20),
        ],
      ),
    );
  }
}
