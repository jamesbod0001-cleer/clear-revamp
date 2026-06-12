import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/onboarding/widgets/onboarding_carousel.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';

class OnboardingScreen extends HookWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.color.transparent,
      body: OnboardingCarousel(
        footer: Padding(
          padding: Dimens.of(context).edgeInsetsScreenHorizontal,
          child: Column(
            children: [
              PrimaryButton(
                onPressed: () => CreateAccountRoute().push(context),
                child: Text(l10n.getStarted),
              ),
              Gap(Dimens.spacing.sp12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.alreadyHaveAnAccount,
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.outline,
                      ),
                    ),
                    TextSpan(text: ' '),
                    TextSpan(
                      text: l10n.logIn,
                      style: context.typo.bodyLink.copyWith(
                        color: context.color.primaryBlue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => LoginRoute().push(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
