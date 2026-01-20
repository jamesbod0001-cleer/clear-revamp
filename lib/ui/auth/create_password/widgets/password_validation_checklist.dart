import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PasswordValidationChecklist extends HookWidget {
  const PasswordValidationChecklist({
    super.key,
    required this.passwordController,
    this.isPasswordValid,
  });

  final TextEditingController passwordController;
  final ValueChanged<bool>? isPasswordValid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    useListenable(passwordController);
    bool hasAtLeast1Uppercase = passwordController.text.contains(
      RegExp(r'[A-Z]'),
    );
    bool hasAtLeast1lowercase = passwordController.text.contains(
      RegExp(r'[a-z]'),
    );
    bool hasAtLeast1Number = passwordController.text.contains(RegExp(r'[0-9]'));
    bool hasAtLeast8Characters = passwordController.text.length >= 8;
    final bool allMet =
        hasAtLeast1Uppercase &&
        hasAtLeast1lowercase &&
        hasAtLeast1Number &&
        hasAtLeast8Characters;
    useEffect(() {
      Future.microtask(() => isPasswordValid?.call(allMet));
      return null;
    }, [allMet]);
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          l10n.yourPasswordMustContain,
          style: context.typo.bodyMedium.copyWith(color: context.color.grey500),
        ),
        Gap(Dimens.spacing.sp8),
        _ValidationItem(
          label: l10n.atLeast1Uppercase,
          isMet: hasAtLeast1Uppercase,
        ),
        Gap(Dimens.spacing.sp4),
        _ValidationItem(
          label: l10n.atLeast1Lowercase,
          isMet: hasAtLeast1lowercase,
        ),
        Gap(Dimens.spacing.sp4),
        _ValidationItem(label: l10n.atLeast1Number, isMet: hasAtLeast1Number),
        Gap(Dimens.spacing.sp4),
        _ValidationItem(
          label: l10n.atLeast8Characters,
          isMet: hasAtLeast8Characters,
        ),
      ],
    );
  }
}

class _ValidationItem extends StatelessWidget {
  const _ValidationItem({required this.label, required this.isMet});

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhosphorIcon(
          isMet
              ? PhosphorIcons.checkCircle(.fill)
              : PhosphorIcons.xCircle(.fill),
          size: Dimens.size.s16,
          color: isMet ? context.color.green850 : context.color.grey300,
        ),
        Gap(Dimens.spacing.sp4),
        Text(
          label,
          style: context.typo.bodyMedium.copyWith(
            color: isMet ? context.color.grey800 : context.color.grey600,
          ),
        ),
      ],
    );
  }
}
