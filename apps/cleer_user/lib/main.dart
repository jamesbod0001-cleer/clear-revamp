import 'package:cleer/app.dart';
import 'package:cleer/config/amplify_setup.dart';
import 'package:cleer/config/push_notifications_config.dart';
import 'package:cleer_api/cleer_api.dart';
import 'package:cleer_core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  await configureAmplify();
  registerBackgroundNotificationHandler();
  await SentryFlutter.init((options) {
    options.dsn =
        'https://7a63c35003e90d5bc01370b5cb432677@o4510894890090496.ingest.de.sentry.io/4510894892122192';
    // Adds request headers and IP for users, for more info visit:
    // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
    options.sendDefaultPii = true;
    options.enableLogs = true;
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = 1.0;
    // The sampling rate for profiling is relative to tracesSampleRate
    // Setting to 1.0 will profile 100% of sampled transactions:
    options.profilesSampleRate = 1.0;
    // Configure Session Replay
    options.replay.sessionSampleRate = 0.1;
    options.replay.onErrorSampleRate = 1.0;
    options.attachScreenshot = true;
    options.environment = AppConfig.environment;
  });
  runApp(
    SentryWidget(
      child: ProviderScope(
        observers: [CleerSentryObserver()],
        child: MainApp(),
      ),
    ),
  );
}
