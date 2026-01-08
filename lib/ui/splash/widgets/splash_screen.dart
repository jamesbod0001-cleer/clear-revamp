import 'package:cleer/routing/routes.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    OnboardingRoute().go(context);
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
