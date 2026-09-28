import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/menu_section_header.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class IssueStatusTimeline extends StatelessWidget {
  const IssueStatusTimeline({
    super.key,
    required this.dispute,
    required this.statusHistory,
  });

  final Dispute dispute;
  final List<StatusHistory> statusHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final statusDates = <DisputeStatus, DateTime>{};
    for (final record in statusHistory) {
      final status = record.parsedDisputeStatus;
      if (status != null && record.createdAt != null) {
        statusDates.putIfAbsent(status, () => record.createdAt!);
      }
    }

    final submittedDate =
        statusDates[DisputeStatus.open] ?? dispute.createdAt;
    final inReviewDate = statusDates[DisputeStatus.underReview];
    final resolutionDate =
        statusDates[DisputeStatus.resolved] ??
        statusDates[DisputeStatus.dismissed];

    final isUnderReviewCompleted =
        inReviewDate != null ||
        dispute.status == DisputeStatus.underReview ||
        dispute.status == DisputeStatus.resolved ||
        dispute.status == DisputeStatus.dismissed;

    final isResolutionCompleted =
        resolutionDate != null ||
        dispute.status == DisputeStatus.resolved ||
        dispute.status == DisputeStatus.dismissed;

    final reporterName = dispute.raisedBy?.firstName ?? 'User';

    final steps = [
      _DisputeStep(
        title: l10n.reportSubmitted,
        subtitle: l10n.issueReportedBy(reporterName),
        isCompleted: true,
        date: submittedDate,
      ),
      _DisputeStep(
        title: l10n.inReview,
        subtitle: l10n.fundsAreSecurelyHeld,
        isCompleted: isUnderReviewCompleted,
        date: inReviewDate,
      ),
      _DisputeStep(
        title: l10n.resolution,
        subtitle: isResolutionCompleted
            ? (dispute.status == DisputeStatus.dismissed
                ? l10n.reportDismissed
                : l10n.reportResolved)
            : l10n.wellNotifyYouWhenADecisionHasBeenReached,
        isCompleted: isResolutionCompleted,
        date: resolutionDate,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuSectionHeader(title: l10n.issueStatus),
        Column(
          children: List.generate(steps.length, (index) {
            return _DisputeStepperItem(
              step: steps[index],
              isLastStep: index == steps.length - 1,
              nextLineIsCompleted:
                  index < steps.length - 1 && steps[index + 1].isCompleted,
            );
          }),
        ),
      ],
    );
  }
}

class _DisputeStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final DateTime? date;

  const _DisputeStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.date,
  });
}

class _DisputeStepperItem extends StatelessWidget {
  const _DisputeStepperItem({
    required this.step,
    required this.isLastStep,
    required this.nextLineIsCompleted,
  });

  final _DisputeStep step;
  final bool isLastStep;
  final bool nextLineIsCompleted;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Visibility(
                visible: !isLastStep,
                child: Positioned.fill(
                  top: 17,
                  child: Center(
                    child: DottedLine(
                      direction: Axis.vertical,
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
                step.isCompleted
                    ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                    : PhosphorIcons.circle(),
                size: Dimens.size.s20,
                color: step.isCompleted
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: context.typo.bodySmall.copyWith(
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
