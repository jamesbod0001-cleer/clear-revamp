import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class AgreementReviewStep extends HookConsumerWidget {
  const AgreementReviewStep({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(createAgreementViewModelProvider(type));
    final viewModel = ref.read(createAgreementViewModelProvider(type).notifier);
    final formData = state.value?.formData;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;

        // If didPop is false, we are on Step 2 or 3.
        // Just move the internal state back.
        viewModel.moveStepBack();
      },
      child: Form(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Gap(Dimens.spacing.sp12),
                  Container(
                    padding: .all(Dimens.padding.p12),
                    decoration: BoxDecoration(
                      color: context.color.blue100,
                      borderRadius: .circular(Dimens.radius.r8),
                    ),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      spacing: Dimens.spacing.sp24,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              '${l10n.amountToBeHeld}:',
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey600,
                              ),
                            ),
                            Text(
                              "${l10n.nairaSign}${NumberFormat('#,###.##').format(double.parse(formData!.amount))}",
                              style: context.typo.labelMedium,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              l10n.accountName,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey600,
                              ),
                            ),
                            Text(
                              formData.recipientResolution!.accountName,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              l10n.bankName,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey600,
                              ),
                            ),
                            Text(
                              formData.recipientBank!.name,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              l10n.accountNumber,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey600,
                              ),
                            ),
                            Text(
                              formData.recipientAccountNumber,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              l10n.category,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey600,
                              ),
                            ),
                            Text(
                              formData.category!.label,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              "${l10n.fees}:",
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey600,
                              ),
                            ),
                            Text(
                              '',
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              l10n.fundsReleaseDate,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey600,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy').format(formData.releaseDate!),
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: context.color.background,
                          height: Dimens.size.s1,
                          thickness: Dimens.size.s1,
                        ),
                        Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              l10n.description,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey600,
                              ),
                            ),
                            Gap(Dimens.spacing.sp4),
                            Text(
                              formData.description,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                              ),
                            ),
                          ],
                        )
                      ],
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
                      onPressed: () => viewModel.initiateAgreement(),
                      child: Text(l10n.confirmAndPay),
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
