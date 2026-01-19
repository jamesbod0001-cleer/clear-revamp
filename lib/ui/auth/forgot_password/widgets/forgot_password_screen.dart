import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Gap(Dimens.spacing.sp24),
                    AppBackButton(),
                    Gap(Dimens.spacing.sp24),
                    Text(
                      l10n.forgotPassword,
                      style: context.typo.headlineSmall,
                    ),
                    Gap(Dimens.spacing.sp12),
                    Text(
                      l10n.enterYourEmailOrPhoneNumberToReceiveA6DigitsRecoveryCode,
                      style: context.typo.labelSmall.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp32),
                    // Expanded(child: LoginForm()),
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
