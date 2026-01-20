part of 'forgot_password_screen.dart';

class _RequestCodeStep extends HookConsumerWidget {
  const _RequestCodeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);
    final state = ref.watch(forgotPasswordViewModelProvider);

    final isEmailMode = useState(false);

    final formData = state.value!.forgotPasswordFormData;

    final usernameController = useTextEditingController();

    useEffect(() {
      usernameController.text = isEmailMode.value
          ? formData.email
          : formData.phoneNumber;
      return null;
    }, [isEmailMode.value]);

    useListenable(usernameController);

    bool isFormValid = isEmailMode.value
        ? formData.email.isValidEmailRequired
        : formData.phoneNumber.isValidPhone;

    final bool isLoading = ref.watch(forgotPasswordViewModelProvider).isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      onChanged: () {
        viewModel.onFormChanged(
          ForgotPasswordFormData(
            phoneNumber: isEmailMode.value ? '' : usernameController.text,
            email: isEmailMode.value ? usernameController.text : '',
          ),
        );
      },
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            l10n.enterYourEmailOrPhoneNumberToReceiveA6DigitsRecoveryCode,
            style: context.typo.labelSmall.copyWith(
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
            child: isEmailMode.value
                ? CustomTextFormField(
                    key: const ValueKey('email_field'),
                    labelText: l10n.email,
                    controller: usernameController,
                    textInputType: .emailAddress,
                    validator: (value) =>
                        emailValidator(value, l10n, isRequired: true),
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
                viewModel.onFormChanged(ForgotPasswordFormData.empty());
                isEmailMode.value = !isEmailMode.value;
              },
              child: Text(
                isEmailMode.value ? l10n.usePhoneInstead : l10n.useEmailInstead,
                style: context.typo.bodyLink,
              ),
            ),
          ),
          const Spacer(),
          Gap(Dimens.spacing.sp35),
          PrimaryButton(
            onPressed: isFormValid
                ? () => viewModel.requestCode(isEmailMode.value)
                : null,
            child: Text(l10n.requestCode),
          ),
          Gap(Dimens.spacing.sp20),
        ],
      ),
    );
  }
}
