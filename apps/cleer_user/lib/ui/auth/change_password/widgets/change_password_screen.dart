import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/update_password_result/update_password_result.dart';
import 'package:cleer/ui/auth/change_password/view_model/change_password_view_model.dart';
import 'package:cleer/ui/auth/create_password/widgets/password_validation_checklist.dart';
import 'package:cleer/ui/core/localization/error_messages.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer_ui/widgets/custom_text_form_field.dart';
import 'package:cleer_ui/widgets/form_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangePasswordScreen extends HookConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(changePasswordViewModelProvider, (prev, next) {
      next.whenData((result) {
        if (result == null) return;

        result.maybeWhen(
          success: () {
            context.pop();
          },
          orElse: () {
            debugPrint(result.runtimeType.toString());
          },
        );
      });
    });

    final state = ref.watch(changePasswordViewModelProvider);
    final viewModel = ref.read(changePasswordViewModelProvider.notifier);

    final TextEditingController oldPasswordController =
        useTextEditingController();
    final TextEditingController newPasswordController =
        useTextEditingController();
    final TextEditingController confirmNewPasswordController =
        useTextEditingController();
    final checklistIsMet = useState(false);
    useListenable(oldPasswordController);
    useListenable(newPasswordController);
    useListenable(confirmNewPasswordController);

    if (state.isLoading) {
      return Material(child: Center(child: CircularProgressIndicator()));
    }

    return AppOfflineBannerWrapper(
      child: Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: .start,
          children: [
            Gap(Dimens.spacing.sp12),
            AppBackButton(),
            Gap(Dimens.spacing.sp24),
            Text(l10n.changePassword),
          ],
        ),
        toolbarHeight: 102,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
              top: Dimens.padding.p4,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  l10n.manageYourPersonalDetailsAndLoginSecurity,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp40),
                FormError(
                  hasError: state.hasError,
                  errorMessage: state.error != null
                      ? getAuthErrorMessage(state.error as AuthFailure, context)
                      : null,
                ),
                CustomTextFormField(
                  controller: oldPasswordController,
                  labelText: l10n.oldPassword,
                  isPassword: true,
                ),
                Gap(Dimens.spacing.sp20),
                CustomTextFormField(
                  controller: newPasswordController,
                  labelText: l10n.newPassword,
                  isPassword: true,
                ),
                Gap(Dimens.spacing.sp20),
                CustomTextFormField(
                  controller: confirmNewPasswordController,
                  labelText: l10n.confirmPassword,
                  isPassword: true,
                  validator: (value) {
                    final confirmPassword = value ?? '';
                    if (confirmPassword.isEmpty) {
                      return l10n.pleaseEnterYourPassword;
                    }
                    if (newPasswordController.text != confirmPassword) {
                      return l10n.passwordDoesNotMatch;
                    }
                    return null;
                  },
                ),
                Gap(Dimens.spacing.sp28),
                PasswordValidationChecklist(
                  passwordController: newPasswordController,
                  isPasswordValid: (valid) => checklistIsMet.value = valid,
                ),
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  Gap(Dimens.spacing.sp30),
                  PrimaryButton(
                    onPressed:
                        (checklistIsMet.value &&
                            newPasswordController.text ==
                                confirmNewPasswordController.text &&
                            confirmNewPasswordController.text.isNotEmpty &&
                            oldPasswordController.text.isNotEmpty)
                        ? () => viewModel.changePassword(
                            oldPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                          )
                        : null,
                    child: Text(l10n.saveChanges),
                  ),
                  Gap(Dimens.spacing.sp20),
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
