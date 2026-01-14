import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/auth/registration_success/view_model/registration_success_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RegistrationSuccessScreen extends ConsumerWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.padding.p12,
                        ),
                        child: Column(
                          mainAxisAlignment: .center,
                          children: [
                            CircleAvatar(
                              radius: Dimens.radius.r50,
                              backgroundColor: context.color.white,
                              child: Assets.images.successThumbUp.image(
                                width: Dimens.size.s60,
                                height: Dimens.size.s56,
                              ),
                            ),
                            Gap(Dimens.spacing.sp54),
                            Text(
                              l10n.youreCleerAccountSecured,
                              style: context.typo.headlineSmall,
                              textAlign: .center,
                            ),
                            Gap(Dimens.spacing.sp12),
                            Text(
                              l10n.welcomeToThePlatformWhereTrustIsGuaranteedAndTransactionsAreAlwaysTransparent,
                              textAlign: .center,
                              style: context.typo.bodyMedium.copyWith(
                                color: context.color.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(Dimens.spacing.sp28),
                    FilledButton(
                      onPressed: () => ref
                          .read(registrationSuccessViewModelProvider.notifier)
                          .finish(),
                      child: Text(l10n.finish),
                    ),
                    Gap(Dimens.spacing.sp38),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
