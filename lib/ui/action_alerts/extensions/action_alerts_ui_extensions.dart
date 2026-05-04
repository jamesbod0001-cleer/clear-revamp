import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/action_alerts/models/action_alert.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A simple configuration class to hold the painted properties
class AlertUIProperties {
  final String title;
  final String subtitle;
  final Widget leading;
  final Color backgroundColor;
  final Color contentColor;
  final VoidCallback onTap;

  AlertUIProperties({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.backgroundColor,
    required this.contentColor,
    required this.onTap,
  });
}

extension ActionAlertUIExtension on ActionAlert {
  /// Maps the sealed class data into pure UI configurations
  AlertUIProperties getUIProperties(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isCritical = severity == AlertSeverity.critical;
    final backgroundColor = isCritical
        ? context.color.errorLight
        : context.color.warningLight;
    final foregroundColor = isCritical
        ? context.color.error
        : context.color.warning;

    return switch (this) {
      ActiveDisputesAlert a => AlertUIProperties(
        title: l10n.activeDisputesCount(a.count),
        subtitle: l10n.tapToViewAndResolve,
        leading: Assets.images.flag.image(
          color: context.color.error,
          height: Dimens.size.s32,
        ),
        backgroundColor: backgroundColor,
        contentColor: foregroundColor,
        onTap: () {
          // TODO: Route to disputes
        },
      ),

      VerifyNinAlert _ => AlertUIProperties(
        title: l10n.verifyYourNIN,
        subtitle: l10n.unlockHigherTransactionLimits,
        leading: PhosphorIcon(
          PhosphorIcons.identificationCard(.duotone),
          size: Dimens.size.s28,
          color: context.color.warning,
        ),
        backgroundColor: backgroundColor,
        contentColor: foregroundColor,
        onTap: () {
          // TODO: Route to NIN
        },
      ),

      AddEmailAlert _ => AlertUIProperties(
        title: l10n.addYourEmail,
        subtitle: l10n.requiredToFullySecureYourAccount,
        leading: PhosphorIcon(
          PhosphorIcons.mailbox(.duotone),
          size: Dimens.size.s28,
          color: context.color.warning,
        ),
        backgroundColor: backgroundColor,
        contentColor: foregroundColor,
        onTap: () {
          // TODO: Route to Add Email
        },
      ),

      VerifyEmailAlert _ => AlertUIProperties(
        title: l10n.verifyYourEmail,
        subtitle: l10n.verifyToKeepYourAccountActive,
        leading: PhosphorIcon(
          PhosphorIcons.mailbox(.duotone),
          size: Dimens.size.s28,
          color: context.color.warning,
        ),
        backgroundColor: backgroundColor,
        contentColor: foregroundColor,
        onTap: () => VerifyEmailRoute().push(context),
      ),
    };
  }
}
