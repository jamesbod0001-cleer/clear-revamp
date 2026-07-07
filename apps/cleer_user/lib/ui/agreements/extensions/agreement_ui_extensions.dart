import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:cleer_core/models/milestone/milestone.dart';
import 'package:cleer_core/models/physical_delivery_context/physical_delivery_context_enums.dart';
import 'package:cleer_core/models/user/user.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

extension AgreementUIExtensions on Agreement {
  Color getStatusPillColor(BuildContext context) {
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
      case AgreementStatus.rejected:
      case AgreementStatus.cancelled:
        // TODO: Update these with your actual colors when ready
        return context.color.grayComponent;
    }
  }

  Color getStatusTextColor(BuildContext context) {
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
      case AgreementStatus.rejected:
      case AgreementStatus.cancelled:
        // TODO: Update these with your actual colors when ready
        return context.color.grey800;
    }
  }

  String getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
    final isPending = status == AgreementStatus.awaitingRecipient ||
        status == AgreementStatus.awaitingFunding;
    final amIInitiator = initiator?.id == currentUser.id;
    final isSender = sender?.id == currentUser.id;
    final isRecipient = recipient?.id == currentUser.id;

    // 2. Evaluate "Action Required" logic
    bool needsAction = (isPending && !amIInitiator) ||
        (status == AgreementStatus.readyForRelease && isSender);

    // 3. Evaluate Physical Delivery states ONLY for "Action Required"
    if (status == AgreementStatus.inProgress && physicalDeliveryContext != null) {
      final deliveryStatus = physicalDeliveryContext!.status;

      if (deliveryStatus == PhysicalDeliveryContextStatus.awaitingPackaging ||
          deliveryStatus == PhysicalDeliveryContextStatus.awaitingDispatch) {
        if (isRecipient) needsAction = true;
      } else if (deliveryStatus == PhysicalDeliveryContextStatus.awaitingBuyerAcknowledgement) {
        if (isSender) needsAction = true;
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

  DateTime? dueDate({Milestone? currentlyRunning}) {
    switch (disbursementType) {
      case DisbursementType.oneTime:
        return expectedReleaseDate!;
      case DisbursementType.milestones:
        if (currentlyRunning != null) {
          return currentlyRunning.expectedReleaseDate;
        }
        return null;
    }
  }
}
