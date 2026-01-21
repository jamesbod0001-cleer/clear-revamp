import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const OnboardingRoute().go(context);
    });
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.onboardingBackground.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: context.color.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
