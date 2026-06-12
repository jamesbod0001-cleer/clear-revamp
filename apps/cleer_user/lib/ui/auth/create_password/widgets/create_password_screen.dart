import 'package:cleer/domain/providers/network/network_provider.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/ui/auth/create_password/view_model/create_password_view_model.dart';
import 'package:cleer/ui/auth/create_password/widgets/password_validation_checklist.dart';
import 'package:cleer/ui/auth/widgets/auth_responsive_layout.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/custom_text_form_field.dart';
import 'package:cleer_ui/widgets/offline_warning_banner.dart';
import 'package:cleer_ui/widgets/step_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreatePasswordScreen extends HookConsumerWidget {
  const CreatePasswordScreen({
    super.key,
    required this.phoneNumber,
    this.redirectTo,
  });

  final String phoneNumber;
  final String? redirectTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController passwordController = useTextEditingController();
    final TextEditingController confirmPasswordController =
        useTextEditingController();
    final checklistIsMet = useState(false);
    useListenable(passwordController);
    useListenable(confirmPasswordController);

    final bool viewModelsLoading = ref
        .watch(createPasswordViewModelProvider)
        .isLoading;

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
              child: Padding(
                padding: Dimens.of(context).edgeInsetsScreenHorizontal,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Gap(
                      context.isMobile
                          ? Dimens.spacing.sp16
                          : Dimens.spacing.sp56,
                    ),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        AppBackButton(),
                        StepProgressIndicator(currentStep: 3),
                      ],
                    ),
                    Gap(
                      context.isMobile
                          ? Dimens.spacing.sp24
                          : Dimens.spacing.sp52,
                    ),
                    OfflineWarningBanner(isDisconnected: isDisconnected),
                    Text(
                      l10n.createYourPassword,
                      style: context.typo.headlineSmall,
                    ),
                    Gap(Dimens.spacing.sp8),
                    Text(
                      l10n.createAPasswordToProtectYourAccount,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp32),
                    CustomTextFormField(
                      controller: passwordController,
                      labelText: l10n.enterPassword,
                      isPassword: true,
                    ),
                    Gap(Dimens.spacing.sp20),
                    CustomTextFormField(
                      controller: confirmPasswordController,
                      labelText: l10n.confirmPassword,
                      isPassword: true,
                      validator: (value) {
                        final confirmPassword = value ?? '';
                        if (confirmPassword.isEmpty) {
                          return l10n.pleaseEnterYourPassword;
                        }
                        if (passwordController.text != confirmPassword) {
                          return l10n.passwordDoesNotMatch;
                        }
                        return null;
                      },
                    ),
                    Gap(Dimens.spacing.sp28),
                    PasswordValidationChecklist(
                      passwordController: passwordController,
                      isPasswordValid: (valid) => checklistIsMet.value = valid,
                    ),
                    const Spacer(),
                    Gap(Dimens.spacing.sp40),
                    FilledButton(
                      onPressed:
                          (checklistIsMet.value &&
                              passwordController.text ==
                                  confirmPasswordController.text &&
                              confirmPasswordController.text.isNotEmpty)
                          ? () => ref
                                .read(createPasswordViewModelProvider.notifier)
                                .createPassword(
                                  phoneNumber: phoneNumber,
                                  password: passwordController.text,
                                )
                          : null,
                      child: Text(l10n.createPassword),
                    ),
                    Gap(context.isMobile ? Dimens.spacing.sp20 : Dimens.spacing.sp32),
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
