import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:cleer_core/models/milestone/milestone.dart';
import 'package:cleer_core/models/milestone/milestone_enums.dart';
import 'package:cleer_core/models/status_history/status_history.dart';
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
  pending;

  bool get isPending => this == .pending;
  bool get isCompleted => this == .completed;
}

class Step {
  final String title;
  final String subtitle;
  final DateTime? date;
  final StepState state;

  Step({
    required this.title,
    required this.subtitle,
    this.date,
    required this.state,
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
                    : PhosphorIcons.circle(),
                size: Dimens.size.s20,
                color: step.state.isCompleted
                    ? context.color.green800
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
                          steps[mIndex + 1].state.isCompleted,
                    );
                  }),
                ),
              );
            },
          ),

          // historyState.when(
          //   data: (List<StatusHistory> history) {
          //     final statusDates = <MilestoneStatus, DateTime>{};
          //     for (final h in history) {
          //       final status = h.parsedMilestoneStatus;
          //       if (status != null && h.createdAt != null) {
          //         statusDates.putIfAbsent(status, () => h.createdAt!);
          //       }
          //     }
          //     final List<Step> steps = [
          //       Step(
          //         title: l10n.fundsReleased,
          //         subtitle: l10n.releaseInitiatedCompletingIn2Hours,
          //         state: statusDates[MilestoneStatus.processingRelease] != null
          //             ? StepState.completed
          //             : StepState.pending,
          //         date: null,
          //       ),
          //       Step(
          //         title: l10n.completed,
          //         subtitle: l10n.milestoneHasBeenCompleted,
          //         state: statusDates[MilestoneStatus.released] != null
          //             ? StepState.completed
          //             : StepState.pending,
          //         date: null,
          //       ),
          //     ];
          //
          //     return Column(
          //       children: List.generate(steps.length, (mIndex) {
          //         return _StepperItem(
          //           step: steps[mIndex],
          //           isLastStep: mIndex == steps.length - 1,
          //           nextLineIsCompleted:
          //               mIndex < steps.length - 1 &&
          //               steps[mIndex + 1].state.isCompleted,
          //         );
          //       }),
          //     );
          //   },
          //
          //   /// TODO: Show proper error here
          //   error: (Object error, StackTrace stackTrace) =>
          //       const SizedBox.shrink(),
          //   loading: () => Padding(
          //     padding: .symmetric(vertical: Dimens.padding.p16),
          //     // child: Center(child: CircularProgressIndicator()),
          //   ),
          // ),
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
    final l10n = AppLocalizations.of(context)!;
    final statusDates = <AgreementStatus, DateTime>{};

    final sortedHistory = statusHistory.toList()
      ..sort(
        (a, b) => (a.createdAt ?? DateTime.now()).compareTo(
          b.createdAt ?? DateTime.now(),
        ),
      );

    for (final history in sortedHistory) {
      final status = history.parsedAgreementStatus;
      if (status != null && history.createdAt != null) {
        statusDates.putIfAbsent(status, () => history.createdAt!);
      }
    }

    final List<Step> steps = [];

    if (agreement.initiatorRole == InitiatorRole.sender) {
      steps.add(
        Step(
          title: l10n.agreementInitiated,
          subtitle: l10n.initiatedBy(
            agreement.initiator!.firstName,
          ), // Add your l10n here
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
                    steps[index + 1].state.isCompleted,
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
