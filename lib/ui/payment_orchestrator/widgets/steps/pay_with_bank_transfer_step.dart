import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PayWithBankTransferStep extends HookConsumerWidget {
  const PayWithBankTransferStep({super.key, required this.agreementId});
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
    final viewModel = ref.read(
      paymentOrchestratorViewModelProvider(agreementId).notifier,
    );

    final generateVirtualAccountCommand = viewModel.generateVirtualAccount;
    useEffect(() {
      Future.microtask(() async {
        generateVirtualAccountCommand.clearErrors();
        await generateVirtualAccountCommand.runAsync();
      });

      void listener() {
        if (generateVirtualAccountCommand.errors.value != null) {
          debugPrint(
            "Command Error: ${generateVirtualAccountCommand.errors.value?.error}",
          );
        }
      }

      generateVirtualAccountCommand.errors.addListener(listener);

      return () =>
          generateVirtualAccountCommand.errors.removeListener(listener);
    }, []);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;
        viewModel.changePaymentMethod(); // Going back to change payment method
      },
      child: Column(
        children: [
          StepHeader(title: l10n.payWithBankTransfer),
          Gap(Dimens.spacing.sp40),
          ValueListenableBuilder<bool>(
            valueListenable: viewModel.generateVirtualAccount.isRunning,
            builder: (context, isRunning, _) {
              final virtualAccount = state.value!.ongoingVirtualAccount;
              return Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: .symmetric(
                          horizontal: Dimens.padding.p20,
                          vertical: Dimens.padding.p16,
                        ),
                        decoration: BoxDecoration(
                          color: context.color.infoLight,
                          borderRadius: .circular(Dimens.radius.r15),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Text(
                                  l10n.amount,
                                  style: context.typo.bodyMedium.copyWith(
                                    fontWeight: AppFontWeights.regular,
                                    color: context.color.grey800,
                                  ),
                                ),
                                Text(
                                  "${l10n.ngn} ${NumberFormat('#,###.##').format(virtualAccount?.amount ?? 0)}",
                                  style: context.typo.labelMedium,
                                ),
                              ],
                            ),
                            Gap(Dimens.spacing.sp20),
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Text(
                                  l10n.bankName,
                                  style: context.typo.bodyMedium.copyWith(
                                    fontWeight: AppFontWeights.regular,
                                    color: context.color.grey800,
                                  ),
                                ),
                                Text(
                                  virtualAccount?.bankName ?? '',
                                  style: context.typo.labelMedium,
                                ),
                              ],
                            ),
                            Gap(Dimens.spacing.sp20),
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Text(
                                  l10n.accountNumber,
                                  style: context.typo.bodyMedium.copyWith(
                                    fontWeight: AppFontWeights.regular,
                                    color: context.color.grey800,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: .min,
                                  children: [
                                    Text(
                                      virtualAccount?.accountNumber ?? '',
                                      style: context.typo.labelMedium,
                                    ),
                                    Gap(Dimens.spacing.sp8),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: context.color.blue700,
                                        padding: .symmetric(
                                          vertical: Dimens.padding.p4,
                                        ),
                                        tapTargetSize: .shrinkWrap,
                                        visualDensity: .compact,
                                        minimumSize: .zero,
                                      ),
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text:
                                                virtualAccount?.accountNumber ??
                                                '',
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: .min,
                                        children: [
                                          PhosphorIcon(
                                            PhosphorIcons.copySimple(.fill),
                                            // color: context.color.blue700,
                                            size: Dimens.size.s16,
                                          ),
                                          Gap(Dimens.spacing.sp2),
                                          Text(
                                            l10n.copy,
                                            style: context.typo.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Gap(Dimens.spacing.sp32),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.color.grey800,
                          padding: .symmetric(vertical: Dimens.padding.p12),
                          tapTargetSize: .shrinkWrap,
                          visualDensity: .compact,
                        ),
                        onPressed: () => viewModel.verifyTransaction(),
                        child: Text(l10n.iHaveSentTheMoney),
                      ),
                    ],
                  ),
                  if (isRunning)
                    Positioned.fill(
                      child: Material(
                        color: context.color.background,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              );
            },
          ),
          Gap(Dimens.spacing.sp54),
        ],
      ),
    );
  }
}
