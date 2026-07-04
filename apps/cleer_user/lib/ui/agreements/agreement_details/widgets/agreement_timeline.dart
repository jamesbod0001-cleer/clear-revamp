import 'package:cleer/ui/agreements/agreement_details/widgets/review_photo_thumbnail.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/milestone/milestone_enums.dart';
import 'package:cleer/domain/providers/milestone/milestone_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/menu_section_header.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum StepState {
  completed,
  pending,
  skipped;

  bool get isPending => this == StepState.pending;
  bool get isCompleted => this == StepState.completed;
  bool get isSkipped => this == StepState.skipped;
}

class Step {
  final String title;
  final String subtitle;
  final DateTime? date;
  final StepState state;
  final Widget? footer;

  Step({
    required this.title,
    required this.subtitle,
    this.date,
    required this.state,
    this.footer,
  });
}

class _StepperItem extends StatelessWidget {
  const _StepperItem({
    required this.step,
    required this.isLastStep,
    required this.nextLineIsCompleted,
  });
  final Step step;
  final bool isLastStep;
  final bool nextLineIsCompleted;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          Stack(
            alignment: .topCenter,
            clipBehavior: .none,
            children: [
              Visibility(
                visible: !isLastStep,
                child: Positioned.fill(
                  top: 17,
                  child: Center(
                    child: DottedLine(
                      direction: .vertical,
                      dashLength: Dimens.size.s5,
                      dashGapLength: Dimens.size.s3,
                      dashColor: nextLineIsCompleted
                          ? context.color.green800
                          : context.color.grey300,
                    ),
                  ),
                ),
              ),
              PhosphorIcon(
                step.state.isCompleted
                    ? PhosphorIcons.checkCircle(.fill)
                    : step.state.isSkipped
                    ? PhosphorIcons.minusCircle(.fill)
                    : PhosphorIcons.circle(),
                size: Dimens.size.s20,
                color: step.state.isCompleted
                    ? context.color.green800
                    : step.state.isSkipped
                    ? context.color.grey400
                    : context.color.grey300,
              ),
            ],
          ),
          Gap(Dimens.spacing.sp6),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLastStep ? Dimens.padding.p0 : Dimens.padding.p20,
              ),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Text(
                        step.title,
                        style: context.typo.bodyMedium.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                      if (step.date != null) ...[
                        Gap(Dimens.spacing.sp4),
                        Text(
                          '•',
                          style: context.typo.bodySmall.copyWith(
                            color: context.color.grey600,
                          ),
                        ),
                        Gap(Dimens.spacing.sp4),
                        Text(
                          DateFormat('d MMM, h:mm a').format(step.date!),
                          style: context.typo.bodySmall.copyWith(
                            color: context.color.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Gap(Dimens.spacing.sp4),
                  Text(
                    step.subtitle,
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey600,
                    ),
                  ),
                  if (step.footer != null) ...[
                    Gap(Dimens.spacing.sp4),
                    ?step.footer,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneTimelineTile extends HookConsumerWidget {
  const _MilestoneTimelineTile({
    required this.milestone,
    required this.index,
    required this.isLast,
  });
  final Milestone milestone;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = useState(true);
    final historyState = ref.watch(
      milestoneStatusHistoryProvider(milestone.id!),
    );

    Widget? statusPill() {
      switch (milestone.status) {
        case MilestoneStatus.pending:
          return null;
        case MilestoneStatus.inProgress:
        case MilestoneStatus.readyForRelease:
        case MilestoneStatus.processingRelease:
          return Ink(
            decoration: BoxDecoration(
              color: context.color.warningLight,
              borderRadius: BorderRadius.circular(Dimens.radius.r20),
            ),
            padding: .symmetric(
              horizontal: Dimens.padding.p6,
              vertical: Dimens.padding.p3,
            ),
            child: Text(
              l10n.inProgress,
              style: context.typo.bodySmall.copyWith(
                color: context.color.warning,
              ),
            ),
          );
        case MilestoneStatus.released:
          return Ink(
            decoration: BoxDecoration(
              color: context.color.successLight,
              borderRadius: BorderRadius.circular(Dimens.radius.r20),
            ),
            padding: .symmetric(
              horizontal: Dimens.padding.p6,
              vertical: Dimens.padding.p3,
            ),
            child: Text(
              l10n.completed,
              style: context.typo.bodySmall.copyWith(
                color: context.color.success,
              ),
            ),
          );
        case MilestoneStatus.disputed:
          return Ink(
            decoration: BoxDecoration(
              color: context.color.errorLight,
              borderRadius: BorderRadius.circular(Dimens.radius.r20),
            ),
            padding: .symmetric(
              horizontal: Dimens.padding.p6,
              vertical: Dimens.padding.p3,
            ),
            child: Text(
              l10n.inDispute,
              style: context.typo.bodySmall.copyWith(
                color: context.color.error,
              ),
            ),
          );
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? Dimens.padding.p0 : Dimens.padding.p12,
      ),
      child: ExpansionTile(
        backgroundColor: context.color.infoLight,
        collapsedBackgroundColor: context.color.infoLight,
        shape: RoundedRectangleBorder(
          borderRadius: .circular(Dimens.radius.r8),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: .circular(Dimens.radius.r8),
        ),
        childrenPadding: .fromLTRB(
          37,
          Dimens.padding.p4,
          Dimens.padding.p0,
          Dimens.padding.p12,
        ),
        expandedAlignment: .centerLeft,
        tilePadding: .symmetric(
          horizontal: Dimens.padding.p12,
          vertical: Dimens.padding.p4,
        ),
        minTileHeight: Dimens.size.s0,
        initiallyExpanded: true,
        onExpansionChanged: (value) => isExpanded.value = value,
        trailing: PhosphorIcon(
          isExpanded.value
              ? PhosphorIcons.caretUp()
              : PhosphorIcons.caretDown(),
          color: context.color.blue700,
        ),
        title: Row(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: statusPill() == null
                  ? .zero
                  : EdgeInsets.only(top: Dimens.padding.p2),
              child: PhosphorIcon(
                milestone.status == .released
                    ? PhosphorIcons.checkCircle(.fill)
                    : PhosphorIcons.circleDashed(.bold),
                size: Dimens.size.s20,
                color: context.color.green800,
              ),
            ),
            Gap(Dimens.spacing.sp5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: Dimens.spacing.sp8,
                  children: [
                    Text(
                      l10n.milestoneCount(index + 1),
                      style: context.typo.titleMedium.copyWith(
                        color: context.color.grey800,
                      ),
                    ),
                    statusPill() != null
                        ? Skeleton.replace(
                            replacement: Bone(
                              width: Dimens.size.s56,
                              height: Dimens.size.s22,
                              borderRadius: .circular(Dimens.radius.r20),
                            ),
                            child: statusPill()!,
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                Gap(Dimens.spacing.sp4),
                Row(
                  children: [
                    Text(
                      milestone.name,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp4),
                    Text(
                      "${l10n.nairaSign}${NumberFormat('#,###.##').format(milestone.amount)}",
                      style: context.typo.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        children: [
          historyState.maybeWhen(
            /// TODO: Show proper error here
            error: (Object error, StackTrace stackTrace) =>
                const SizedBox.shrink(),
            orElse: () {
              bool isLoading = historyState.isLoading;

              List<StatusHistory> history = historyState.value ?? [];

              final statusDates = <MilestoneStatus, DateTime>{};

              for (final h in history) {
                final status = h.parsedMilestoneStatus;
                if (status != null && h.createdAt != null) {
                  statusDates.putIfAbsent(status, () => h.createdAt!);
                }
              }
              final List<Step> steps = [
                Step(
                  title: l10n.fundsReleased,
                  subtitle: l10n.releaseInitiatedCompletingIn2Hours,
                  state: statusDates[MilestoneStatus.processingRelease] != null
                      ? StepState.completed
                      : StepState.pending,
                  date: null,
                ),
                Step(
                  title: l10n.completed,
                  subtitle: l10n.milestoneHasBeenCompleted,
                  state: statusDates[MilestoneStatus.released] != null
                      ? StepState.completed
                      : StepState.pending,
                  date: null,
                ),
              ];

              return Skeletonizer(
                enabled: isLoading,
                child: Column(
                  children: List.generate(steps.length, (mIndex) {
                    return _StepperItem(
                      step: steps[mIndex],
                      isLastStep: mIndex == steps.length - 1,
                      nextLineIsCompleted:
                          mIndex < steps.length - 1 &&
                          (steps[mIndex + 1].state.isCompleted ||
                              steps[mIndex + 1].state.isSkipped),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AgreementTimeline extends HookWidget {
  const AgreementTimeline({
    super.key,
    required this.agreement,
    required this.statusHistory,
    this.milestones,
  });
  final Agreement agreement;
  final List<StatusHistory> statusHistory;
  final List<Milestone>? milestones;

  @override
  Widget build(BuildContext context) {
    final statusDates = <AgreementStatus, DateTime>{};
    final deliveryStatusDates = <PhysicalDeliveryContextStatus, DateTime>{};

    final sortedHistory = statusHistory.toList()
      ..sort(
        (a, b) => (a.createdAt ?? DateTime.now()).compareTo(
          b.createdAt ?? DateTime.now(),
        ),
      );

    for (final history in sortedHistory) {
      if (history.context == 'CORE_STATUS') {
        final status = history.parsedAgreementStatus;
        if (status != null && history.createdAt != null) {
          statusDates.putIfAbsent(status, () => history.createdAt!);
        }
      } else if (history.context == 'DELIVERY_STATUS') {
        final status = history.parsedPhysicalDeliveryStatus;
        if (status != null && history.createdAt != null) {
          deliveryStatusDates.putIfAbsent(status, () => history.createdAt!);
        }
      }
    }

    if (agreement.category == AgreementCategory.physicalGoods) {
      return _PhysicalGoodsTimeline(
        agreement: agreement,
        statusDates: statusDates,
        deliveryStatusDates: deliveryStatusDates,
      );
    }

    return _StandardTimeline(
      agreement: agreement,
      statusDates: statusDates,
      milestones: milestones,
    );
  }
}

class _StandardTimeline extends StatelessWidget {
  const _StandardTimeline({
    required this.agreement,
    required this.statusDates,
    this.milestones,
  });

  final Agreement agreement;
  final Map<AgreementStatus, DateTime> statusDates;
  final List<Milestone>? milestones;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Step> steps = [];

    if (agreement.initiatorRole == InitiatorRole.sender) {
      steps.add(
        Step(
          title: l10n.agreementInitiated,
          subtitle: l10n.initiatedBy(agreement.initiator!.firstName),
          state: StepState.completed,
          date: agreement.createdAt,
        ),
      );
      final fundsLockedDate = statusDates[AgreementStatus.awaitingRecipient];
      steps.add(
        Step(
          title: l10n.fundsLocked,
          subtitle: l10n.fundsAreSecurelyHeld,
          state: fundsLockedDate != null
              ? StepState.completed
              : StepState.pending,
          date: fundsLockedDate,
        ),
      );
      final agreementAcceptedDate =
          statusDates[AgreementStatus.funded] ??
          statusDates[AgreementStatus.inProgress];
      steps.add(
        Step(
          title: l10n.agreementAccepted,
          subtitle: l10n.theAgreementIsNowActive,
          state: agreementAcceptedDate != null
              ? StepState.completed
              : StepState.pending,
          date: agreementAcceptedDate,
        ),
      );
      if (agreement.disbursementType == .oneTime) {
        final fundsReleasedDate =
            statusDates[AgreementStatus.processingRelease];
        steps.add(
          Step(
            title: l10n.fundsReleased,
            subtitle: l10n.releaseInitiatedCompletingIn2Hours,
            state: fundsReleasedDate != null
                ? StepState.completed
                : StepState.pending,
            date: fundsReleasedDate,
          ),
        );

        final completedDate = statusDates[AgreementStatus.released];
        steps.add(
          Step(
            title: l10n.completed,
            subtitle: l10n.agreementHasBeenCompleted,
            state: completedDate != null
                ? StepState.completed
                : StepState.pending,
            date: completedDate,
          ),
        );
      }
    } else {
      steps.add(
        Step(
          title: l10n.agreementInitiated,
          subtitle: l10n.initiatedBy(agreement.initiator!.firstName),
          state: StepState.completed,
          date: agreement.createdAt,
        ),
      );
      final agreementAcceptedDate =
          statusDates[AgreementStatus.funded] ??
          statusDates[AgreementStatus.inProgress];
      steps.add(
        Step(
          title: l10n.agreementAccepted,
          subtitle: l10n.theAgreementIsNowActive,
          state: agreementAcceptedDate != null
              ? StepState.completed
              : StepState.pending,
          date: agreementAcceptedDate,
        ),
      );
      final fundsLockedDate =
          statusDates[AgreementStatus.funded] ??
          statusDates[AgreementStatus.inProgress];
      steps.add(
        Step(
          title: l10n.fundsLocked,
          subtitle: l10n.fundsAreSecurelyHeld,
          state: fundsLockedDate != null
              ? StepState.completed
              : StepState.pending,
          date: fundsLockedDate,
        ),
      );
      if (agreement.disbursementType == .oneTime) {
        final fundsReleasedDate =
            statusDates[AgreementStatus.processingRelease];
        steps.add(
          Step(
            title: l10n.fundsReleased,
            subtitle: l10n.releaseInitiatedCompletingIn2Hours,
            state: fundsReleasedDate != null
                ? StepState.completed
                : StepState.pending,
            date: fundsReleasedDate,
          ),
        );

        final completedDate = statusDates[AgreementStatus.released];
        steps.add(
          Step(
            title: l10n.completed,
            subtitle: l10n.agreementHasBeenCompleted,
            state: completedDate != null
                ? StepState.completed
                : StepState.pending,
            date: completedDate,
          ),
        );
      }
    }

    return Column(
      children: [
        MenuSectionHeader(
          title: agreement.disbursementType == .oneTime
              ? l10n.agreementStatus
              : l10n.paymentMilestones,
        ),
        Padding(
          padding: agreement.disbursementType == .oneTime
              ? .zero
              : .only(left: Dimens.padding.p12, bottom: Dimens.padding.p12),
          child: Column(
            children: List.generate(steps.length, (index) {
              return _StepperItem(
                step: steps[index],
                isLastStep: index == steps.length - 1,
                // Next line is green if the NEXT step is completed
                nextLineIsCompleted:
                    index < steps.length - 1 &&
                    (steps[index + 1].state.isCompleted ||
                        steps[index + 1].state.isSkipped),
              );
            }),
          ),
        ),
        if (agreement.disbursementType == DisbursementType.milestones &&
            milestones != null) ...[
          Gap(Dimens.spacing.sp12),
          ...List.generate(milestones!.length, (index) {
            return _MilestoneTimelineTile(
              milestone: milestones![index],
              index: index,
              isLast: (index + 1) == milestones!.length,
            );
          }),
        ],
      ],
    );
  }
}

class _PhysicalGoodsTimeline extends StatelessWidget {
  const _PhysicalGoodsTimeline({
    required this.agreement,
    required this.statusDates,
    required this.deliveryStatusDates, // Make sure this is passed from AgreementTimeline!
  });

  final Agreement agreement;
  final Map<AgreementStatus, DateTime> statusDates;
  final Map<PhysicalDeliveryContextStatus, DateTime> deliveryStatusDates;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 1. Safely calculate the current macro step
    int calculatedCurrentStep = 1;

    switch (agreement.status) {
      case AgreementStatus.draft:
      case AgreementStatus.awaitingRecipient:
      case AgreementStatus.awaitingFunding:
      case AgreementStatus.funded:
        calculatedCurrentStep = 1; // Active / Setup
      case AgreementStatus.inProgress:
        calculatedCurrentStep = 2; // Preparing & Shipping
      case AgreementStatus.readyForRelease:
        calculatedCurrentStep = 3; // Release Funds (Waiting for buyer action)
      case AgreementStatus.processingRelease:
      case AgreementStatus.released:
        calculatedCurrentStep = 4; // Completed (Timer ticking or finished)
      default:
        calculatedCurrentStep = 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuSectionHeader(title: l10n.agreementStatus),

        AgreementProgressCard(
          currentStep: calculatedCurrentStep,
          isCompleted: agreement.status == AgreementStatus.released,
        ),

        Gap(Dimens.spacing.sp16),

        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Calculate the exact 3-column dimension upfront.
            // Screen width - 26px (Left icon & gap) - 24px (Container padding) - 12px (Wrap spacing)
            final double photoDimension = (constraints.maxWidth - 62) / 3;

            // Build the Micro Steps based on the active Macro Step
            final List<Step> activeSectionSteps = [];

            if (calculatedCurrentStep == 1) {
              // ---------------------------------------------------------
              // MACRO STEP 1: ACTIVE (Setup Phase)
              // ---------------------------------------------------------
              if (agreement.initiatorRole == InitiatorRole.sender) {
                activeSectionSteps.add(
                  Step(
                    title: l10n.agreementInitiated,
                    subtitle: l10n.initiatedBy(agreement.initiator!.firstName),
                    state: StepState.completed,
                    date: agreement.createdAt,
                  ),
                );
                final fundsLockedDate =
                    statusDates[AgreementStatus.awaitingRecipient];
                activeSectionSteps.add(
                  Step(
                    title: l10n.fundsLocked,
                    subtitle: l10n.fundsAreSecurelyHeld,
                    state: fundsLockedDate != null
                        ? StepState.completed
                        : StepState.pending,
                    date: fundsLockedDate,
                  ),
                );
                final agreementAcceptedDate =
                    statusDates[AgreementStatus.funded] ??
                    statusDates[AgreementStatus.inProgress];
                activeSectionSteps.add(
                  Step(
                    title: l10n.agreementAccepted,
                    subtitle: l10n.theAgreementIsNowActive,
                    state: agreementAcceptedDate != null
                        ? StepState.completed
                        : StepState.pending,
                    date: agreementAcceptedDate,
                  ),
                );
              } else {
                activeSectionSteps.add(
                  Step(
                    title: l10n.agreementInitiated,
                    subtitle: l10n.initiatedBy(agreement.initiator!.firstName),
                    state: StepState.completed,
                    date: agreement.createdAt,
                  ),
                );
                final agreementAcceptedDate =
                    statusDates[AgreementStatus.funded] ??
                    statusDates[AgreementStatus.inProgress];
                activeSectionSteps.add(
                  Step(
                    title: l10n.agreementAccepted,
                    subtitle: l10n.theAgreementIsNowActive,
                    state: agreementAcceptedDate != null
                        ? StepState.completed
                        : StepState.pending,
                    date: agreementAcceptedDate,
                  ),
                );
                final fundsLockedDate =
                    statusDates[AgreementStatus.funded] ??
                    statusDates[AgreementStatus.inProgress];
                activeSectionSteps.add(
                  Step(
                    title: l10n.fundsLocked,
                    subtitle: l10n.fundsAreSecurelyHeld,
                    state: fundsLockedDate != null
                        ? StepState.completed
                        : StepState.pending,
                    date: fundsLockedDate,
                  ),
                );
              }
            } else if (calculatedCurrentStep == 2) {
              // ---------------------------------------------------------
              // MACRO STEP 2: PREPARING & SHIPPING
              // ---------------------------------------------------------

              // Sub-step 1: Package photos
              final dispatchDate =
                  deliveryStatusDates[PhysicalDeliveryContextStatus
                      .awaitingDispatch];

              final bool isPackagingSkipped =
                  dispatchDate != null &&
                  (agreement
                          .physicalDeliveryContext
                          ?.packagingPhotos
                          ?.isEmpty ??
                      true);

              activeSectionSteps.add(
                Step(
                  title: isPackagingSkipped
                      ? l10n.packagePhotosSkipped
                      : l10n.packagePhotosUploaded,
                  subtitle: isPackagingSkipped
                      ? l10n.vendorOptedNotToUploadPhotos
                      : l10n.vendorHasPreparedThePackage,
                  state: dispatchDate == null
                      ? StepState.pending
                      : (isPackagingSkipped
                            ? StepState.skipped
                            : StepState.completed),
                  date: dispatchDate,

                  footer:
                      dispatchDate != null &&
                          !isPackagingSkipped &&
                          agreement.physicalDeliveryContext?.status !=
                              PhysicalDeliveryContextStatus.awaitingDispatch
                      ? Container(
                          padding: .all(Dimens.padding.p12),
                          decoration: BoxDecoration(
                            color: context.color.grayComponent,
                            borderRadius: .circular(Dimens.radius.r12),
                          ),
                          child: Wrap(
                            spacing: Dimens.spacing.sp6,
                            runSpacing: Dimens.spacing.sp6,
                            children: agreement
                                .physicalDeliveryContext!
                                .packagingPhotos!
                                .map((photo) {
                                  return ReviewPhotoThumbnail(
                                    photo: photo,
                                    dimension: photoDimension,
                                  );
                                })
                                .toList(),
                          ),
                        )
                      : null,
                ),
              );

              // Sub-step 2: Delivery details shared
              final acknowledgementDate =
                  deliveryStatusDates[PhysicalDeliveryContextStatus
                      .awaitingBuyerAcknowledgement];
              final transitDate =
                  deliveryStatusDates[PhysicalDeliveryContextStatus.inTransit];
              final detailsSharedDate = acknowledgementDate ?? transitDate;

              final bool isSharingDeliveryDetailsSkipped =
                  transitDate != null &&
                  agreement.physicalDeliveryContext?.deliveryDetails == null;

              // Sub-step 2: Delivery details shared
              activeSectionSteps.add(
                Step(
                  title: isSharingDeliveryDetailsSkipped
                      ? l10n.deliveryDetailsSkipped
                      : l10n.deliveryDetailsShared,
                  subtitle: isSharingDeliveryDetailsSkipped
                      ? l10n.vendorSkippedSharingDeliveryInfo
                      : l10n.vendorSharedTheDriverWaybillInfo,
                  state: detailsSharedDate == null
                      ? StepState.pending
                      : (isSharingDeliveryDetailsSkipped
                            ? StepState.skipped
                            : StepState.completed),
                  date: detailsSharedDate,
                ),
              );

              // Sub-step 3: Delivery details confirmed (inherently skipped if step 2 was skipped)
              activeSectionSteps.add(
                Step(
                  title: isSharingDeliveryDetailsSkipped
                      ? l10n.confirmationSkipped
                      : l10n.deliveryDetailsConfirmed,
                  subtitle: isSharingDeliveryDetailsSkipped
                      ? l10n.autoSkippedBecauseDetailsWereNotProvided
                      : l10n.buyerAcknowledgedTheDeliveryDetails,
                  state: transitDate == null
                      ? StepState.pending
                      : (isSharingDeliveryDetailsSkipped
                            ? StepState.skipped
                            : StepState.completed),
                  date: transitDate,
                ),
              );
            } else if (calculatedCurrentStep == 3) {
              // ---------------------------------------------------------
              // MACRO STEP 3: RELEASE FUNDS
              // ---------------------------------------------------------

              final processingDate =
                  statusDates[AgreementStatus.processingRelease];

              // Sub-step 1: Confirm item received
              activeSectionSteps.add(
                Step(
                  title: l10n.confirmItemReceived,
                  subtitle: l10n.buyerHasReceivedAndInspectedTheGoods,
                  state: processingDate != null
                      ? StepState.completed
                      : StepState.pending,
                  date:
                      processingDate, // This is stamped the exact moment they click "Release Funds"
                ),
              );

              // Sub-step 2: Releasing funds (2-hour timer started)
              activeSectionSteps.add(
                Step(
                  title: l10n.releasingFunds,
                  subtitle: l10n.fundsWillBeReleasedIn2Hours,
                  // If it's processing, it's currently "completed" in the sense that the timer has started
                  state: processingDate != null
                      ? StepState.completed
                      : StepState.pending,
                  date: processingDate,
                ),
              );
            } else if (calculatedCurrentStep == 4) {
              // ---------------------------------------------------------
              // MACRO STEP 4: COMPLETED
              // ---------------------------------------------------------

              final releaseDate = statusDates[AgreementStatus.released];
              activeSectionSteps.add(
                Step(
                  title: l10n.completed,
                  subtitle: l10n.agreementHasBeenCompleted,
                  state: releaseDate != null
                      ? StepState.completed
                      : StepState.pending,
                  date: releaseDate,
                ),
              );
            }

            return Column(
              children: List.generate(activeSectionSteps.length, (index) {
                return _StepperItem(
                  step: activeSectionSteps[index],
                  isLastStep: index == activeSectionSteps.length - 1,
                  // Next line is green if the NEXT step is completed
                  nextLineIsCompleted:
                      index < activeSectionSteps.length - 1 &&
                      (activeSectionSteps[index + 1].state.isCompleted ||
                          activeSectionSteps[index + 1].state.isSkipped),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

enum _ProgressNodeState { pending, inProgress, completed }

class _ProgressNode extends StatelessWidget {
  const _ProgressNode({required this.step, required this.state});
  final int step;
  final _ProgressNodeState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _ProgressNodeState.pending:
        return Skeleton.leaf(
          child: Container(
            width: Dimens.size.s28,
            height: Dimens.size.s28,
            decoration: BoxDecoration(
              shape: .circle,
              color: context.color.white,
              border: .all(color: context.color.outline),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: context.typo.bodySmall.copyWith(
                  color: context.color.grey500,
                ),
              ),
            ),
          ),
        );
      case _ProgressNodeState.inProgress:
        return Skeleton.leaf(
          child: Container(
            width: Dimens.size.s28,
            height: Dimens.size.s28,
            decoration: BoxDecoration(
              shape: .circle,
              color: context.color.white,
              border: .all(
                color: context.color.secondary,
                width: Dimens.size.s8,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              boxShadow: [BoxShadow(color: Color(0x1E050857), spreadRadius: 4)],
            ),
          ),
        );
      case _ProgressNodeState.completed:
        return Skeleton.leaf(
          child: Container(
            width: Dimens.size.s28,
            height: Dimens.size.s28,
            decoration: BoxDecoration(
              shape: .circle,
              color: context.color.green800,
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIcons.check(.bold),
                size: Dimens.size.s14,
                color: context.color.white,
              ),
            ),
          ),
        );
    }
  }
}

class AgreementProgressCard extends StatelessWidget {
  const AgreementProgressCard({
    super.key,
    required this.currentStep,
    required this.isCompleted,
  });
  final int currentStep;
  final bool isCompleted;

  _ProgressNodeState _getNodeState(int stepNumber) {
    if (currentStep > stepNumber) return _ProgressNodeState.completed;
    if (currentStep == stepNumber) {
      return isCompleted
          ? _ProgressNodeState.completed
          : _ProgressNodeState.inProgress;
    }
    return _ProgressNodeState.pending;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    int totalSteps = 4;

    return Container(
      padding: .all(Dimens.padding.p16),
      decoration: BoxDecoration(
        color: context.color.white,
        borderRadius: .circular(Dimens.radius.r20),
        border: .all(color: context.color.outline),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(l10n.whereThisAgreementIs, style: context.typo.bodyMedium),
              Text(
                'Step $currentStep of $totalSteps',
                style: context.typo.bodySmall.copyWith(
                  color: context.color.grey600,
                ),
              ),
            ],
          ),
          Gap(Dimens.spacing.sp20),

          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double maxWidth = constraints.maxWidth / 4;
              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.padding.p24,
                    ),
                    child: Divider(
                      thickness: Dimens.size.s3,
                      height: Dimens.size.s28,
                      color: context.color.outline,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Node 1
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          children: [
                            _ProgressNode(
                              step: 1,
                              state: _getNodeState(1),
                            ), // UPDATED
                            Gap(Dimens.spacing.sp8),
                            Text(
                              'Active',
                              textAlign: TextAlign.center,
                              style: context.typo.bodySmall.copyWith(
                                color: currentStep == 1
                                    ? context.color.grey1000
                                    : context.color.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Node 2
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          children: [
                            _ProgressNode(
                              step: 2,
                              state: _getNodeState(2),
                            ), // UPDATED
                            Gap(Dimens.spacing.sp8),
                            Text(
                              'Preparing & shipping',
                              textAlign: TextAlign.center,
                              style: context.typo.bodySmall.copyWith(
                                color: currentStep == 2
                                    ? context.color.grey1000
                                    : context.color.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Node 3
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          children: [
                            _ProgressNode(
                              step: 3,
                              state: _getNodeState(3),
                            ), // UPDATED
                            Gap(Dimens.spacing.sp8),
                            Text(
                              'Release Funds',
                              textAlign: TextAlign.center,
                              style: context.typo.bodySmall.copyWith(
                                color: currentStep == 3
                                    ? context.color.grey1000
                                    : context.color.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Node 4
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          children: [
                            _ProgressNode(
                              step: 4,
                              state: _getNodeState(4),
                            ), // UPDATED
                            Gap(Dimens.spacing.sp8),
                            Text(
                              'Completed',
                              textAlign: TextAlign.center,
                              style: context.typo.bodySmall.copyWith(
                                color: currentStep == 4
                                    ? context.color.grey1000
                                    : context.color.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
