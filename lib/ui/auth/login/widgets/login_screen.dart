import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/agreement/agreement_preview.dart';
import 'package:cleer/domain/models/sign_in_result/sign_in_result.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/accept_agreement/view_model/accept_agreement_view_model.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/ui/auth/login/view_model/login_view_model.dart';
import 'package:cleer/ui/auth/login/widgets/login_form.dart';
import 'package:cleer/ui/auth/verify_phone_number/models/verification_details.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/app_back_button.dart';
import 'package:cleer/ui/core/ui/offline_warning_banner.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    String? shortCode;
    if (redirectTo != null && redirectTo!.startsWith('/a/')) {
      shortCode = redirectTo!.split('/a/').last.split('?').first;
    }
    AgreementPreview? preview;
    if (shortCode != null) {
      preview = ref
          .watch(acceptAgreementViewModelProvider(shortCode))
          .value
          ?.agreementPreview;
    }

    String title = l10n.welcomeBack;
    String? subtitle = l10n.pickUpWhereYouLeftOff;

    if (preview != null) {
      if (preview.initiatorRole == InitiatorRole.sender) {
        title = l10n.verifyYourIdentityToReceiveFunds;
        subtitle = null;
      } else {
        title = l10n.confirmYourIdentity;
        subtitle = l10n.thisHelpsUsToKeepPaymentsSecureAndCompliant;
      }
    }

    ref.listen(loginViewModelProvider, (prev, next) {
      next.whenData((state) {
        final result = state.signInDomainResult;
        if (result == null) return;

        result.maybeWhen(
          confirmationRequired: (String destination, String deliveryMedium) {
            final formData = ref
                .read(loginViewModelProvider)
                .value!
                .loginFormData;

            final cleanDigits = formData.phoneNumber.replaceAll(' ', '');
            final fullE164Number = '+234$cleanDigits';
            final details = VerificationDetails(
              username: fullE164Number,
              destination: destination,
              deliveryMedium: deliveryMedium,
            );
            ref.read(loginViewModelProvider.notifier).resetResult();
            VerifyPhoneRoute(
              $extra: details,
              redirectTo: redirectTo,
            ).push(context);
          },
          orElse: () {
            debugPrint(result.runtimeType.toString());
          },
        );
      });
    });

    final bool viewModelsLoading = ref.watch(loginViewModelProvider).isLoading;

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
                    Text(title, style: context.typo.headlineSmall),
                    if (subtitle != null) ...[
                      Gap(Dimens.spacing.sp8),
                      Text(
                        subtitle,
                        style: context.typo.bodyMedium.copyWith(
                          fontWeight: AppFontWeights.regular,
                          color: context.color.grey600,
                        ),
                      ),
                    ],
                    Gap(Dimens.spacing.sp32),
                    Expanded(child: LoginForm(redirectTo: redirectTo)),
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
