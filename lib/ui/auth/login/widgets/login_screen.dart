import 'package:cleer/domain/models/sign_in_result/sign_in_result.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/ui/auth/login/view_model/login_view_model.dart';
import 'package:cleer/ui/auth/login/widgets/login_form.dart';
import 'package:cleer/ui/auth/verify_phone_number/models/verification_details.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
            VerifyPhoneRoute($extra: details).push(context);
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
                    Text(l10n.welcomeBack, style: context.typo.headlineSmall),
                    Gap(Dimens.spacing.sp12),
                    Text(
                      l10n.pickUpWhereYouLeftOff,
                      style: context.typo.labelSmall.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp32),
                    Expanded(child: LoginForm()),
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
