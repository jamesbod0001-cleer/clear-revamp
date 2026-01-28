import 'package:cleer/domain/failures/auth_failures.dart';
import 'package:cleer/domain/models/reset_password_result/reset_password_result.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/create_password/widgets/password_validation_checklist.dart';
import 'package:cleer/ui/auth/forgot_password/state/forgot_password_state.dart';
import 'package:cleer/ui/auth/forgot_password/view_model/forgot_password_view_model.dart';
import 'package:cleer/ui/core/localization/error_messages.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/app_back_button.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/ui/core/ui/form_error.dart';
import 'package:cleer/ui/core/ui/offline_warning_banner.dart';
import 'package:cleer/utils/validators/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'request_code_step.dart';
part 'reset_password_step.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(forgotPasswordViewModelProvider, (prev, next) {
      next.whenData((state) {
        if (state.resetPasswordDomainResult !=
            prev?.value?.resetPasswordDomainResult) {
          state.resetPasswordDomainResult?.maybeWhen(
            success: () {
              LoginRoute().pushReplacement(context);
            },
            orElse: () {},
          );
        }
        return;
      });
    });

    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);
    final state = ref.watch(forgotPasswordViewModelProvider);

    final currentStep =
        state.value?.forgotPasswordStep ?? ForgotPasswordStep.requestCode;
    final bool isFirstStep = currentStep == ForgotPasswordStep.requestCode;

    Widget getCurrentStepWidget() {
      final ForgotPasswordStep currentStep = state.value!.forgotPasswordStep;
      return switch (currentStep) {
        ForgotPasswordStep.requestCode => _RequestCodeStep(
          key: ValueKey(currentStep),
        ),
        ForgotPasswordStep.resetPassword => _ResetPasswordStep(
          key: ValueKey(currentStep),
        ),
      };
    }

    void handleBack() {
      if (isFirstStep) {
        context.pop();
      } else {
        viewModel.moveStepBack();
      }
    }

    final bool isLoading = ref.watch(forgotPasswordViewModelProvider).isLoading;

    return PopScope(
      canPop: isFirstStep,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;

        // If didPop is false, we are on Step 2 or 3.
        // Just move the internal state back.
        viewModel.moveStepBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Gap(Dimens.spacing.sp24),
                          AppBackButton(onPressed: () => handleBack()),
                          Gap(Dimens.spacing.sp24),
                          OfflineWarningBanner(),
                          Text(
                            l10n.forgotPassword,
                            style: context.typo.headlineSmall,
                          ),
                          Gap(Dimens.spacing.sp8),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: getCurrentStepWidget(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                Positioned.fill(
                  child: Material(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
