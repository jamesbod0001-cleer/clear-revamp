import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/agreement/agreement_preview.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/accept_agreement/view_model/accept_agreement_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/form_error.dart';
import 'package:cleer/utils/identity_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementDetailsStep extends HookConsumerWidget {
  const AgreementDetailsStep({super.key, required this.shortCode});

  final String shortCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final User? user = ref.watch(userProvider).value;

    final state = ref.watch(acceptAgreementViewModelProvider((shortCode)));
    final viewModel = ref.read(
      acceptAgreementViewModelProvider(shortCode).notifier,
    );

    final AgreementPreview? previewAgreement = state.value?.agreementPreview;

    final isExpanded = useState(true);

    String title() {
      String fullName = previewAgreement?.initiator?.fullName ?? '';
      if (previewAgreement?.initiatorRole == .sender) {
        return l10n.wantsToPayYouSecurely(fullName);
      } else {
        return l10n.paymentAgreementFrom(fullName);
      }
    }

    final ValueNotifier<String?> errorMessage = useState(null);
    void setErrorMessage(String? message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        errorMessage.value = message;
      });
    }

    // I need a better name for this function
    bool enableActionButtons() {
      if (user != null) {
        if (previewAgreement?.initiator?.id == user.id) {
          setErrorMessage(
            "You can not accept this agreement. You can't accept an agreement you created",
          );
          return false;
        }
        if (previewAgreement?.initiatorRole == .sender) {
          if (previewAgreement?.recipient != null) {
            // Meaning yes a recipient is already connected to it
            // Check if the signed in user is the same has the recipient connected to it
            if (user.id == previewAgreement?.recipient?.id) {
              // Meaning the signed in user is the same as the recipient
              setErrorMessage(null);
              return true;
            } else {
              // Meaning the signed in user is not the same as the recipient
              setErrorMessage(
                'You can not accept this agreement. You are not the recipient of this agreement',
              );
              return false;
            }
          } else {
            // Meaning no a recipient is not connected to it
            // Do a name match between the recipient account name and the signed in user full name
            if (IdentityUtils.isNameMatch(
              userName: user.fullName,
              bankAccountName: previewAgreement?.recipientAccountName ?? '',
            )) {
              // Meaning the bank account belongs to this user and can go on
              setErrorMessage(null);
              return true;
            } else {
              // Meaning the bank account does not belong to this user
              setErrorMessage(
                'You can not accept this agreement. You can only accept agreements where the recipient bank account is in your name.',
              );
              return false;
            }
          }
        }
      }
      setErrorMessage(null);
      return true;
    }

    return PopScope(
      child: Builder(
        builder: (context) {
          if (state.hasError &&
              state.error is UnknownDataFailure &&
              (state.error as UnknownDataFailure).code == 'BackendException') {
            return Padding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal,
              child: Center(
                child: FormError(
                  hasError: state.hasError,
                  errorMessage:
                      state.error != null && state.error is UnknownDataFailure
                      ? (state.error as UnknownDataFailure).message
                      : null,
                ),
              ),
            );
          }
          if (previewAgreement == null) {
            return Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              PinnedHeaderSliver(
                child: Container(
                  color: context.color.background,
                  child: Padding(
                    padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                      top: Dimens.padding.p24,
                      bottom: Dimens.padding.p8,
                    ),
                    child: Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Text(
                            title(),
                            style: context.typo.headlineSmall.copyWith(
                              color: context.color.grey800,
                            ),
                          ),
                        ),
                        Gap(Dimens.spacing.sp20),
                        IconButton(
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimens.padding.p6,
                              vertical: Dimens.padding.p8,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {},
                          icon: PhosphorIcon(
                            PhosphorIcons.x(),
                            color: context.color.grey1000,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Gap(Dimens.spacing.sp24),
                    FormError(
                      hasError:
                          !enableActionButtons() && errorMessage.value != null,
                      errorMessage: errorMessage.value,
                    ),
                    if (previewAgreement.disbursementType == .milestones)
                      Column(
                        crossAxisAlignment: .start,
                        mainAxisSize: .min,
                        children: [
                          Text(
                            l10n.paymentWillBeReleasedInMilestones,
                            style: context.typo.bodyMedium.copyWith(
                              fontWeight: AppFontWeights.regular,
                              color: context.color.grey600,
                            ),
                          ),
                          Gap(Dimens.spacing.sp4),
                          Container(
                            margin: .only(bottom: Dimens.padding.p40),
                            color: context.color.transparent,
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              onExpansionChanged: (value) =>
                                  isExpanded.value = value,
                              trailing: PhosphorIcon(
                                isExpanded.value
                                    ? PhosphorIcons.caretUp()
                                    : PhosphorIcons.caretDown(),
                                size: Dimens.size.s16,
                                color: context.color.blue700,
                              ),
                              tilePadding: .zero,
                              minTileHeight: 0,
                              visualDensity: .comfortable,
                              childrenPadding: .zero,
                              collapsedShape: Border(
                                bottom: BorderSide(
                                  color: context.color.outline,
                                ),
                              ),
                              shape: Border(),
                              title: Text(
                                l10n.milestoneBreakdown,
                                style: context.typo.labelSmall.copyWith(
                                  color: context.color.grey600,
                                ),
                              ),
                              children: List.generate(
                                previewAgreement.milestones?.length ?? 0,
                                (int index) {
                                  final milestone =
                                      previewAgreement.milestones?[index];
                                  if (milestone == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: index == 0
                                            ? BorderSide(
                                                color: context.color.black
                                                    .withValues(alpha: .10),
                                              )
                                            : .none,
                                      ),
                                    ),
                                    padding: .only(top: Dimens.padding.p12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: Dimens.size.s16,
                                          height: Dimens.size.s16,
                                          decoration: BoxDecoration(
                                            shape: .circle,
                                            color: context.color.transparent,
                                            border: .all(
                                              color: context.color.outline,
                                            ),
                                          ),
                                        ),
                                        Gap(Dimens.spacing.sp8),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: .min,
                                            crossAxisAlignment: .start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    l10n.milestoneCount(
                                                      index + 1,
                                                    ),
                                                    style: context
                                                        .typo
                                                        .bodyMedium
                                                        .copyWith(
                                                          fontWeight:
                                                              AppFontWeights
                                                                  .regular,
                                                          color: context
                                                              .color
                                                              .grey600,
                                                        ),
                                                  ),
                                                  Gap(Dimens.spacing.sp24),
                                                  Text(
                                                    DateFormat(
                                                      'dd/MM/yyyy',
                                                    ).format(
                                                      milestone
                                                          .expectedReleaseDate,
                                                    ),
                                                    style: context
                                                        .typo
                                                        .bodySmall
                                                        .copyWith(
                                                          color: context
                                                              .color
                                                              .grey600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Gap(Dimens.spacing.sp2),
                                              Row(
                                                mainAxisAlignment:
                                                    .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      milestone.name,
                                                      style: context
                                                          .typo
                                                          .bodyMedium
                                                          .copyWith(
                                                            fontWeight:
                                                                AppFontWeights
                                                                    .regular,
                                                          ),
                                                      overflow: .ellipsis,
                                                    ),
                                                  ),
                                                  Gap(Dimens.spacing.sp24),
                                                  Text(
                                                    "${l10n.nairaSign}${NumberFormat('#,###.##').format(milestone.amount)}",
                                                    style: context
                                                        .typo
                                                        .labelMedium,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                    Container(
                      padding: .all(Dimens.padding.p12),
                      decoration: BoxDecoration(
                        color: context.color.blue100,
                        borderRadius: .circular(Dimens.radius.r8),
                      ),
                      child: Column(
                        crossAxisAlignment: .stretch,
                        spacing: Dimens.spacing.sp24,
                        children: [
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Text(
                                '${l10n.amount}:',
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                  color: context.color.grey600,
                                ),
                              ),
                              Gap(Dimens.spacing.sp28),
                              Expanded(
                                child: Text(
                                  "${l10n.nairaSign}${NumberFormat('#,###.##').format(previewAgreement.amount)}",
                                  style: context.typo.labelMedium,
                                  textAlign: .end,
                                ),
                              ),
                            ],
                          ),
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
                                  '${previewAgreement.recipientBankName} - ${previewAgreement.recipientAccountName}',
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
                                  previewAgreement.recipientAccountNumber ?? '',
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
                                  previewAgreement.category.label,
                                  style: context.typo.bodyMedium.copyWith(
                                    fontWeight: AppFontWeights.regular,
                                  ),
                                  textAlign: .end,
                                  overflow: .ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (previewAgreement.disbursementType == .oneTime)
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
                                    DateFormat('dd/MM/yyyy').format(
                                      previewAgreement.expectedReleaseDate!,
                                    ),
                                    style: context.typo.bodyMedium.copyWith(
                                      fontWeight: AppFontWeights.regular,
                                    ),
                                    textAlign: .end,
                                    overflow: .ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          Divider(
                            color: context.color.background,
                            height: Dimens.size.s1,
                            thickness: Dimens.size.s1,
                          ),
                          Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                l10n.purpose,
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                  color: context.color.grey600,
                                ),
                              ),
                              Gap(Dimens.spacing.sp4),
                              Text(
                                previewAgreement.description,
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisSize: .min,
                    mainAxisAlignment: .end,
                    children: [
                      Gap(Dimens.spacing.sp30),
                      Visibility(
                        visible: previewAgreement.initiatorRole == .recipient,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: .circular(Dimens.radius.r8),
                            color: context.color.grayComponent,
                          ),
                          padding: .all(Dimens.padding.p8),
                          margin: .only(bottom: Dimens.padding.p20),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: Dimens.padding.p3,
                                ),
                                child: PhosphorIcon(
                                  PhosphorIcons.info(),
                                  color: context.color.grey800,
                                ),
                              ),
                              Gap(Dimens.spacing.sp16),
                              Expanded(
                                child: Text(
                                  l10n.fundsWillBeHeldSafelyAndOnlyReleasedWhenYouConfirmDelivery,
                                  style: context.typo.bodyMedium.copyWith(
                                    color: context.color.grey800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: previewAgreement.initiatorRole == .sender,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: Dimens.padding.p8),
                          child: Text(
                            user == null
                                ? l10n.acceptToCreateAnAccountAndReceivePaymentSecurely
                                : l10n.acceptToReceivePaymentSecurely,
                            style: context.typo.bodySmall.copyWith(
                              color: context.color.grey600,
                            ),
                          ),
                        ),
                      ),
                      PrimaryButton(
                        onPressed: enableActionButtons() ? () {} : null,
                        child: Text(
                          previewAgreement.initiatorRole == InitiatorRole.sender
                              ? l10n.acceptAgreement
                              : l10n.continueToPayment,
                        ),
                      ),
                      Gap(Dimens.spacing.sp12),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: context.color.error,
                        ),
                        onPressed: enableActionButtons() ? () {} : null,
                        child: Text(l10n.declineAgreement),
                      ),
                      Gap(Dimens.spacing.sp20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
