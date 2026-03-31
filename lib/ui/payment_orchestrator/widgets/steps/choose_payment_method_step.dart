import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/buttons.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/cancel_agreement_bottom_sheet.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/step_header.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChoosePaymentMethodStep extends ConsumerWidget {
  const ChoosePaymentMethodStep({super.key, required this.agreementId});
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
    final viewModel = ref.read(
      paymentOrchestratorViewModelProvider(agreementId).notifier,
    );

    final methods = [
      _PaymentMethod(
        icon: PhosphorIcon(
          PhosphorIcons.creditCard(.duotone),
          color: context.color.blue700,
        ),
        label: l10n.payWithCard,
        onTap: () => viewModel.goTo(.enterCardDetails),
      ),
      _PaymentMethod(
        icon: PhosphorIcon(
          PhosphorIcons.hash(.duotone),
          color: context.color.blue700,
        ),
        label: l10n.payWithUSSD,
        onTap: () => viewModel.goTo(.payWithUSSD),
      ),
      _PaymentMethod(
        icon: PhosphorIcon(
          PhosphorIcons.bank(.duotone),
          color: context.color.blue700,
        ),
        label: l10n.payWithBankTransfer,
        onTap: () => viewModel.goTo(.payWithBankTransfer),
      ),
      _PaymentMethod(
        icon: Assets.icons.opayLogo.svg(width: Dimens.size.s20),
        label: l10n.payWithOpay,
        onTap: viewModel.payWithOpay,
      ),
    ];

    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Column(
            children: [
              StepHeader(title: l10n.secureYourPayment),
              Gap(Dimens.spacing.sp40),
              ...methods.map(
                (method) => Padding(
                  padding: EdgeInsets.only(bottom: Dimens.spacing.sp12),
                  child: _PaymentMethodTile(method: method),
                ),
              ),
              Gap(Dimens.spacing.sp46),
              CancelPaymentButton(
                onPressed: () => CancelAgreementBottomSheet.show(
                  context,
                  agreement: state.value!.agreement,
                  onCancelAgreement: () => viewModel.cancelAgreement(),
                ),
              ),
            ],
          ),
          if (state.isLoading)
            Positioned.fill(
              child: Container(
                color: context.color.background,
                alignment: .center,
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _PaymentMethod({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.method});

  final _PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: .antiAlias,
      color: context.color.grayComponent,
      borderRadius: .circular(Dimens.radius.r8),
      child: InkWell(
        onTap: method.onTap,
        child: Padding(
          padding: .all(Dimens.padding.p12),
          child: Row(
            children: [
              method.icon,
              Gap(Dimens.spacing.sp8),
              Text(
                method.label,
                style: context.typo.bodyMedium.copyWith(
                  color: context.color.grey800,
                  fontWeight: AppFontWeights.regular,
                ),
              ),
              const Spacer(),
              PhosphorIcon(
                PhosphorIcons.caretRight(),
                color: context.color.blue700,
                size: Dimens.size.s20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class ChoosePaymentMethodStep extends ConsumerWidget {
//   const ChoosePaymentMethodStep({super.key, required this.agreementId});
//   final String agreementId;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final l10n = AppLocalizations.of(context)!;
//
//     final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
//     final viewModel = ref.read(
//       paymentOrchestratorViewModelProvider(agreementId).notifier,
//     );
//
//     return Column(
//       children: [
//         Column(
//           children: [
//             Text(l10n.secureYourPayment, style: context.typo.headlineSmall),
//             Gap(Dimens.spacing.sp12),
//             Row(
//               mainAxisAlignment: .center,
//               children: [
//                 PhosphorIcon(
//                   PhosphorIcons.lockKey(.duotone),
//                   color: context.color.grey600,
//                   size: Dimens.size.s16,
//                 ),
//                 Gap(Dimens.spacing.sp4),
//                 Text(
//                   l10n.securedBy,
//                   style: context.typo.bodySmall.copyWith(
//                     color: context.color.grey600,
//                   ),
//                 ),
//                 Gap(Dimens.spacing.sp8),
//                 Assets.images.flutterwaveLogoWordmark.image(
//                   height: Dimens.size.s16,
//                   width: Dimens.size.s101,
//                 ),
//               ],
//             ),
//           ],
//         ),
//         Gap(Dimens.spacing.sp40),
//         Column(
//           spacing: Dimens.spacing.sp12,
//           children: List.generate(PaymentMethodType.values.length, (int index) {
//             List<Widget> icons = [
//               PhosphorIcon(
//                 PhosphorIcons.creditCard(.duotone),
//                 color: context.color.blue700,
//                 size: Dimens.size.s20,
//               ),
//               Assets.icons.opayLogo.svg(
//                 width: Dimens.size.s20,
//                 height: Dimens.size.s19,
//               ),
//             ];
//             List<String> labels = [l10n.payWithCard, l10n.payWithOpay];
//             List<VoidCallback> onPressed = [
//               () => throw UnimplementedError(),
//               () => viewModel.payWithOpay(),
//             ];
//             return Material(
//               clipBehavior: .antiAlias,
//               color: context.color.grayComponent,
//               borderRadius: .circular(Dimens.radius.r8),
//               child: InkWell(
//                 onTap: onPressed[index],
//                 child: Padding(
//                   padding: .all(Dimens.padding.p12),
//                   child: Row(
//                     children: [
//                       icons[index],
//                       Gap(Dimens.spacing.sp8),
//                       Text(
//                         labels[index],
//                         style: context.typo.bodyMedium.copyWith(
//                           color: context.color.grey800,
//                           fontWeight: AppFontWeights.regular,
//                         ),
//                       ),
//                       const Spacer(),
//                       PhosphorIcon(
//                         PhosphorIcons.caretRight(),
//                         color: context.color.blue700,
//                         size: Dimens.size.s20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),
//         Gap(Dimens.spacing.sp46),
//         Center(child: CancelPaymentButton(onPressed: () {})),
//       ],
//     );
//   }
// }
