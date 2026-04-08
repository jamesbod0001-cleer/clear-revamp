import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/status_history/status_history.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_section_header.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
                          : Color(0xFFA0BCA2),
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
                          height: 1,
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
                  Gap(Dimens.spacing.sp8),
                  Text(
                    step.subtitle,
                    style: context.typo.bodyMedium.copyWith(
                      height: 1,
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

class AgreementTimeline extends StatelessWidget {
  const AgreementTimeline({
    super.key,
    required this.agreement,
    required this.statusHistory,
  });
  final Agreement agreement;
  final List<StatusHistory> statusHistory;

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
          subtitle: 'You created the agreement', // Add your l10n here
          state: StepState.completed,
          date: agreement.createdAt,
        ),
      );
      final fundsLockedDate = statusDates[AgreementStatus.awaitingRecipient];
      steps.add(
        Step(
          title: l10n.fundsLocked,
          subtitle: 'Your money is safely held',
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
          subtitle: 'The agreement is now active',
          state: agreementAcceptedDate != null
              ? StepState.completed
              : StepState.pending,
          date: agreementAcceptedDate,
        ),
      );
      final fundsReleasedDate = null;
      steps.add(
        Step(
          title: l10n.fundsReleased,
          subtitle: 'Funds have been released',
          state: fundsReleasedDate != null
              ? StepState.completed
              : StepState.pending,
          date: fundsReleasedDate,
        ),
      );

      final completedDate = null;
      steps.add(
        Step(
          title: l10n.completed,
          subtitle: 'Agreement has been completed',
          state: completedDate != null
              ? StepState.completed
              : StepState.pending,
          date: completedDate,
        ),
      );
    } else {
      steps.add(
        Step(
          title: l10n.agreementInitiated,
          subtitle: 'You created the agreement', // Add your l10n here
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
          subtitle: 'The agreement is now active',
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
          subtitle: 'Your money is safely held',
          state: fundsLockedDate != null
              ? StepState.completed
              : StepState.pending,
          date: fundsLockedDate,
        ),
      );
      final fundsReleasedDate = null;
      steps.add(
        Step(
          title: l10n.fundsReleased,
          subtitle: 'Funds have been released',
          state: fundsReleasedDate != null
              ? StepState.completed
              : StepState.pending,
          date: fundsReleasedDate,
        ),
      );

      final completedDate = null;
      steps.add(
        Step(
          title: l10n.completed,
          subtitle: 'Agreement has been completed',
          state: completedDate != null
              ? StepState.completed
              : StepState.pending,
          date: completedDate,
        ),
      );
    }
    return Column(
      children: [
        ProfileSectionHeader(title: l10n.agreementStatus),
        ...List.generate(steps.length, (index) {
          return _StepperItem(
            step: steps[index],
            isLastStep: index == steps.length - 1,
            // Next line is green if the NEXT step is completed
            nextLineIsCompleted:
            index < steps.length - 1 && steps[index + 1].state.isCompleted,
          );
        }),
      ],
    );
  }
}

