import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.watch(userProfileProvider).isLoading) {
      } else {
        const OnboardingRoute().go(context);
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
