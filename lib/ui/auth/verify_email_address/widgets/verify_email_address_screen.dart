import 'package:cleer/domain/models/confirm_user_attribute_result/confirm_user_attribute_result.dart';
import 'package:cleer/domain/models/update_user_attribute_result/update_user_attribute_result.dart';
import 'package:cleer/ui/auth/verify_email_address/view_model/verify_email_address_view_model.dart';
import 'package:cleer/ui/auth/verify_email_address/widgets/change_email_address_bottom_sheet.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/app_back_button.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/code_pinput.dart';
import 'package:cleer/ui/core/ui/resend_code_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VerifyEmailAddressScreen extends HookConsumerWidget {
  const VerifyEmailAddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(verifyEmailAddressViewModelProvider, (prev, next) {
      next.whenData((state) {
        // Handle Code Verification
        final confirmResult = state.confirmUserAttributeDomainResult;
        if (confirmResult != null) {
          confirmResult.maybeWhen(
            success: () {
              if (context.mounted) context.pop();
            },
            orElse: () => debugPrint('Confirm Result: $confirmResult'),
          );
        }

        // Handle Email Change
        final updateResult = state.updateUserAttributeDomainResult;
        if (updateResult != null) {
          updateResult.maybeWhen(
            success: () {
              // Only pop if Cognito says it's 100% done (rare, but good to handle)
              if (context.mounted) context.pop();
            },
            orElse: () => debugPrint('Update Result: $updateResult'),
          );
        }
      });
    });

    final codeController = useTextEditingController();
    useListenable(codeController);

    final state = ref.watch(verifyEmailAddressViewModelProvider);
    final viewModel = ref.read(verifyEmailAddressViewModelProvider.notifier);

    if (state.isLoading) {
      return Material(child: Center(child: CircularProgressIndicator()));
    }

    final codeDeliveryDetails = state.value!.codeDeliveryDetails;

    return Scaffold(
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
            Text(l10n.verifyEmailAddress),
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
                  l10n.enterVerificationCode(codeDeliveryDetails.destination!),
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp40),
                CodePinput(
                  controller: codeController,
                  hasError: state.hasError,
                  onCompleted: (code) {
                    if (code != null) {
                      viewModel.verifyEmailAddress(code);
                    }
                  },
                ),
                Gap(Dimens.spacing.sp48),
                Center(
                  child: ResendCodeTimer(
                    Duration(minutes: 1),
                    resendOtp: () => viewModel.resendCode(),
                  ),
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
                    onPressed: () =>
                        viewModel.verifyEmailAddress(codeController.text),
                    child: Text(l10n.verify),
                  ),
                  Gap(Dimens.spacing.sp16),
                  TextButton(
                    onPressed: () => ChangeEmailAddressBottomSheet.show(
                      context,
                      saveChanges: (String newEmail) {
                        context.pop();
                        viewModel.changeEmail(newEmail);
                      },
                    ),
                    child: Text(l10n.changeEmailAddress),
                  ),
                  Gap(Dimens.spacing.sp20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
