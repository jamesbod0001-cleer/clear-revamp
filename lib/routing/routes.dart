import 'package:cleer/ui/auth/create_account/widgets/create_account_screen.dart';
import 'package:cleer/ui/auth/create_password/widgets/create_password_screen.dart';
import 'package:cleer/ui/auth/forgot_password/widgets/forgot_password_screen.dart';
import 'package:cleer/ui/auth/login/widgets/login_screen.dart';
import 'package:cleer/ui/auth/registration_success/widgets/registration_success_screen.dart';
import 'package:cleer/ui/auth/verify_phone_number/models/verification_details.dart';
import 'package:cleer/ui/auth/verify_phone_number/widgets/verify_phone_number_screen.dart';
import 'package:cleer/ui/core/navigation/app_navigation_shell.dart';
import 'package:cleer/ui/core/navigation/navigation_config.dart';
import 'package:cleer/ui/onboarding/widgets/onboarding_screen.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_screen.dart';
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

@TypedGoRoute<LoginRoute>(
  path: '/login',
  routes: [TypedGoRoute<ForgotPasswordRoute>(path: 'forgot_password')],
)
class LoginRoute extends GoRouteData with $LoginRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) => LoginScreen();
}

class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ForgotPasswordScreen();
}

@TypedGoRoute<CreateAccountRoute>(path: '/create_account')
class CreateAccountRoute extends GoRouteData with $CreateAccountRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CreateAccountScreen();
}

@TypedGoRoute<VerifyPhoneRoute>(path: '/verify_phone')
class VerifyPhoneRoute extends GoRouteData with $VerifyPhoneRoute {
  final VerificationDetails $extra;
  VerifyPhoneRoute({required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VerifyPhoneNumberScreen(details: $extra);
}

@TypedGoRoute<CreatePasswordRoute>(path: '/create_password')
class CreatePasswordRoute extends GoRouteData with $CreatePasswordRoute {
  final String phoneNumber;
  CreatePasswordRoute({required this.phoneNumber});
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CreatePasswordScreen(phoneNumber: phoneNumber);
}

@TypedGoRoute<RegistrationSuccessRoute>(path: '/registration_success')
class RegistrationSuccessRoute extends GoRouteData
    with $RegistrationSuccessRoute {
  const RegistrationSuccessRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RegistrationSuccessScreen();
}

// --- PROTECTED SHELL ROUTES ---

@TypedStatefulShellRoute<ShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [TypedGoRoute<HomeRoute>(path: '/home')],
    ),
    TypedStatefulShellBranch<AgreementsBranch>(
      routes: [TypedGoRoute<AgreementsRoute>(path: '/agreements')],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile')],
    ),
  ],
)
class ShellRouteData extends StatefulShellRouteData {
  const ShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AppNavigationShell(
      navigationShell: navigationShell,
      destinations: NavigationConfig.destinations,
    );
  }
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) => Placeholder();
}

class AgreementsBranch extends StatefulShellBranchData {
  const AgreementsBranch();
}

class AgreementsRoute extends GoRouteData with $AgreementsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const Placeholder();
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}
