import 'package:cleer/routing/router.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/l10n/generated/ui_localizations.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainApp extends ConsumerWidget {
  const MainApp._internal();

  static const instances = MainApp._internal();

  factory MainApp() => instances;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...UiLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
