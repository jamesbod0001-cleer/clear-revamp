part of 'forgot_password_screen.dart';

class _RequestCodeStep extends HookConsumerWidget {
  const _RequestCodeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);
    final state = ref.watch(forgotPasswordViewModelProvider);

    final isEmailMode = state.value!.isEmailMode;

    final formData = state.value!.forgotPasswordFormData;

    final usernameController = useTextEditingController();

    useEffect(() {
      usernameController.text = isEmailMode
          ? formData.email
          : formData.phoneNumber;
      return null;
    }, [isEmailMode]);

    useListenable(usernameController);

    bool isFormValid = isEmailMode
        ? formData.email.isValidEmailRequired
        : formData.phoneNumber.isValidPhone;

    return Form(
      onChanged: () {
        viewModel.onFormChanged(
          ForgotPasswordFormData(
            phoneNumber: isEmailMode ? '' : usernameController.text,
            email: isEmailMode ? usernameController.text : '',
          ),
        );
      },
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            l10n.enterYourEmailOrPhoneNumberToReceiveA6DigitsRecoveryCode,
            style: context.typo.bodyMedium.copyWith(
              fontWeight: AppFontWeights.regular,
              color: context.color.grey600,
            ),
          ),
          Gap(Dimens.spacing.sp32),
          FormError(
            hasError: state.hasError,
            errorMessage: state.error != null
                ? getAuthErrorMessage(state.error as AuthFailure, context)
                : null,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isEmailMode
                ? CustomTextFormField(
                    key: const ValueKey('email_field'),
                    labelText: l10n.email,
                    controller: usernameController,
                    textInputType: .emailAddress,
                    validator: context.emailValidator(),
                  )
                : PhoneNumberTextFormField(
                    key: const ValueKey('phone_field'),
                    controller: usernameController,
                  ),
          ),
          Gap(Dimens.spacing.sp12),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                usernameController.clear();
                viewModel.toggleIsEmailMode();
              },
              child: Text(
                isEmailMode ? l10n.usePhoneInstead : l10n.useEmailInstead,
                style: context.typo.bodyLink,
              ),
            ),
          ),
          const Spacer(),
          Gap(Dimens.spacing.sp35),
          PrimaryButton(
            onPressed: isFormValid ? () => viewModel.requestCode() : null,
            child: Text(l10n.requestCode),
          ),
          Gap(context.isMobile ? Dimens.spacing.sp20 : Dimens.spacing.sp32),
        ],
      ),
    );
  }
}
