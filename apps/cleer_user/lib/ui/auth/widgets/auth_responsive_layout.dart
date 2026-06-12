import 'package:cleer/ui/onboarding/widgets/onboarding_carousel.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';

class AuthResponsiveLayout extends StatelessWidget {
  final Widget child;

  const AuthResponsiveLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= Breakpoints.tablet) {
      return Scaffold(
        body: Row(
          children: [
            const Expanded(
              child: OnboardingCarousel(),
            ),
            Expanded(
              child: Container(
                color: context.color.background,
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
    );
  }
}
