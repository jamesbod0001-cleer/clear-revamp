import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/utils/validators/common_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';

class CreateAccountForm extends HookWidget {
  const CreateAccountForm({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController firstNameController =
        useTextEditingController();
    final TextEditingController lastNameController = useTextEditingController();
    final TextEditingController phoneNumberController =
        useTextEditingController();
    final TextEditingController emailController = useTextEditingController();
    final GlobalKey<FormState> createAccountFormKey = useMemoized(
      () => GlobalKey<FormState>(),
    );
    return Form(
      key: createAccountFormKey,
      child: Column(
        children: [
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
          ),
          const Spacer(),
          Gap(Dimens.spacing.sp40),
          FilledButton(onPressed: () {}, child: Text(l10n.next)),
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
                  style: context.typo.bodyMedium.copyWith(
                    color: context.color.blue700,
                  ),
                ),
              ],
            ),
          ),
          Gap(Dimens.spacing.sp20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: l10n.byClickingContinueYouAgreeToCleer,
                  style: context.typo.bodySmall.copyWith(
                    color: context.color.grey600,
                  ),
                ),
                TextSpan(text: ' '),
                TextSpan(
                  text: l10n.terms,
                  style: context.typo.bodySmall.copyWith(
                    color: context.color.blue700,
                  ),
                ),
              ],
            ),
          ),
          Gap(Dimens.spacing.sp8),
        ],
      ),
    );
  }
}
