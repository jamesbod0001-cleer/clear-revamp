import 'package:flutter/material.dart';

/// Global key to access the ScaffoldMessenger (for SnackBars/Banners)
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Global key to access the Navigator (for context-less navigation)
final GlobalKey<NavigatorState> cleerNavigatorKey = GlobalKey<NavigatorState>();
