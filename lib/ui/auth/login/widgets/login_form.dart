import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/login/view_model/login_view_model.dart';
import 'package:cleer/ui/core/localization/error_messages.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/ui/core/ui/form_error.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final viewmodel = ref.read(loginViewModelProvider.notifier);
    final state = ref.watch(loginViewModelProvider);

    final TextEditingController phoneNumberController =
        useTextEditingController(text: state.value!.loginFormData.phoneNumber);
    final TextEditingController passwordController = useTextEditingController(
      text: state.value!.loginFormData.password,
    );

    final GlobalKey<FormState> loginFormKey = useMemoized(
      () => GlobalKey<FormState>(),
    );
    return Form(
      key: loginFormKey,
      child: Column(
        children: [
          FormError(
            hasError: state.hasError,
            errorMessage: state.error != null
                ? getAuthErrorMessage(state.error as AuthFailure, context)
                : null,
          ),
          PhoneNumberTextFormField(controller: phoneNumberController),
          Gap(Dimens.spacing.sp28),
          CustomTextFormField(
            labelText: l10n.password,
            controller: passwordController,
            isPassword: true,
            // validator: (value) => emailValidator(value, l10n),
          ),
          Gap(Dimens.spacing.sp14),
          Align(
            alignment: .centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Text(l10n.forgotPassword, style: context.typo.bodyLink),
            ),
          ),
          const Spacer(),
          Gap(Dimens.spacing.sp35),
          FilledButton(
            onPressed: state.value!.loginFormData.isValid
                ? () => viewmodel.login()
                : null,
            child: Text(l10n.next),
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
                    ..onTap = () =>
                        CreateAccountRoute().pushReplacement(context),
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
