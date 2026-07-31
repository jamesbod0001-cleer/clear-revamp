import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authUseCaseProvider, (previous, next) {
      if (next.isLoading) return;

      final authState = next.value;
      final hasError = next.hasError;

      final width = MediaQuery.sizeOf(context).width;

      // Handle Success
      if (authState is SignedIn) {
        HomeRoute().go(context);
        return;
      }

      // Handle Sign Out OR Error (Total failure)
      if (authState is SignedOut || hasError) {
        if (width >= Breakpoints.tablet) {
          CreateAccountRoute().go(context);
        } else {
          OnboardingRoute().go(context);
        }
      }
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
        body: Column(
          mainAxisAlignment: .center,
          children: [
            Assets.icons.cleerPrimaryLogo.svg(),
            Gap(Dimens.spacing.sp24),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
