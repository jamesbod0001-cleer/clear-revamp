import 'package:cleer/ui/auth/log_out/view_model/log_out_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LogOutButton extends ConsumerWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < Breakpoints.tablet;

    final l10n = AppLocalizations.of(context)!;

    if (isMobile) {
      return OutlinedButton(
        style: FilledButton.styleFrom(
          foregroundColor: context.color.error,
          side: BorderSide(color: context.color.error),
          padding: EdgeInsets.symmetric(vertical: Dimens.padding.p12),
        ),
        onPressed: () => ref.read(logOutViewModelProvider.notifier).logOut(),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            PhosphorIcon(
              PhosphorIcons.signOut(.duotone),
              size: Dimens.size.s24,
            ),
            Gap(Dimens.spacing.sp10),
            Text(l10n.logout),
          ],
        ),
      );
    }

    return Material(
      color: context.color.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.radius.r12),
        onTap: () => ref.read(logOutViewModelProvider.notifier).logOut(),
        splashColor: context.color.error.withValues(alpha: .5),
        highlightColor: context.color.error.withValues(alpha: .05),
        child: Container(
          padding: EdgeInsets.all(Dimens.padding.p12),
          decoration: BoxDecoration(
            color: context.color.transparent,
            borderRadius: BorderRadius.circular(Dimens.radius.r12),
          ),
          child: Row(
            children: [
              // Icon
              PhosphorIcon(
                PhosphorIcons.signOut(.duotone),
                color: context.color.error,
                size: Dimens.size.s20,
              ),
              Gap(
                width >= Breakpoints.desktop
                    ? Dimens.spacing.sp12
                    : Dimens.spacing.sp8,
              ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.logout,
                  style:
                      (width >= Breakpoints.desktop
                              ? context.typo.bodyMedium
                              : context.typo.bodySmall)
                          .copyWith(color: context.color.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
