import 'package:cleer/ui/auth/create_account/widgets/create_account_form.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Gap(Dimens.spacing.sp16),
                    IconButton(
                      style: IconButton.styleFrom(
                        tapTargetSize: .shrinkWrap,
                        visualDensity: .compact,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                      ),
                      onPressed: () => context.pop(),
                      icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
                    ),
                    Gap(Dimens.spacing.sp24),
                    Text(
                      l10n.letsGetYouStarted,
                      style: context.typo.headlineSmall,
                    ),
                    Gap(Dimens.spacing.sp12),
                    Text(
                      l10n.aFewQuickStepsToSetUpYourAccountAndSecureYourFunds,
                      style: context.typo.labelSmall.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp32),
                    Expanded(child: CreateAccountForm()),
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
