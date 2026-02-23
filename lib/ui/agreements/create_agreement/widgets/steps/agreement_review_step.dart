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
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
                  Gap(
                    formData?.disbursementType == .milestones
                        ? Dimens.spacing.sp5
                        : Dimens.spacing.sp12,
                  ),
                  if (formData?.disbursementType == .milestones)
                    Container(
                      margin: .only(bottom: Dimens.padding.p40),
                      color: context.color.transparent,
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        trailing: PhosphorIcon(
                          PhosphorIcons.caretDown(),
                          size: Dimens.size.s16,
                          color: context.color.blue700,
                        ),
                        tilePadding: .zero,
                        minTileHeight: 0,
                        visualDensity: .comfortable,
                        childrenPadding: .zero,
                        collapsedShape: Border(
                          bottom: BorderSide(
                            color: context.color.black.withValues(alpha: .10),
                          ),
                        ),
                        shape: Border(),
                        title: Text(
                          l10n.milestoneBreakdown,
                          style: context.typo.titleSmall.copyWith(
                            color: context.color.grey700,
                          ),
                        ),
                        children: List.generate(
                          formData?.milestones?.length ?? 0,
                          (int index) {
                            final milestone = formData?.milestones?[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: index == 0
                                      ? BorderSide(
                                          color: context.color.black.withValues(
                                            alpha: .10,
                                          ),
                                        )
                                      : .none,
                                ),
                              ),
                              padding: .only(top: Dimens.padding.p12),
                              child: Row(
                                children: [
                                  Container(
                                    width: Dimens.size.s16,
                                    height: Dimens.size.s16,
                                    decoration: BoxDecoration(
                                      shape: .circle,
                                      color: context.color.transparent,
                                      border: .all(
                                        color: context.color.outline,
                                      ),
                                    ),
                                  ),
                                  Gap(Dimens.spacing.sp8),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: .min,
                                      crossAxisAlignment: .start,
                                      children: [
                                        Text(
                                          "Milestone ${index + 1}",
                                          style: context.typo.bodyMedium
                                              .copyWith(
                                                fontWeight:
                                                    AppFontWeights.regular,
                                                color: context.color.grey600,
                                              ),
                                        ),
                                        Gap(Dimens.spacing.sp2),
                                        Row(
                                          mainAxisAlignment: .spaceBetween,
                                          children: [
                                            Text(
                                              milestone?.name ?? '',
                                              style: context.typo.bodyMedium
                                                  .copyWith(
                                                    fontWeight:
                                                        AppFontWeights.regular,
                                                  ),
                                            ),
                                            Text(
                                              "${l10n.nairaSign} ${NumberFormat('#,###.##').format(milestone?.amount)}",
                                              style: context.typo.labelMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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
                            Gap(Dimens.spacing.sp28),
                            Expanded(
                              child: Text(
                                "${l10n.nairaSign}${NumberFormat('#,###.##').format(double.parse(formData!.amount))}",
                                style: context.typo.labelMedium,
                                textAlign: .end,
                              ),
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
                            Gap(Dimens.spacing.sp28),
                            Expanded(
                              child: Text(
                                formData.recipientResolution!.accountName,
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                ),
                                textAlign: .end,
                                overflow: .ellipsis,
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
                            Gap(Dimens.spacing.sp28),
                            Expanded(
                              child: Text(
                                formData.recipientBank!.name,
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                ),
                                textAlign: .end,
                                overflow: .ellipsis,
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
                            Gap(Dimens.spacing.sp28),
                            Expanded(
                              child: Text(
                                formData.recipientAccountNumber,
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                ),
                                textAlign: .end,
                                overflow: .ellipsis,
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
                            Gap(Dimens.spacing.sp28),
                            Expanded(
                              child: Text(
                                formData.category!.label,
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                ),
                                textAlign: .end,
                                overflow: .ellipsis,
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
                            Gap(Dimens.spacing.sp28),
                            Expanded(
                              child: Text(
                                '',
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                ),
                                textAlign: .end,
                                overflow: .ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (formData.disbursementType == .oneTime)
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
                              Gap(Dimens.spacing.sp28),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(formData.releaseDate!),
                                  style: context.typo.bodyMedium.copyWith(
                                    fontWeight: AppFontWeights.regular,
                                  ),
                                  textAlign: .end,
                                  overflow: .ellipsis,
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
                        ),
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
