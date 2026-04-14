import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/status_circle_icon.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaymentNotSecuredStep extends ConsumerWidget {
  const PaymentNotSecuredStep({super.key, required this.agreementId});

  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
    // final viewModel = ref.read(
    //   paymentOrchestratorViewModelProvider(agreementId).notifier,
    // );
    return PopScope(
      canPop: false,
      child: Center(
        heightFactor: 1.5,
        child: Column(
          mainAxisSize: .min,
          children: [
            StatusCircleIcon(type: .error),
            Gap(Dimens.spacing.sp48),
            Text(
              l10n.paymentCouldNotBeSecured,
              style: context.typo.headlineSmall,
            ),
            Gap(Dimens.spacing.sp12),
            Text(
              l10n.weCouldNotSecureYourPaymentNoMoneyHasBeenHeldOrTransferred,
              style: context.typo.bodyMedium.copyWith(
                color: context.color.grey600,
              ),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
