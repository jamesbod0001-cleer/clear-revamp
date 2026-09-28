import 'package:cleer/domain/providers/dispute/dispute_provider.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/approve_service_payment_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/confirm_item_received_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/dispute_notice_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/dispute_report_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/mark_service_completed_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/review_delivery_information_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/review_package_photos_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/share_delivery_information_card.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/upload_package_photos_card.dart';
import 'package:cleer/ui/agreements/extensions/agreement_ui_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ============================================================================
// DYNAMIC HEADER
// ============================================================================

class DynamicAgreementHeader extends ConsumerWidget {
  const DynamicAgreementHeader({
    super.key,
    required this.agreement,
    required this.currentUser,
  });

  final Agreement agreement;
  final User? currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (agreement.isDisputed && agreement.id != null) {
      final disputeState = ref.watch(
        activeAgreementDisputeProvider(agreement.id!),
      );
      final dispute = disputeState.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DisputeNoticeCard(),
          Gap(Dimens.spacing.sp20),
          Skeletonizer(
            enabled: disputeState.isLoading && !disputeState.isReloading,
            child: DisputeReportCard(
              dispute:
                  dispute ??
                  Dispute(
                    id: 'id',
                    reason: .deliveryIssue,
                    description: 'description',
                  ),
            ),
          ),
        ],
      );
    }

    if ([
      AgreementStatus.draft,
      AgreementStatus.released,
    ].contains(agreement.status)) {
      return const SizedBox.shrink();
    }

    final isSender = agreement.sender?.id == currentUser?.id;
    final isRecipient = agreement.recipient?.id == currentUser?.id;

    // STEP 1: Attempt to get a high-priority action card
    final actionCard = _getActionCard(isSender, isRecipient);
    if (actionCard != null) {
      return actionCard;
    }

    // STEP 2: Handle edge cases where NO header should show
    if (agreement.status == AgreementStatus.funded &&
        agreement.category == AgreementCategory.physicalGoods) {
      return const SizedBox.shrink();
    }

    // STEP 3: Fallback to the informational banner
    return AgreementActionBanner(
      agreement: agreement,
      currentUser: currentUser,
    );
  }

  // --- HELPER DELEGATES ---

  Widget? _getActionCard(bool isSender, bool isRecipient) {
    if (agreement.category == AgreementCategory.physicalGoods) {
      return _getPhysicalGoodsAction(isSender, isRecipient);
    } else if (agreement.category == AgreementCategory.servicesWork) {
      return _getServicesAction(isSender, isRecipient);
    }
    return null;
  }

  Widget? _getPhysicalGoodsAction(bool isSender, bool isRecipient) {
    final deliveryCtx = agreement.physicalDeliveryContext;

    if (agreement.status == AgreementStatus.inProgress && deliveryCtx != null) {
      if (isSender) {
        if (deliveryCtx.status ==
                PhysicalDeliveryContextStatus.awaitingDispatch &&
            deliveryCtx.packagingPhotos != null) {
          return ReviewPackagePhotosCard(agreement: agreement);
        }
        if (deliveryCtx.status ==
                PhysicalDeliveryContextStatus.awaitingBuyerAcknowledgement &&
            deliveryCtx.deliveryDetails != null) {
          return ReviewDeliveryInformationCard(agreement: agreement);
        }
      } else if (isRecipient) {
        if (deliveryCtx.status ==
            PhysicalDeliveryContextStatus.awaitingPackaging) {
          return UploadPackagePhotosCard(agreement: agreement);
        }
        if (deliveryCtx.status ==
            PhysicalDeliveryContextStatus.awaitingDispatch) {
          return ShareDeliveryInformationCard(agreement: agreement);
        }
      }
    } else if (agreement.status == AgreementStatus.readyForRelease) {
      if (isSender &&
          deliveryCtx?.status == PhysicalDeliveryContextStatus.inTransit) {
        return ConfirmItemReceivedCard(agreement: agreement);
      }
    }
    return null;
  }

  Widget? _getServicesAction(bool isSender, bool isRecipient) {
    final isOneTime = agreement.disbursementType == DisbursementType.oneTime;
    final isMilestones =
        agreement.disbursementType == DisbursementType.milestones;

    final activeStatus = agreement.activeMilestoneStatus;

    if (agreement.status == AgreementStatus.inProgress) {
      if (isRecipient) {
        if (isOneTime) {
          return MarkServiceCompletedCard(agreement: agreement);
        }
        if (isMilestones && activeStatus == 'IN_PROGRESS') {
          return MarkServiceCompletedCard(agreement: agreement);
        }
      } else if (isSender) {
        if (isMilestones && activeStatus == 'READY_FOR_RELEASE') {
          return ApproveServicePaymentCard(agreement: agreement);
        }
      }
    } else if (agreement.status == AgreementStatus.readyForRelease) {
      if (isSender && isOneTime) {
        return ApproveServicePaymentCard(agreement: agreement);
      }
    }
    return null;
  }
}

// ============================================================================
// BANNER DATA CLASS & WIDGET
// ============================================================================

class _BannerData {
  final IconData icon;
  final String statusLabel;
  final String title;
  final String description;

  _BannerData(this.icon, this.statusLabel, this.title, this.description);
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
    final data = _getBannerData(context);
    if (data == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.padding.p12,
        vertical: Dimens.padding.p8,
      ),
      decoration: BoxDecoration(
        color: context.color.outline,
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
      ),
      child: Row(
        children: [
          Container(
            width: Dimens.size.s36,
            height: Dimens.size.s36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.color.grayComponent,
                width: Dimens.size.s2,
              ),
            ),
            child: Center(
              child: PhosphorIcon(
                data.icon,
                color: context.color.blue800,
                size: Dimens.size.s16,
              ),
            ),
          ),
          Gap(Dimens.spacing.sp12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.statusLabel,
                  style: context.typo.bodySmall.copyWith(
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp4),
                Text(data.title, style: context.typo.titleSmall),
                Gap(Dimens.spacing.sp4),
                Text(
                  data.description,
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

  // --- LOGIC EXTRACTOR ---

  _BannerData? _getBannerData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amIInitiator = agreement.initiator?.id == currentUser?.id;
    final isSender = agreement.sender?.id == currentUser?.id;
    final isRecipient = agreement.recipient?.id == currentUser?.id;

    final activeStatus = agreement.activeMilestoneStatus;

    switch (agreement.status) {
      case AgreementStatus.awaitingRecipient:
        if (amIInitiator) {
          return _BannerData(
            PhosphorIcons.handshake(PhosphorIconsStyle.duotone),
            agreement.recipient != null
                ? l10n.waitingOnUser(agreement.recipient!.firstName)
                : l10n.waitingForAcceptance,
            l10n.noActionNeededFromYouRightNow,
            agreement.recipient != null
                ? l10n.notifyWhenUserAccepts(agreement.recipient!.firstName)
                : l10n.wellNotifyYouTheMomentTheAgreementHasBeenAccepted,
          );
        }
        break;

      case AgreementStatus.awaitingFunding:
        if (amIInitiator) {
          return _BannerData(
            PhosphorIcons.handshake(PhosphorIconsStyle.duotone),
            agreement.sender != null
                ? l10n.waitingOnUser(agreement.sender!.firstName)
                : l10n.waitingForPayment,
            l10n.noActionNeededFromYouRightNow,
            agreement.sender != null
                ? l10n.notifyWhenUserDepositsFunds(agreement.sender!.firstName)
                : l10n.wellNotifyYouTheMomentTheFundsHaveBeenDeposited,
          );
        }
        break;

      case AgreementStatus.funded:
      case AgreementStatus.inProgress:
        if (agreement.category == AgreementCategory.physicalGoods) {
          if (isSender) {
            if (agreement.physicalDeliveryContext?.status ==
                PhysicalDeliveryContextStatus.awaitingPackaging) {
              return _BannerData(
                PhosphorIcons.images(PhosphorIconsStyle.duotone),
                l10n.waitingForPackageImages,
                l10n.noActionNeededFromYouRightNow,
                l10n.theVendorIsPreparingYourItemAndUploadingPackagePhotosBeforeShipment,
              );
            } else if (agreement.physicalDeliveryContext?.status ==
                    PhysicalDeliveryContextStatus.awaitingDispatch &&
                agreement.physicalDeliveryContext?.packagingPhotos == null) {
              return _BannerData(
                PhosphorIcons.truck(PhosphorIconsStyle.duotone),
                l10n.waitingForDeliveryInformation,
                l10n.noActionNeededFromYouRightNow,
                l10n.theVendorIsSharingDeliveryDetailsSoYouKnowWhoWillBeDeliveringYourItem,
              );
            }
          } else if (isRecipient) {
            if (agreement.physicalDeliveryContext?.status ==
                PhysicalDeliveryContextStatus.awaitingBuyerAcknowledgement) {
              return _BannerData(
                PhosphorIcons.truck(PhosphorIconsStyle.duotone),
                l10n.waitingForBuyerConfirmation,
                l10n.noActionNeededFromYouRightNow,
                l10n.theBuyerIsReviewingTheDeliveryDetailsYouShared,
              );
            }
          }
        } else if (agreement.category == AgreementCategory.servicesWork) {
          if (agreement.disbursementType == DisbursementType.milestones &&
              activeStatus == 'PROCESSING_RELEASE') {
            if (isRecipient) {
              return _BannerData(
                PhosphorIcons.hourglass(PhosphorIconsStyle.duotone),
                l10n.releaseProcessing,
                l10n.fundsAreOnTheWay,
                l10n.theClientHasApprovedTheReleaseTheFundsWillArriveInYourRegisteredPayoutDestinationWithin2Hours,
              );
            } else if (isSender) {
              return _BannerData(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
                l10n.releaseProcessing,
                l10n.paymentReleased,
                l10n.youHaveSuccessfullyApprovedThisPaymentTheFundsAreCurrentlyBeingRoutedToTheProvider,
              );
            }
          }

          if (isSender) {
            return _BannerData(
              PhosphorIcons.gear(PhosphorIconsStyle.duotone),
              agreement.disbursementType == DisbursementType.milestones
                  ? l10n.milestoneInProgress
                  : l10n.serviceInProgress,
              l10n.noActionNeededFromYouRightNow,
              agreement.disbursementType == DisbursementType.milestones
                  ? l10n.thisMilestoneIsNowActiveYouWillBeNotifiedOnceTheProviderMarksItAsCompleted
                  : l10n.theAgreementIsNowActiveYouWillBeNotifiedWhenTheProviderMarksTheServiceAsCompleted,
            );
          } else if (isRecipient && activeStatus == 'READY_FOR_RELEASE') {
            return _BannerData(
              PhosphorIcons.hourglass(PhosphorIconsStyle.duotone),
              l10n.waitingForMilestonePayment,
              l10n.noActionNeededFromYouRightNow,
              l10n.yourClientHasBeenNotifiedThatThisMilestoneIsCompleteAndCanNowReleasePayment,
            );
          } else if (isRecipient &&
              agreement.status == AgreementStatus.funded) {
            return _BannerData(
              PhosphorIcons.gear(PhosphorIconsStyle.duotone),
              l10n.completeAgreedService,
              l10n.noActionNeededFromYouRightNow,
              l10n.onceYouHaveCompletedTheAgreedWorkNotifyYourClientSoTheyCanReleasePayment,
            );
          }
        }
        break;

      case AgreementStatus.readyForRelease:
        if (agreement.category == AgreementCategory.physicalGoods) {
          if (agreement.physicalDeliveryContext?.status ==
              PhysicalDeliveryContextStatus.inTransit) {
            return _BannerData(
              PhosphorIcons.truck(PhosphorIconsStyle.duotone),
              l10n.waitingForBuyerVerification,
              l10n.noActionNeededFromYouRightNow,
              l10n.theBuyerHasNotYetVerifiedPickup,
            );
          }
        } else if (agreement.category == AgreementCategory.servicesWork &&
            isRecipient) {
          return _BannerData(
            PhosphorIcons.hourglass(PhosphorIconsStyle.duotone),
            l10n.waitingForPayment,
            l10n.noActionNeededFromYouRightNow,
            l10n.yourClientHasBeenNotifiedThatTheServiceIsCompleteAndCanNowReleasePayment,
          );
        }
        break;

      case AgreementStatus.processingRelease:
        if (isRecipient) {
          return _BannerData(
            PhosphorIcons.hourglass(PhosphorIconsStyle.duotone),
            l10n.releaseProcessing,
            l10n.fundsAreOnTheWay,
            l10n.theClientHasApprovedTheReleaseTheFundsWillArriveInYourRegisteredPayoutDestinationWithin2Hours,
          );
        } else if (isSender) {
          return _BannerData(
            PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
            l10n.releaseProcessing,
            l10n.paymentReleased,
            l10n.youHaveSuccessfullyApprovedThisPaymentTheFundsAreCurrentlyBeingRoutedToTheProvider,
          );
        }
        break;

      default:
        break;
    }

    return _BannerData(
      PhosphorIcons.info(PhosphorIconsStyle.duotone),
      kEmpty,
      kEmpty,
      kEmpty,
    );
  }
}
