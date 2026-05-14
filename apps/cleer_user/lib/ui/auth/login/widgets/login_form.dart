import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/login/view_model/login_view_model.dart';
import 'package:cleer/ui/core/localization/error_messages.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer_ui/widgets/form_error.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final viewModel = ref.read(loginViewModelProvider.notifier);
    final state = ref.watch(loginViewModelProvider);

    final isEmailMode = state.value!.isEmailMode;
    final loginFormData = state.value!.loginFormData;

    final usernameController = useTextEditingController(
      text: isEmailMode ? loginFormData.email : loginFormData.phoneNumber,
    );
    final TextEditingController passwordController = useTextEditingController(
      text: loginFormData.password,
    );

    final GlobalKey<FormState> loginFormKey = useMemoized(
      () => GlobalKey<FormState>(),
    );
    return Form(
      key: loginFormKey,
      onChanged: () {
        viewModel.onFormChanged(
          state.value!.loginFormData.copyWith(
            phoneNumber: isEmailMode ? '' : usernameController.text,
            email: isEmailMode ? usernameController.text : '',
            password: passwordController.text,
          ),
        );
      },
      child: Column(
        children: [
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
                viewModel.toggleLoginMode();
              },
              child: Text(
                isEmailMode ? l10n.usePhoneInstead : l10n.useEmailInstead,
                style: context.typo.bodyLink,
              ),
            ),
          ),
          Gap(Dimens.spacing.sp28),
          CustomTextFormField(
            labelText: l10n.password,
            controller: passwordController,
            isPassword: true,
          ),
          Gap(Dimens.spacing.sp14),
          Align(
            alignment: .centerRight,
            child: GestureDetector(
              onTap: () => ForgotPasswordRoute().push(context),
              child: Text(
                '${l10n.forgotPassword}?',
                style: context.typo.bodyLink,
              ),
            ),
          ),
          const Spacer(),
          Gap(Dimens.spacing.sp35),
          PrimaryButton(
            onPressed: state.value!.isFormValid
                ? () => viewModel.login()
                : null,
            child: Text(l10n.login),
          ),
          Gap(Dimens.spacing.sp12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: l10n.dontHaveAnAccount,
                  style: context.typo.bodyMedium.copyWith(
                    color: context.color.grey600,
                  ),
                ),
                TextSpan(text: ' '),
                TextSpan(
                  text: l10n.signUp,
                  style: context.typo.bodyLink.copyWith(
                    color: context.color.blue700,
                    decorationColor: context.color.blue700,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => CreateAccountRoute(
                      redirectTo: redirectTo,
                    ).pushReplacement(context),
                ),
              ],
            ),
          ),
          Gap(Dimens.spacing.sp20),
        ],
      ),
    );
  }
}
