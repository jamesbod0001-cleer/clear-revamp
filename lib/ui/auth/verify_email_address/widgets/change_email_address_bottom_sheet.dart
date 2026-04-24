import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangeEmailAddressBottomSheet extends HookConsumerWidget {
  const ChangeEmailAddressBottomSheet({super.key, required this.saveChanges});

  final Function(String newEmail) saveChanges;

  static Future<void> show(
    BuildContext context, {
    required Function(String newEmail) saveChanges,
  }) => CustomBottomSheet.show<void>(
    context: context,
    isDismissible: true,
    child: ChangeEmailAddressBottomSheet(saveChanges: saveChanges),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final newEmailAddressController = useTextEditingController();

    return Column(
      children: [
        Text(l10n.changeEmailAddress, style: context.typo.headlineSmall),
        Gap(Dimens.spacing.sp24),
        CustomTextFormField(
          controller: newEmailAddressController,
          labelText: l10n.enterNewEmailAddress,
        ),
        Gap(Dimens.spacing.sp24),
        PrimaryButton(
          onPressed: () => saveChanges(newEmailAddressController.text),
          child: Text(l10n.saveChanges),
        ),
        Gap(Dimens.spacing.sp20),
      ],
    );
  }
}
