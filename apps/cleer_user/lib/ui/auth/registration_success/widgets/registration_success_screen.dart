import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/auth/registration_success/view_model/registration_success_view_model.dart';
import 'package:cleer/ui/auth/widgets/auth_responsive_layout.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RegistrationSuccessScreen extends ConsumerWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AuthResponsiveLayout(
      child: SafeArea(
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
                              l10n.youreCleerYourAccountIsSecured,
                              style: context.typo.headlineSmall,
                              textAlign: .center,
                            ),
                            Gap(Dimens.spacing.sp12),
                            Text(
                              l10n.welcomeToCleerWhereYourPaymentsAreSafeAndTransparent,
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
                    Gap(
                      context.isMobile
                          ? Dimens.spacing.sp20
                          : Dimens.spacing.sp32,
                    ),
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
