import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer_core/models/sign_in_result/sign_in_result.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/accept_agreement/view_model/accept_agreement_view_model.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/ui/auth/login/view_model/login_view_model.dart';
import 'package:cleer/ui/auth/login/widgets/login_form.dart';
import 'package:cleer/ui/auth/widgets/auth_responsive_layout.dart';
import 'package:cleer/ui/auth/verify_phone_number/models/verification_details.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
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

    final isDisconnected = ref
        .watch(connectionStatusProvider)
        .maybeWhen(
          data: (status) => status.isDisconnected,
          orElse: () => false,
        );

    if (isLoading) {
      return Material(child: Center(child: CircularProgressIndicator()));
    }

    return AuthResponsiveLayout(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Gap(
                      context.isMobile
                          ? Dimens.spacing.sp16
                          : Dimens.spacing.sp56,
                    ),
                    AppBackButton(
                      onPressed: context.isAtLeastTablet
                          ? () => CreateAccountRoute(
                              redirectTo: redirectTo,
                            ).pushReplacement(context)
                          : null,
                    ),
                    Gap(
                      context.isMobile
                          ? Dimens.spacing.sp24
                          : Dimens.spacing.sp52,
                    ),
                    OfflineWarningBanner(isDisconnected: isDisconnected),
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
