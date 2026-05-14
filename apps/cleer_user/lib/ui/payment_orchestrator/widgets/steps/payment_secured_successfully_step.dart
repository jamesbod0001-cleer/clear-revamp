import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/status_circle_icon.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class PaymentSecuredSuccessfullyStep extends ConsumerWidget {
  const PaymentSecuredSuccessfullyStep({super.key, required this.agreementId});
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
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
            StatusCircleIcon(type: .successOutlined),
            Gap(Dimens.spacing.sp48),
            Text(
              l10n.paymentSecuredSuccessfully,
              style: context.typo.headlineSmall,
            ),
            Gap(Dimens.spacing.sp12),
            Text(
              l10n.fundsHeldSecurely(
                'NGN ${NumberFormat('#,###.##').format(state.value!.agreement.amount)}',
              ),
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
