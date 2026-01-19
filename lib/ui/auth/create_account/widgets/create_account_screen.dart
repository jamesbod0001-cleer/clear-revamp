import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/ui/auth/create_account/view_model/create_account_view_model.dart';
import 'package:cleer/ui/auth/create_account/widgets/create_account_form.dart';
import 'package:cleer/ui/auth/verify_phone_number/models/verification_details.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/app_back_button.dart';
import 'package:cleer/ui/core/ui/offline_warning_banner.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateAccountScreen extends ConsumerWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen(createAccountViewModelProvider, (prev, next) {
      next.whenData((state) {
        final result = state.signUpDomainResult;
        if (result == null) return;

        result.when(
          success: () {},
          confirmationRequired: (String destination, String deliveryMedium) {
            final formData = ref
                .read(createAccountViewModelProvider)
                .value!
                .createAccountFormData;

            final cleanDigits = formData.phoneNumber.replaceAll(' ', '');
            final fullE164Number = '+234$cleanDigits';
            final details = VerificationDetails(
              username: fullE164Number,
              destination: destination,
              deliveryMedium: deliveryMedium,
            );
            ref.read(createAccountViewModelProvider.notifier).resetResult();
            VerifyPhoneRoute($extra: details).push(context);
          },
        );
      });
    });
    final bool viewModelsLoading = ref
        .watch(createAccountViewModelProvider)
        .isLoading;

    final bool isRedirectingOrSyncing = ref
        .watch(authUseCaseProvider)
        .maybeWhen(
          data: (state) => state is SignedIn,
          loading: () => true,
          orElse: () => false,
        );
    bool isLoading = viewModelsLoading || isRedirectingOrSyncing;
    if (isLoading) {
      return Material(child: Center(child: CircularProgressIndicator()));
    }
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
                    Gap(Dimens.spacing.sp16),
                    AppBackButton(),
                    Gap(Dimens.spacing.sp24),
                    OfflineWarningBanner(),
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
