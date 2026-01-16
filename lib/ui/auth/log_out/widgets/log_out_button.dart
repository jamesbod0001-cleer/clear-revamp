import 'package:cleer/ui/auth/log_out/view_model/log_out_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LogOutButton extends ConsumerWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton(
      style: FilledButton.styleFrom(
        foregroundColor: context.color.error,
        backgroundColor: context.color.transparent,
      ),
      onPressed: () => ref.read(logOutViewModelProvider.notifier).logOut(),
      child: Text(l10n.logout),
    );
  }
}
