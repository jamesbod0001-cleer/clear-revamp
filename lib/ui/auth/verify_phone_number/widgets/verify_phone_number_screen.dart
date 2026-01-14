import 'package:cleer/domain/models/sign_up_result/sign_up_result.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/ui/auth/verify_phone_number/models/verification_details.dart';
import 'package:cleer/ui/auth/verify_phone_number/view_model/verify_phone_number_view_model.dart';
import 'package:cleer/ui/auth/verify_phone_number/widgets/code_pinput.dart';
import 'package:cleer/ui/auth/verify_phone_number/widgets/resend_code_timer.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

class VerifyPhoneNumberScreen extends HookConsumerWidget {
  const VerifyPhoneNumberScreen({super.key, required this.details});
  final VerificationDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final codeController = useTextEditingController();
    useListenable(codeController);
    final viewmodel = ref.read(verifyPhoneNumberViewModelProvider.notifier);

    ref.listen(verifyPhoneNumberViewModelProvider, (prev, next) {
      next.whenData((signUpDomainResult) {
        if (signUpDomainResult == null) return;

        signUpDomainResult.when(
          success: () {
            CreatePasswordRoute(phoneNumber: details.username).push(context);
          },
          confirmationRequired: (String destination, String deliveryMedium) {
            VerifyPhoneRoute($extra: details).push(context);
          },
        );
      });
    });

    final bool viewModelsLoading = ref
        .watch(verifyPhoneNumberViewModelProvider)
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
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Gap(Dimens.spacing.sp16),
                    AppBackButton(),
                    Gap(Dimens.spacing.sp24),
                    Text(
                      l10n.verifyPhoneNumber,
                      style: context.typo.headlineSmall,
                    ),
                    Gap(Dimens.spacing.sp12),
                    Text(
                      l10n.weSentA6DigitCodeToYourPhoneForVerification,
                      style: context.typo.labelSmall.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp80),
                    CodePinput(
                      controller: codeController,
                      onCompleted: (code) {
                        if (code != null) {
                          viewmodel.verifyPhoneNumber(details.username, code);
                        }
                      },
                    ),
                    Gap(Dimens.spacing.sp48),
                    Center(
                      child: ResendCodeTimer(
                        Duration(minutes: 1),
                        resendOtp: () => viewmodel.resendCode(details.username),
                      ),
                    ),
                    const Spacer(),
                    Gap(Dimens.spacing.sp40),
                    FilledButton(
                      onPressed: codeController.length == 6
                          ? () => viewmodel.verifyPhoneNumber(
                              details.username,
                              codeController.text,
                            )
                          : null,
                      child: Text(l10n.verifyPhoneNumber),
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
