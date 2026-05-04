import 'package:flutter/material.dart';

/// A global key to access the ScaffoldMessenger without BuildContext.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();