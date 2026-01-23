import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/agreement_numpad_overlay.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_section_header.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementSetupStep extends StatelessWidget {
  const AgreementSetupStep({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CustomTextFormField(
          labelText: l10n.amount,
          readOnly: true,
          onTap: () => showAgreementNumpadOverlay(context),
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: Dimens.padding.p8),
            child: Text(
              l10n.nairaSign,
              style: context.typo.bodyLarge.copyWith(
                color: context.color.grey600,
              ),
            ),
          ),
          suffixIcon: IconButton(
            onPressed: () => showAgreementNumpadOverlay(context),
            icon: PhosphorIcon(
              PhosphorIcons.numpad(),
              color: context.color.blue700,
            ),
          ),
        ),
        Gap(Dimens.spacing.sp40),

        ProfileSectionHeader(title: l10n.recipientDetails),
        CustomTextFormField(
          labelText: l10n.selectBank,
          suffixIcon: IconButton(
            onPressed: () {},
            icon: PhosphorIcon(
              PhosphorIcons.caretDown(),
              color: context.color.blue700,
            ),
          ),
        ),
        Gap(Dimens.spacing.sp28),
        CustomTextFormField(labelText: l10n.accountNumber),
        Gap(Dimens.spacing.sp40),

        ProfileSectionHeader(title: l10n.howWillThePaymentBeReleased),
      ],
    );
  }

  void showAgreementNumpadOverlay(BuildContext context) => showDialog(
    context: context,
    useRootNavigator: true,
    fullscreenDialog: true,
    useSafeArea: false,
    builder: (context) => AgreementNumpadOverlay(type: type),
  );
}
