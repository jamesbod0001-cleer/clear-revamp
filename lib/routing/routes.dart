import 'package:cleer/ui/auth/create_account/widgets/create_account_screen.dart';
import 'package:cleer/ui/auth/verify_phone_number/models/verification_details.dart';
import 'package:cleer/ui/auth/verify_phone_number/widgets/verify_phone_number_screen.dart';
import 'package:cleer/ui/onboarding/widgets/onboarding_screen.dart';
import 'package:cleer/ui/splash/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

// --- PUBLIC ROUTES ---

@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
}

@TypedGoRoute<CreateAccountRoute>(path: '/create_account')
class CreateAccountRoute extends GoRouteData with $CreateAccountRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CreateAccountScreen();
}

@TypedGoRoute<VerifyPhoneRoute>(path: '/verify_phone_number')
class VerifyPhoneRoute extends GoRouteData with $VerifyPhoneRoute {
  final VerificationDetails $extra;
  VerifyPhoneRoute({required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VerifyPhoneNumberScreen(details: $extra);
}
