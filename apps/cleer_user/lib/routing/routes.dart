import 'dart:ui';

import 'package:cleer/ui/home/activity_timeline/widgets/activity_timeline_screen.dart';
import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer/ui/agreements/accept_agreement/widgets/accept_agreement_screen.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/agreement_details_screen.dart';
import 'package:cleer/ui/agreements/agreements/widgets/agreements_screen.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/create_agreement_screen.dart';
import 'package:cleer/ui/auth/add_email_address/widgets/add_email_address_screen.dart';
import 'package:cleer/ui/auth/change_password/widgets/change_password_screen.dart';
import 'package:cleer/ui/auth/create_account/widgets/create_account_screen.dart';
import 'package:cleer/ui/auth/create_password/widgets/create_password_screen.dart';
import 'package:cleer/ui/auth/forgot_password/widgets/forgot_password_screen.dart';
import 'package:cleer/ui/auth/login/widgets/login_screen.dart';
import 'package:cleer/ui/auth/registration_success/widgets/registration_success_screen.dart';
import 'package:cleer/ui/auth/verify_email_address/widgets/verify_email_address_screen.dart';
import 'package:cleer/ui/auth/verify_phone_number/models/verification_details.dart';
import 'package:cleer/ui/auth/verify_phone_number/widgets/verify_phone_number_screen.dart';
import 'package:cleer/ui/core/navigation/app_navigation_shell.dart';
import 'package:cleer/ui/core/navigation/navigation_config.dart';
import 'package:cleer/ui/home/home/widgets/home_screen.dart';
import 'package:cleer/ui/onboarding/widgets/onboarding_screen.dart';
import 'package:cleer/ui/profile/account_security/widgets/account_security_screen.dart';
import 'package:cleer/ui/profile/data_privacy/widgets/data_privacy_screen.dart';
import 'package:cleer/ui/profile/help_support/widgets/help_support_screen.dart';
import 'package:cleer/ui/profile/manage_notifications/widgets/manage_notifications_screen.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/payout_destination_screen.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_screen.dart';
import 'package:cleer/ui/profile/terms_and_policies/widgets/terms_and_policies_screen.dart';
import 'package:cleer/ui/splash/widgets/splash_screen.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

// --- HELPERS ---

/// Extension to provide a context-aware navigator key for adaptive routing.
extension AdaptiveGoRouteData on GoRouteData {
  /// Returns the root navigator key if on mobile (to cover the shell),
  /// otherwise returns null to stay within the shell on desktop.
  GlobalKey<NavigatorState>? get dynamicParentNavigatorKey {
    // Try to get context from the navigator key (Standard way)
    final context = cleerNavigatorKey.currentContext;
    if (context != null) {
      return context.isMobile ? cleerNavigatorKey : null;
    }

    // Fallback for initial route tree construction (when context is not yet available)
    // This handles cold starts and deep links by checking the physical screen size.
    try {
      final view = PlatformDispatcher.instance.views.first;
      final width = view.physicalSize.width / view.devicePixelRatio;
      if (width < Breakpoints.tablet) {
        return cleerNavigatorKey;
      }
    } catch (_) {
      // If we can't determine the size, we default to null (desktop-friendly)
    }

    return null;
  }
}

// --- PUBLIC ROUTES ---

@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  final String? redirectTo;

  const SplashRoute({this.redirectTo});

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
  final String? redirectTo;

  LoginRoute({this.redirectTo});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      LoginScreen(redirectTo: redirectTo);
}

class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ForgotPasswordScreen();
}

@TypedGoRoute<CreateAccountRoute>(path: '/create_account')
class CreateAccountRoute extends GoRouteData with $CreateAccountRoute {
  final String? redirectTo;

  CreateAccountRoute({this.redirectTo});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CreateAccountScreen(redirectTo: redirectTo);
}

@TypedGoRoute<VerifyPhoneRoute>(path: '/verify_phone')
class VerifyPhoneRoute extends GoRouteData with $VerifyPhoneRoute {
  final VerificationDetails $extra;
  final String? redirectTo;

  VerifyPhoneRoute({required this.$extra, this.redirectTo});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VerifyPhoneNumberScreen(details: $extra, redirectTo: redirectTo);
}

@TypedGoRoute<CreatePasswordRoute>(path: '/create_password')
class CreatePasswordRoute extends GoRouteData with $CreatePasswordRoute {
  final String phoneNumber;
  final String? redirectTo;

  CreatePasswordRoute({required this.phoneNumber, this.redirectTo});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CreatePasswordScreen(phoneNumber: phoneNumber, redirectTo: redirectTo);
}

@TypedGoRoute<RegistrationSuccessRoute>(path: '/registration_success')
class RegistrationSuccessRoute extends GoRouteData
    with $RegistrationSuccessRoute {
  final String? redirectTo;

  const RegistrationSuccessRoute({this.redirectTo});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RegistrationSuccessScreen();
}

@TypedGoRoute<ChangePasswordRoute>(path: '/change_password')
class ChangePasswordRoute extends GoRouteData with $ChangePasswordRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChangePasswordScreen();
}

@TypedGoRoute<AddEmailRoute>(path: '/add_email')
class AddEmailRoute extends GoRouteData with $AddEmailRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddEmailAddressScreen();
}

@TypedGoRoute<VerifyEmailRoute>(path: '/verify_email')
class VerifyEmailRoute extends GoRouteData with $VerifyEmailRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const VerifyEmailAddressScreen();
}

@TypedGoRoute<AcceptAgreementRoute>(path: '/a/:shortCode')
class AcceptAgreementRoute extends GoRouteData with $AcceptAgreementRoute {
  final String shortCode;
  final String? action;

  const AcceptAgreementRoute({required this.shortCode, this.action});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AcceptAgreementScreen(shortCode: shortCode, action: action);
  }
}

// --- PROTECTED SHELL ROUTES ---

@TypedStatefulShellRoute<ShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [
        TypedGoRoute<HomeRoute>(
          path: '/home',
          routes: [
            TypedGoRoute<ActivityTimelineRoute>(path: 'activity_timeline'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<AgreementsBranch>(
      routes: [
        TypedGoRoute<AgreementsRoute>(
          path: '/agreements',
          routes: [
            TypedGoRoute<CreateAgreementRoute>(path: 'create_agreement/:type'),
            TypedGoRoute<AgreementDetailsRoute>(path: 'details/:id'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [
        TypedGoRoute<ProfileRoute>(
          path: '/profile',
          routes: [
            TypedGoRoute<PayoutDestinationRoute>(path: 'payout_destination'),
            TypedGoRoute<AccountSecurityRoute>(path: 'account_security'),
            TypedGoRoute<ManageNotificationsRoute>(
              path: 'manage_notifications',
            ),
            TypedGoRoute<TermsAndPoliciesRoute>(path: 'terms_and_policies'),
            TypedGoRoute<DataPrivacyRoute>(path: 'data_privacy'),
            TypedGoRoute<HelpSupportRoute>(path: 'help_support'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ActivityBranch>(
      routes: [TypedGoRoute<ActivityTabRoute>(path: '/activity')],
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
      destinations: NavigationConfig.getDestinations(context),
    );
  }
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) => HomeScreen();
}

class ActivityTimelineRoute extends GoRouteData with $ActivityTimelineRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  const ActivityTimelineRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ActivityTimelineScreen();
}

class AgreementsBranch extends StatefulShellBranchData {
  const AgreementsBranch();
}

class AgreementsRoute extends GoRouteData with $AgreementsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AgreementsScreen();
}

class CreateAgreementRoute extends GoRouteData with $CreateAgreementRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  final AgreementType type;

  CreateAgreementRoute({required this.type});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CreateAgreementScreen(type: type);
}

class AgreementDetailsRoute extends GoRouteData with $AgreementDetailsRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  final String id;
  final Agreement? $extra;

  AgreementDetailsRoute({required this.id, this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AgreementDetailsScreen(agreementId: id, initialAgreement: $extra);
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}

class ActivityBranch extends StatefulShellBranchData {
  const ActivityBranch();
}

class ActivityTabRoute extends GoRouteData with $ActivityTabRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ActivityTimelineScreen();
}

class PayoutDestinationRoute extends GoRouteData with $PayoutDestinationRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PayoutDestinationScreen();
}

class AccountSecurityRoute extends GoRouteData with $AccountSecurityRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AccountSecurityScreen();
}

class ManageNotificationsRoute extends GoRouteData
    with $ManageNotificationsRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ManageNotificationsScreen();
}

class TermsAndPoliciesRoute extends GoRouteData with $TermsAndPoliciesRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TermsAndPoliciesScreen();
}

class DataPrivacyRoute extends GoRouteData with $DataPrivacyRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DataPrivacyScreen();
}

class HelpSupportRoute extends GoRouteData with $HelpSupportRoute {
  GlobalKey<NavigatorState>? get parentNavigatorKey =>
      dynamicParentNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      HelpSupportScreen();
}
