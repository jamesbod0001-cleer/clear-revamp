import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

extension AgreementUIExtensions on Agreement {
  bool get isDisputed =>
      status == AgreementStatus.disputed ||
      activeMilestoneStatus?.toUpperCase() == 'DISPUTED';

  Color getStatusPillColor(BuildContext context) {
    if (isDisputed) return context.color.errorLight;

    switch (status) {
      case AgreementStatus.draft:
      case AgreementStatus.awaitingRecipient:
      case AgreementStatus.awaitingFunding:
        return context.color.warningLight;
      case AgreementStatus.funded:
      case AgreementStatus.inProgress:
      case AgreementStatus.readyForRelease:
      case AgreementStatus.processingRelease:
        return context.color.infoLight;
      case AgreementStatus.released:
        return context.color.successLight;
      case AgreementStatus.disputed:
        return context.color.errorLight;
      case AgreementStatus.rejected:
      case AgreementStatus.cancelled:
        // TODO: Update these with your actual colors when ready
        return context.color.grayComponent;
    }
  }

  Color getStatusTextColor(BuildContext context) {
    if (isDisputed) return context.color.error;

    switch (status) {
      case AgreementStatus.draft:
      case AgreementStatus.awaitingRecipient:
      case AgreementStatus.awaitingFunding:
        return context.color.warning;
      case AgreementStatus.funded:
      case AgreementStatus.inProgress:
      case AgreementStatus.readyForRelease:
      case AgreementStatus.processingRelease:
        return context.color.info;
      case AgreementStatus.released:
        return context.color.success;
      case AgreementStatus.disputed:
        return context.color.error;
      case AgreementStatus.rejected:
      case AgreementStatus.cancelled:
        // TODO: Update these with your actual colors when ready
        return context.color.grey800;
    }
  }

  String getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isDisputed) return l10n.inDispute;

    switch (status) {
      case AgreementStatus.draft:
      case AgreementStatus.awaitingRecipient:
      case AgreementStatus.awaitingFunding:
        return l10n.pending;
      case AgreementStatus.funded:
      case AgreementStatus.inProgress:
      case AgreementStatus.readyForRelease:
      case AgreementStatus.processingRelease:
        return l10n.fundsHeld;
      case AgreementStatus.released:
        return l10n.released;
      case AgreementStatus.disputed:
        return l10n.inDispute;
      case AgreementStatus.rejected:
      case AgreementStatus.cancelled:
        // TODO: Add actual l10n strings later
        return "Unknown";
    }
  }

  String getDisplayTitle(BuildContext context, {required User? currentUser}) {
    final l10n = AppLocalizations.of(context)!;

    String partnerName = "Loading...";
    if (currentUser != null && sender != null && recipient != null) {
      if (currentUser.id == sender?.id) {
        partnerName = "${recipient?.firstName} ${recipient?.lastName}";
      } else {
        partnerName = "${sender?.firstName} ${sender?.lastName}";
      }
    }

    switch (status) {
      case AgreementStatus.draft:
      case AgreementStatus.awaitingRecipient:
        return l10n.awaitingAcceptanceStatus(description);
      case AgreementStatus.awaitingFunding:
        return l10n.awaitingPaymentStatus(description);
      case AgreementStatus.funded:
      case AgreementStatus.inProgress:
      case AgreementStatus.readyForRelease:
      case AgreementStatus.processingRelease:
      case AgreementStatus.released:
      case AgreementStatus.disputed:
      case AgreementStatus.rejected:
      case AgreementStatus.cancelled:
        return l10n.agreementWith(partnerName);
    }
  }

  Widget getActionWidget(BuildContext context, {required User? currentUser}) {
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    // 1. Establish base identity variables
    final isPending =
        status == AgreementStatus.awaitingRecipient ||
        status == AgreementStatus.awaitingFunding;
    final amIInitiator = initiator?.id == currentUser.id;
    final isSender = sender?.id == currentUser.id;
    final isRecipient = recipient?.id == currentUser.id;

    // 2. Evaluate base "Action Required" logic
    bool needsAction =
        (isPending && !amIInitiator) ||
        (status == AgreementStatus.readyForRelease && isSender);

    // 3. Evaluate nested category states when IN_PROGRESS
    if (status == AgreementStatus.inProgress) {
      // --- Physical Goods ---
      if (category == AgreementCategory.physicalGoods &&
          physicalDeliveryContext != null) {
        final deliveryStatus = physicalDeliveryContext!.status;
        if (deliveryStatus == PhysicalDeliveryContextStatus.awaitingPackaging ||
            deliveryStatus == PhysicalDeliveryContextStatus.awaitingDispatch) {
          if (isRecipient) needsAction = true;
        } else if (deliveryStatus ==
            PhysicalDeliveryContextStatus.awaitingBuyerAcknowledgement) {
          if (isSender) needsAction = true;
        }
      }
      // --- Services & Works (One-Time & Milestones) ---
      else if (category == AgreementCategory.servicesWork) {
        if (disbursementType == DisbursementType.oneTime) {
          if (isRecipient) needsAction = true; // Vendor needs to do work
        } else if (disbursementType == DisbursementType.milestones) {
          // Using our denormalized NoSQL field directly on the UI model!
          if (isRecipient && activeMilestoneStatus == 'IN_PROGRESS') {
            needsAction = true;
          } else if (isSender && activeMilestoneStatus == 'READY_FOR_RELEASE') {
            needsAction = true;
          }
        }
      }
    }

    // 4. Render the Action Required widget if applicable
    if (needsAction) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.actionRequired,
            style: context.typo.bodyLink.copyWith(
              color: context.color.blue700,
              decorationColor: context.color.blue700,
            ),
          ),
          Gap(Dimens.spacing.sp4),
          PhosphorIcon(
            PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
            size: Dimens.size.s16,
            color: context.color.blue700,
          ),
        ],
      );
    }

    // 5. STRICT RULE: Render "Awaiting response" ONLY when waiting for initial acceptance/funding
    if (isPending && amIInitiator) {
      return Text(
        l10n.awaitingResponse,
        style: context.typo.labelSmall.copyWith(color: context.color.warning),
      );
    }

    // Show nothing otherwise
    return const SizedBox.shrink();
  }

  DateTime? get dueDate {
    switch (disbursementType) {
      case DisbursementType.oneTime:
        return expectedReleaseDate;
      case DisbursementType.milestones:
        return activeMilestoneExpectedReleaseDate;
    }
  }
}

extension AgreementDisputeCategoryExtension on Agreement {
  DisputeReasonCategory get reportIssueCategory {
    if (category == AgreementCategory.physicalGoods) {
      return DisputeReasonCategory.products;
    }
    if (category == AgreementCategory.servicesWork &&
        disbursementType == DisbursementType.milestones) {
      return DisputeReasonCategory.milestones;
    }
    return DisputeReasonCategory.services;
  }

  List<DisputeReason> get availableIssueReasons {
    return DisputeReason.forCategory(reportIssueCategory);
  }
}

extension DisputeReasonUIExtension on DisputeReason {
  String getLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case DisputeReason.itemNotReceived:
        return l10n.issueReasonItemNotReceived;
      case DisputeReason.itemDamaged:
        return l10n.issueReasonItemDamaged;
      case DisputeReason.wrongItemReceived:
        return l10n.issueReasonWrongItemReceived;
      case DisputeReason.itemSignificantlyDifferent:
        return l10n.issueReasonItemSignificantlyDifferent;
      case DisputeReason.deliveryIssue:
        return l10n.issueReasonDeliveryIssue;
      case DisputeReason.workNotDelivered:
        return l10n.issueReasonWorkNotDelivered;
      case DisputeReason.workIncomplete:
        return l10n.issueReasonWorkIncomplete;
      case DisputeReason.workDoesNotMatch:
        return l10n.issueReasonWorkDoesNotMatch;
      case DisputeReason.serviceDeadlineMissed:
      case DisputeReason.milestoneDeadlineMissed:
        return l10n.issueReasonServiceDeadlineMissed;
      case DisputeReason.paymentReleasedByMistake:
        return l10n.issueReasonPaymentReleasedByMistake;
      case DisputeReason.milestoneNotCompleted:
        return l10n.issueReasonMilestoneNotCompleted;
      case DisputeReason.milestoneDoesNotMatch:
        return l10n.issueReasonMilestoneDoesNotMatch;
      case DisputeReason.workRequiresRevisions:
        return l10n.issueReasonWorkRequiresRevisions;
      case DisputeReason.productOther:
      case DisputeReason.serviceOther:
      case DisputeReason.milestoneOther:
        return l10n.issueReasonOther;
    }
  }
}
