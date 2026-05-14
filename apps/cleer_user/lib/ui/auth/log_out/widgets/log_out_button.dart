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
    final l10n = AppLocalizations.of(context)!;
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
          PhosphorIcon(PhosphorIcons.signOut(.duotone), size: Dimens.size.s24),
          Gap(Dimens.spacing.sp10),
          Text(l10n.logout),
        ],
      ),
    );
  }
}
