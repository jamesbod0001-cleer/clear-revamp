import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart'; // For context.color and context.typo
import 'package:flutter/material.dart';

extension AgreementUIExtensions on Agreement {
  Color getStatusPillColor(BuildContext context) {
    switch (status) {
      case AgreementStatus.draft:
      case AgreementStatus.awaitingRecipient:
      case AgreementStatus.awaitingFunding:
        return context.color.warningLight;
      case AgreementStatus.funded:
      case AgreementStatus.inProgress:
        return context.color.infoLight;
      case AgreementStatus.released:
        return context.color.successLight;
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
        return context.color.info;
      case AgreementStatus.released:
        return context.color.success;
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
        return l10n.fundsHeld;
      case AgreementStatus.released:
        return l10n.released;
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
      case AgreementStatus.cancelled:
      case AgreementStatus.released:
        return l10n.agreementWith(partnerName);
    }
  }

  Widget getActionWidget(BuildContext context, {required User? currentUser}) {
    if (currentUser == null ||
        initiator == null ||
        (initiatorRole == .sender ? sender == null : recipient == null)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    if (status == AgreementStatus.awaitingRecipient ||
        status == AgreementStatus.awaitingFunding) {
      if (initiator!.id == currentUser.id) {
        return Text(
          l10n.awaitingResponse,
          style: context.typo.labelSmall.copyWith(color: context.color.warning),
        );
      } else {
        return Text(
          l10n.actionRequired,
          style: context.typo.bodyLink.copyWith(
            color: context.color.blue700,
            decorationColor: context.color.blue700,
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  DateTime get dueDate {
    switch (disbursementType) {
      case DisbursementType.oneTime:
        return expectedReleaseDate!;
      case DisbursementType.milestones:

        /// TODO: Come back and set it to use the ongoing milestone date
        return DateTime.now();
    }
  }
}
