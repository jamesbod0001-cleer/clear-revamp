import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ContinueWithOpayStep extends ConsumerWidget {
  const ContinueWithOpayStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentOrchestratorViewModelProvider);
    final viewModel = ref.read(paymentOrchestratorViewModelProvider.notifier);
    return Column(
      children: [
        Column(
          children: [
            Text(l10n.continueWithOpay, style: context.typo.headlineSmall),
            Gap(Dimens.spacing.sp12),
            Row(
              mainAxisAlignment: .center,
              children: [
                PhosphorIcon(
                  PhosphorIcons.lockKey(.duotone),
                  color: context.color.grey600,
                  size: Dimens.size.s16,
                ),
                Gap(Dimens.spacing.sp4),
                Text(
                  l10n.securedBy,
                  style: context.typo.bodySmall.copyWith(
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp8),
                Assets.images.flutterwaveLogoWordmark.image(
                  height: Dimens.size.s16,
                  width: Dimens.size.s101,
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            Column(
              children: [
                Gap(Dimens.spacing.sp84),
                Column(
                  mainAxisSize: .min,
                  children: [
                    Assets.icons.opayLogoWordmark.svg(height: Dimens.size.s32),
                    Gap(Dimens.spacing.sp24),
                    Text(
                      l10n.youllBeRedirectedToAuthorizeThisPayment,
                      style: context.typo.bodyLarge.copyWith(
                        color: context.color.grey600,
                      ),
                      textAlign: .center,
                    ),
                    Gap(Dimens.spacing.sp24),
                    PrimaryButton(
                      onPressed: () {},
                      child: Text(l10n.continueWithOpay),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp103),
                Column(
                  mainAxisSize: .min,
                  children: [
                    ChangePaymentMethodButton(
                      onPressed: () => viewModel.changePaymentMethod(),
                    ),
                    Gap(Dimens.spacing.sp16),
                    CancelPaymentButton(onPressed: () {}),
                  ],
                ),
              ],
            ),
            if (state.isLoading)
              Positioned.fill(
                child: Material(
                  child: Center(
                    child: SizedBox.square(
                      dimension: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: Dimens.size.s8,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
