import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/dynamic_agreement_header.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/domain/providers/milestone/milestone_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/agreement_details/view_model/agreement_details_view_model.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/agreement_timeline.dart';
import 'package:cleer/ui/agreements/extensions/agreement_ui_extensions.dart';
import 'package:cleer/ui/core/extensions/string_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/status_circle_icon.dart';
import 'package:cleer_ui/widgets/menu_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AgreementDetailsScreen extends ConsumerWidget {
  const AgreementDetailsScreen({
    super.key,
    required this.agreementId,
    this.initialAgreement,
  });

  final String agreementId;
  final Agreement? initialAgreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProfileProvider).value;

    final state = ref.watch(agreementDetailsViewModelProvider(agreementId));

    final agreement = state.value ?? initialAgreement;

    if (agreement == null && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (agreement == null && state.hasError) {
      /// TODO: Show proper error here
      return SizedBox.shrink();
    }

    if ((agreement!.status == AgreementStatus.awaitingRecipient ||
            agreement.status == AgreementStatus.awaitingFunding) &&
        agreement.initiator?.id != user?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AcceptAgreementRoute(shortCode: agreement.shortCode).go(context);
      });
      return const Center(child: CircularProgressIndicator());
    }

    Milestone? currentlyRunning;
    AsyncValue<List<Milestone>>? milestonesState;
    if (agreement.disbursementType == .milestones) {
      milestonesState = ref.watch(agreementMilestonesProvider(agreement.id!));
      currentlyRunning = milestonesState!.value?.currentlyRunning;
    }

    DateTime? dueDate = agreement.dueDate(currentlyRunning: currentlyRunning);

    final agreementStatusHistoryState = ref.watch(
      agreementStatusHistoryProvider(agreement.id!),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: .start,
          children: [
            Gap(Dimens.spacing.sp15),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                AppBackButton(),
                if (![
                  AgreementStatus.awaitingFunding,
                  AgreementStatus.awaitingRecipient,
                ].contains(agreement.status))
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: context.color.errorLight,
                      foregroundColor: context.color.error,
                      side: BorderSide(color: Color(0xFFEED8D8)),
                      textStyle: context.typo.bodyMedium.copyWith(height: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(Dimens.radius.r40),
                      ),
                      minimumSize: .zero,
                      padding: .symmetric(
                        horizontal: Dimens.padding.p10,
                        vertical: Dimens.padding.p8,
                      ),
                      tapTargetSize: .shrinkWrap,
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.warning(.duotone),
                          size: Dimens.size.s16,
                        ),
                        Gap(Dimens.spacing.sp4),
                        Text(l10n.reportIssue),
                      ],
                    ),
                  ),
              ],
            ),
            Gap(Dimens.spacing.sp22),
            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Gap(Dimens.spacing.sp2),
                      Text(
                        '${l10n.nairaSign}${NumberFormat('#,###.##').format(agreement.amount)}',
                        style: context.typo.headlineMedium.copyWith(
                          color: context.color.grey800,
                        ),
                      ),
                      Gap(Dimens.spacing.sp6),
                      Text(
                        agreement.getDisplayTitle(context, currentUser: user),
                        style: context.typo.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(Dimens.spacing.sp12),
                      Row(
                        mainAxisSize: .min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: agreement.getStatusPillColor(context),
                              borderRadius: BorderRadius.circular(
                                Dimens.radius.r20,
                              ),
                            ),
                            padding: .symmetric(
                              horizontal: Dimens.padding.p6,
                              vertical: Dimens.padding.p3,
                            ),
                            child: Text(
                              agreement.getStatusText(context),
                              style: context.typo.bodySmall.copyWith(
                                color: agreement.getStatusTextColor(context),
                              ),
                            ),
                          ),
                          Gap(Dimens.spacing.sp8),
                          Text(
                            l10n.dueDate(
                              dueDate != null
                                  ? DateFormat('d MMM').format(dueDate)
                                  : '',
                            ),
                            style: context.typo.bodySmall.copyWith(
                              color: context.color.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Gap(Dimens.spacing.sp24),
                StatusCircleIcon(type: .handshake),
              ],
            ),
          ],
        ),
        toolbarHeight: 216,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Gap(Dimens.spacing.sp30),
                      DynamicAgreementHeader(
                        agreement: agreement,
                        currentUser: user,
                      ),
                      if ([
                        AgreementStatus.awaitingFunding,
                        AgreementStatus.awaitingRecipient,
                      ].contains(agreement.status)) ...[
                        Gap(Dimens.spacing.sp24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                agreement.shareLink,
                                style: context.typo.labelMedium.copyWith(
                                  color: context.color.blue700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Gap(Dimens.spacing.sp16),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Color(
                                  0xFF99D2AE,
                                ).withValues(alpha: .20),
                                padding: .symmetric(
                                  horizontal: Dimens.padding.p10,
                                  vertical: Dimens.padding.p6,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: .zero,
                              ),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: agreement.shareLink),
                                );
                              },
                              child: Row(
                                mainAxisSize: .min,
                                children: [
                                  PhosphorIcon(
                                    PhosphorIcons.copySimple(.fill),
                                    color: context.color.green900,
                                    size: Dimens.size.s16,
                                  ),
                                  Gap(Dimens.spacing.sp4),
                                  Text(
                                    l10n.copy,
                                    style: context.typo.bodyMedium.copyWith(
                                      color: context.color.green900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Gap(
                          agreement.category == .physicalGoods
                              ? Dimens.spacing.sp24
                              : Dimens.spacing.sp16,
                        ),
                      ] else
                        Gap(Dimens.spacing.sp48),
                      agreementStatusHistoryState.maybeWhen(
                        /// TODO: Show proper error here
                        error: (error, stackTrace) => SizedBox.shrink(),
                        orElse: () {
                          bool isLoading =
                              agreementStatusHistoryState.isLoading;
                          return Skeletonizer(
                            enabled: isLoading,
                            child: AgreementTimeline(
                              agreement: agreement,
                              statusHistory:
                                  agreementStatusHistoryState.value ?? [],
                              milestones:
                                  agreement.disbursementType ==
                                      DisbursementType.milestones
                                  ? milestonesState!.value
                                  : null,
                            ),
                          );
                        },
                      ),
                      Gap(Dimens.spacing.sp40),
                      MenuSectionHeader(title: l10n.agreementDetails),
                      Column(
                        crossAxisAlignment: .stretch,
                        spacing: Dimens.spacing.sp24,
                        children: [
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                '${l10n.fundsWillBeSentTo}:',
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                  color: context.color.grey600,
                                ),
                              ),
                              Gap(Dimens.spacing.sp28),
                              Expanded(
                                child: Text(
                                  '${agreement.payoutDestination?.bankName} - ${agreement.payoutDestination?.accountName}',
                                  style: context.typo.bodyMedium.copyWith(
                                    fontWeight: AppFontWeights.regular,
                                  ),
                                  maxLines: 2,
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
                                  agreement.sender?.id == user?.id
                                      ? agreement
                                                .payoutDestination
                                                ?.accountNumber
                                                .maskAccountNumber ??
                                            ''
                                      : agreement
                                                .payoutDestination
                                                ?.accountNumber ??
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
                                  agreement.category.label,
                                  style: context.typo.bodyMedium.copyWith(
                                    fontWeight: AppFontWeights.regular,
                                  ),
                                  textAlign: .end,
                                  overflow: .ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (agreement.disbursementType == .oneTime)
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
                                    ).format(agreement.expectedReleaseDate!),
                                    style: context.typo.bodyMedium.copyWith(
                                      fontWeight: AppFontWeights.regular,
                                    ),
                                    textAlign: .end,
                                    overflow: .ellipsis,
                                  ),
                                ),
                              ],
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
                                agreement.description,
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Gap(Dimens.spacing.sp40),
                      // PrimaryButton(
                      //   onPressed:
                      //       ((agreement.sender?.id == user?.id)
                      //           ? [
                      //               AgreementStatus.readyForRelease,
                      //             ].contains(agreement.status)
                      //           : [
                      //               AgreementStatus.inProgress,
                      //             ].contains(agreement.status))
                      //       ? () {}
                      //       : null,
                      //   child: Text(
                      //     agreement.sender?.id == user?.id
                      //         ? l10n.releaseFunds
                      //         : l10n.requestRelease,
                      //   ),
                      // ),
                      Gap(Dimens.spacing.sp20),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
