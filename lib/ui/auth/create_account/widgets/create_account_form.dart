import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/create_account/view_model/create_account_view_model.dart';
import 'package:cleer/ui/core/localization/error_messages.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/ui/core/ui/form_error.dart';
import 'package:cleer/utils/validators/validators.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateAccountForm extends HookConsumerWidget {
  const CreateAccountForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final viewmodel = ref.read(createAccountViewModelProvider.notifier);
    final state = ref.watch(createAccountViewModelProvider);

    final TextEditingController firstNameController = useTextEditingController(
      text: state.value!.createAccountFormData.firstName,
    );
    final TextEditingController lastNameController = useTextEditingController(
      text: state.value!.createAccountFormData.lastName,
    );
    final TextEditingController phoneNumberController =
        useTextEditingController(
          text: state.value!.createAccountFormData.phoneNumber,
        );
    final TextEditingController emailController = useTextEditingController(
      text: state.value!.createAccountFormData.email,
    );

    final GlobalKey<FormState> createAccountFormKey = useMemoized(
      () => GlobalKey<FormState>(),
    );

    return Form(
      key: createAccountFormKey,
      onChanged: () {
        viewmodel.onFormChanged(
          state.value!.createAccountFormData.copyWith(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            phoneNumber: phoneNumberController.text,
            email: emailController.text,
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
          CustomTextFormField(
            labelText: l10n.firstName,
            controller: firstNameController,
            textInputType: .name,
            validator: (value) => commonValidator(
              value: value,
              fieldName: l10n.firstName,
              l10n: l10n,
            ),
          ),
          Gap(Dimens.spacing.sp28),
          CustomTextFormField(
            labelText: l10n.lastName,
            controller: lastNameController,
            textInputType: .name,
            validator: (value) => commonValidator(
              value: value,
              fieldName: l10n.lastName,
              l10n: l10n,
            ),
          ),
          Gap(Dimens.spacing.sp28),
          PhoneNumberTextFormField(controller: phoneNumberController),
          Gap(Dimens.spacing.sp28),
          CustomTextFormField(
            labelText: '${l10n.emailAddress} ${l10n.optional}',
            controller: emailController,
            textInputType: .emailAddress,
            validator: (value) => emailValidator(value, l10n),
          ),
          Gap(Dimens.spacing.sp4),
          Align(
            alignment: .centerLeft,
            child: Text(
              l10n.wellOnlyUseThisForReceiptsAndImportantUpdates,
              style: context.typo.bodySmall.copyWith(
                color: context.color.grey500,
              ),
            ),
          ),
          const Spacer(),
          Gap(Dimens.spacing.sp35),
          PrimaryButton(
            onPressed: state.value!.createAccountFormData.isValid
                ? () => viewmodel.signUp()
                : null,
            child: Text(l10n.next),
          ),
          Gap(Dimens.spacing.sp12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: l10n.alreadyHaveAnAccount,
                  style: context.typo.bodyMedium.copyWith(
                    color: context.color.grey600,
                  ),
                ),
                TextSpan(text: ' '),
                TextSpan(
                  text: l10n.logIn,
                  style: context.typo.bodyLink.copyWith(
                    color: context.color.blue700,
                    decorationColor: context.color.blue700,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => LoginRoute().pushReplacement(context),
                ),
              ],
            ),
          ),
          Gap(Dimens.spacing.sp20),
          Text(
            l10n.byTappingNextYouAgreeToCleerTermsOfService,
            style: context.typo.bodySmall.copyWith(
              color: context.color.grey600,
            ),
          ),
          Gap(Dimens.spacing.sp20),
        ],
      ),
    );
  }
}
