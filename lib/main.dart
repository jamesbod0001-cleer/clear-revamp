import 'package:cleer/app.dart';
import 'package:cleer/config/amplify_setup.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureAmplify();
  runApp(ProviderScope(child: MainApp()));
}
