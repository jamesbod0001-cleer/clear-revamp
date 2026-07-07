import 'package:cleer/ui/agreements/agreement_details/widgets/confirm_item_received_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/mark_service_completed_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/review_delivery_information_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/review_package_photos_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/share_delivery_information_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/upload_package_photos_card.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DynamicAgreementHeader extends StatelessWidget {
  const DynamicAgreementHeader({
    super.key,
    required this.agreement,
    required this.currentUser,
  });

  final Agreement agreement;
  final User? currentUser;

  @override
  Widget build(BuildContext context) {
    // final amIInitiator = agreement.initiator?.id == currentUser?.id;
    final isSender = agreement.sender?.id == currentUser?.id;
    final isRecipient = agreement.recipient?.id == currentUser?.id;

    switch (agreement.status) {
      case AgreementStatus.awaitingRecipient:
      case AgreementStatus.awaitingFunding:
      case AgreementStatus.funded:
        if (agreement.category == .servicesWork) {
          return AgreementActionBanner(
            agreement: agreement,
            currentUser: currentUser,
          );
        }
        return SizedBox();
      case AgreementStatus.inProgress:
        if (agreement.category == AgreementCategory.physicalGoods) {
          if (isSender) {
            if (agreement.physicalDeliveryContext!.status ==
                    .awaitingDispatch &&
                agreement.physicalDeliveryContext!.packagingPhotos != null) {
              // Meaning the Vendor uploaded packaging photos
              return ReviewPackagePhotosCard(agreement: agreement);
            } else if (agreement.physicalDeliveryContext!.status ==
                    .awaitingBuyerAcknowledgement &&
                agreement.physicalDeliveryContext!.deliveryDetails != null) {
              return ReviewDeliveryInformationCard(agreement: agreement);
            }
          } else if (isRecipient) {
            final needsToUploadPackagingPhotos =
                agreement.physicalDeliveryContext?.status == .awaitingPackaging;
            final needsToShareDelivery =
                agreement.physicalDeliveryContext?.status == .awaitingDispatch;
            if (needsToUploadPackagingPhotos) {
              return UploadPackagePhotosCard(agreement: agreement);
            } else if (needsToShareDelivery) {
              return ShareDeliveryInformationCard(agreement: agreement);
            }
          }
        } else if (agreement.category == .servicesWork) {
          if (isRecipient) {
            return MarkServiceCompletedCard(agreement: agreement);
          }
        }
        // Fallback to a standard banner if no specific action is needed
        return AgreementActionBanner(
          agreement: agreement,
          currentUser: currentUser,
        );
      case AgreementStatus.readyForRelease:
        if (agreement.category == AgreementCategory.physicalGoods) {
          if (isSender) {
            if (agreement.physicalDeliveryContext!.status == .inTransit) {
              return ConfirmItemReceivedCard(agreement: agreement);
            }
          }
        }
        // Fallback to a standard banner if no specific action is needed
        return AgreementActionBanner(
          agreement: agreement,
          currentUser: currentUser,
        );

      default:
        // Returns an empty widget for states that don't need a header
        return const SizedBox.shrink();
    }
  }
}

class AgreementActionBanner extends StatelessWidget {
  const AgreementActionBanner({
    super.key,
    required this.agreement,
    required this.currentUser,
  });
  final Agreement agreement;
  final User? currentUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final amIInitiator = agreement.initiator?.id == currentUser?.id;
    final isSender = agreement.sender?.id == currentUser?.id;
    final isRecipient = agreement.recipient?.id == currentUser?.id;

    IconData? icon;
    String statusLabel = kEmpty;
    String title = kEmpty;
    String description = kEmpty;

    switch (agreement.status) {
      case AgreementStatus.awaitingRecipient:
        if (amIInitiator) {
          icon = PhosphorIcons.handshake(.duotone);
          statusLabel = agreement.recipient != null
              ? l10n.waitingOnUser(agreement.recipient!.firstName)
              : l10n.waitingForAcceptance;
          title = l10n.noActionNeededFromYouRightNow;
          description = agreement.recipient != null
              ? l10n.notifyWhenUserAccepts(agreement.recipient!.firstName)
              : l10n.wellNotifyYouTheMomentTheAgreementHasBeenAccepted;
        }
      case AgreementStatus.awaitingFunding:
        if (amIInitiator) {
          icon = PhosphorIcons.handshake(.duotone);
          statusLabel = agreement.sender != null
              ? l10n.waitingOnUser(agreement.sender!.firstName)
              : l10n.waitingForPayment;
          title = l10n.noActionNeededFromYouRightNow;
          description = agreement.sender != null
              ? l10n.notifyWhenUserDepositsFunds(agreement.sender!.firstName)
              : l10n.wellNotifyYouTheMomentTheFundsHaveBeenDeposited;
        }
      case AgreementStatus.funded:
        if (agreement.category == AgreementCategory.servicesWork) {
          if (isSender) {
            icon = PhosphorIcons.gear(.duotone);
            statusLabel = l10n.serviceInProgress;
            title = l10n.noActionNeededFromYouRightNow;
            description = agreement.disbursementType == .milestones
                ? l10n.theServiceProviderIsCurrentlyWorkingOnTheActiveMilestoneWeWillNotifyYouWhenTheyMarkItAsCompleted
                : l10n.theServiceProviderIsCurrentlyWorkingOnTheAgreedServiceWeWillNotifyYouWhenTheyMarkItAsCompleted;
          } else if (isRecipient) {
            icon = PhosphorIcons.gear(.duotone);
            statusLabel = l10n.completeAgreedService;
            title = l10n.noActionNeededFromYouRightNow;
            description = l10n
                .onceYouHaveCompletedTheAgreedWorkNotifyYourClientSoTheyCanReleasePayment;
          }
        }
      case AgreementStatus.inProgress:
        if (agreement.category == AgreementCategory.physicalGoods) {
          /// TODO: I still need to come back here later...
          if (isSender) {
            if (agreement.physicalDeliveryContext!.status ==
                .awaitingPackaging) {
              icon = PhosphorIcons.images(.duotone);
              statusLabel = l10n.waitingForPackageImages;
              title = l10n.noActionNeededFromYouRightNow;
              description = l10n
                  .theVendorIsPreparingYourItemAndUploadingPackagePhotosBeforeShipment;
            } else if (agreement.physicalDeliveryContext!.status ==
                .awaitingDispatch) {
              if (agreement.physicalDeliveryContext!.packagingPhotos == null) {
                // Meaning the Vendor skipped uploading packaging photos
                icon = PhosphorIcons.truck(.duotone);
                statusLabel = l10n.waitingForDeliveryInformation;
                title = l10n.noActionNeededFromYouRightNow;
                description = l10n
                    .theVendorIsSharingDeliveryDetailsSoYouKnowWhoWillBeDeliveringYourItem;
              }
            }
          } else if (isRecipient) {
            if (agreement.physicalDeliveryContext!.status ==
                .awaitingBuyerAcknowledgement) {
              icon = PhosphorIcons.truck(.duotone);
              statusLabel = l10n.serviceInProgress;
              title = l10n.noActionNeededFromYouRightNow;
              description = l10n.theBuyerIsReviewingTheDeliveryDetailsYouShared;
            }
          }
        } else if (agreement.category == AgreementCategory.servicesWork) {
          if (isSender) {
            icon = PhosphorIcons.gear(.duotone);
            statusLabel = l10n.serviceInProgress;
            title = l10n.noActionNeededFromYouRightNow;
            description = agreement.disbursementType == .milestones
                ? l10n.theServiceProviderIsCurrentlyWorkingOnTheActiveMilestoneWeWillNotifyYouWhenTheyMarkItAsCompleted
                : l10n.theServiceProviderIsCurrentlyWorkingOnTheAgreedServiceWeWillNotifyYouWhenTheyMarkItAsCompleted;
          }
        }
      case AgreementStatus.readyForRelease:
        if (agreement.category == AgreementCategory.physicalGoods) {
          if (agreement.physicalDeliveryContext!.status == .inTransit) {
            icon = PhosphorIcons.truck(.duotone);
            statusLabel = l10n.waitingForBuyerVerification;
            title = l10n.noActionNeededFromYouRightNow;
            description = l10n.theBuyerHasNotYetVerifiedPickup;
          }
        }
      default:
        icon = PhosphorIcons.info(.duotone);
        statusLabel = kEmpty;
        title = kEmpty;
        description = kEmpty;
      // case AgreementStatus.draft:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AgreementStatus.funded:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AgreementStatus.readyForRelease:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AgreementStatus.processingRelease:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AgreementStatus.cancelled:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AgreementStatus.rejected:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AgreementStatus.released:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
    }

    return Container(
      padding: .symmetric(
        horizontal: Dimens.padding.p12,
        vertical: Dimens.padding.p8,
      ),
      decoration: BoxDecoration(
        color: context.color.outline,
        borderRadius: .circular(Dimens.radius.r8),
      ),
      child: Row(
        children: [
          Container(
            width: Dimens.size.s36,
            height: Dimens.size.s36,
            decoration: BoxDecoration(
              shape: .circle,
              border: .all(
                color: context.color.grayComponent,
                width: Dimens.size.s2,
              ),
            ),
            child: Center(
              child: PhosphorIcon(
                icon!,
                color: context.color.blue800,
                size: Dimens.size.s16,
              ),
            ),
          ),
          Gap(Dimens.spacing.sp12),
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(
                  statusLabel,
                  style: context.typo.bodySmall.copyWith(
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp4),
                Text(title, style: context.typo.titleSmall),
                Gap(Dimens.spacing.sp4),
                Text(
                  description,
                  style: context.typo.bodySmall.copyWith(
                    color: context.color.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
