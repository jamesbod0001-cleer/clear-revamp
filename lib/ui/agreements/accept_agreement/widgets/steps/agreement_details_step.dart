import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/agreement/agreement_preview.dart';
import 'package:cleer/domain/models/milestone/milestone_preview.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/accept_agreement/state/accept_agreement_state.dart';
import 'package:cleer/ui/agreements/accept_agreement/view_model/accept_agreement_view_model.dart';
import 'package:cleer/ui/agreements/accept_agreement/widgets/decline_agreement_bottom_sheet.dart';
import 'package:cleer/ui/core/extensions/string_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/form_error.dart';
import 'package:cleer/ui/core/ui/status_circle_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementDetailsStep extends HookConsumerWidget {
  const AgreementDetailsStep({super.key, required this.shortCode, this.action});

  final String shortCode;
  final String? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final User? user = ref.watch(userProvider).value;
    final state = ref.watch(acceptAgreementViewModelProvider((shortCode)));
    final viewModel = ref.read(
      acceptAgreementViewModelProvider(shortCode).notifier,
    );
    final AgreementPreview? previewAgreement = state.value?.agreementPreview;

    final errorType = viewModel.getEligibilityError(user, previewAgreement);
    final bool isEligible = errorType == null;

    String? getErrorMessage() {
      switch (errorType) {
        case EligibilityErrorType.cannotAcceptOwn:
          return l10n.youCannotActionAnAgreementYouCreated(
            action ?? l10n.accept.toLowerCase(),
          );
        case EligibilityErrorType.notTheRecipient:
          return l10n.youAreNotTheRecipientOfThisAgreement;
        case EligibilityErrorType.nameMismatch:
          return l10n
              .youCanOnlyActionAgreementsWhereTheRecipientBankAccountIsInYourName(
                action ?? l10n.accept.toLowerCase(),
              );
        case EligibilityErrorType.doesNotBelongToYou:
          return l10n.thisAgreementDoesNotBelongToYou;
        case null:
          return null;
      }
    }

    final eligibilityError = getErrorMessage();

    void handleGuestRouting(String actionIntent) {
      final hasOppositeParty =
          (previewAgreement?.initiatorRole == .sender &&
              previewAgreement?.recipient != null) ||
          (previewAgreement?.initiatorRole == .recipient &&
              previewAgreement?.sender != null);

      if (hasOppositeParty) {
        LoginRoute(
          redirectTo: '/a/$shortCode?action=$actionIntent',
        ).go(context);
      } else {
        CreateAccountRoute(
          redirectTo: '/a/$shortCode?action=$actionIntent',
        ).go(context);
      }
    }

    void handleAccept() async {
      if (previewAgreement?.initiatorRole == InitiatorRole.sender) {
        await viewModel.acceptAgreementAsRecipient();
      } else if (previewAgreement?.initiatorRole == InitiatorRole.recipient) {
        await viewModel.acceptAgreementAsSender();
      }
    }

    final isAutoProcessing = useState(action != null);

    Future<void> handleDecline() async {
      bool? isDeclining = await DeclineAgreementBottomSheet.show(
        context,
        onConfirm: () async {
          context.pop(true);
          await viewModel.declineAgreement();
        },
      );
      isAutoProcessing.value = isDeclining ?? false;
    }

    final hasAutoTriggered = useRef(false);
    useEffect(() {
      if (user != null &&
          action != null &&
          !hasAutoTriggered.value &&
          previewAgreement != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isEligible) {
            hasAutoTriggered.value = true;
            if (action == 'accept') {
              handleAccept();
            } else if (action == 'decline') {
              handleDecline();
            }
          } else {
            hasAutoTriggered.value = true;
            isAutoProcessing.value = false;
          }
        });
      }
      return null;
    }, [user, action, previewAgreement, isEligible]);

    void onPrimaryButtonPressed() {
      if (user == null) {
        handleGuestRouting('accept');
        return;
      }

      if (isEligible) {
        handleAccept();
      }
    }

    String title() {
      String fullName = previewAgreement?.initiator?.fullName ?? '';
      if (previewAgreement?.initiatorRole == .sender) {
        return l10n.wantsToPayYouSecurely(fullName);
      } else {
        return l10n.paymentAgreementFrom(fullName);
      }
    }

    return PopScope(
      child: Builder(
        builder: (context) {
          if (state.hasError &&
              state.error is UnknownDataFailure &&
              (state.error as UnknownDataFailure).code == 'BackendException') {
            String? errorMessage =
                state.error != null && state.error is UnknownDataFailure
                ? (state.error as UnknownDataFailure).message
                : null;
            return Padding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 196),
                  StatusCircleIcon(type: .error),
                  Gap(Dimens.spacing.sp24),
                  Text(
                    errorMessage ?? l10n.unknownExceptionMessage,
                    style: context.typo.headlineSmall,
                    textAlign: .center,
                  ),
                  const Spacer(flex: 328),
                  OutlinedButton(
                    onPressed: () => HomeRoute().go(context),
                    child: Text(l10n.goToDashboard),
                  ),
                  Gap(Dimens.spacing.sp20),
                ],
              ),
            );
          }
          if (previewAgreement == null || isAutoProcessing.value) {
            return Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              _Header(title: title()),
              SliverPadding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Gap(Dimens.spacing.sp24),
                    FormError(
                      hasError: !isEligible && user != null,
                      errorMessage: eligibilityError,
                    ),
                    if (previewAgreement.disbursementType == .milestones)
                      _MilestoneBreakdown(
                        milestones: previewAgreement.milestones!
                          ..sort((a, b) => a.order.compareTo(b.order)),
                      ),
                    _AgreementSummaryCard(previewAgreement: previewAgreement),
                  ]),
                ),
              ),
              _ActionFooter(
                shortCode: shortCode,
                user: user,
                previewAgreement: previewAgreement,
                isEligible: isEligible,
                onPrimaryButtonPressed: onPrimaryButtonPressed,
                handleDecline: handleDecline,
                handleGuestRouting: handleGuestRouting,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return PinnedHeaderSliver(
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
                  title,
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
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    HomeRoute().go(context);
                  }
                },
                icon: PhosphorIcon(
                  PhosphorIcons.x(),
                  color: context.color.grey1000,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementSummaryCard extends StatelessWidget {
  final AgreementPreview previewAgreement;
  const _AgreementSummaryCard({required this.previewAgreement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
                  previewAgreement.initiatorRole == .recipient
                      ? previewAgreement
                                .recipientAccountNumber
                                ?.maskAccountNumber ??
                            ''
                      : previewAgreement.recipientAccountNumber ?? '',
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
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(previewAgreement.expectedReleaseDate!),
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
    );
  }
}

class _MilestoneBreakdown extends HookWidget {
  final List<MilestonePreview> milestones;
  const _MilestoneBreakdown({required this.milestones});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = useState(true);
    return Column(
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
            onExpansionChanged: (value) => isExpanded.value = value,
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
              bottom: BorderSide(color: context.color.outline),
            ),
            shape: Border(),
            title: Text(
              l10n.milestoneBreakdown,
              style: context.typo.labelSmall.copyWith(
                color: context.color.grey600,
              ),
            ),
            children: List.generate(milestones.length, (int index) {
              final milestone = milestones[index];

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: index == 0
                        ? BorderSide(
                            color: context.color.black.withValues(alpha: .10),
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
                        border: .all(color: context.color.outline),
                      ),
                    ),
                    Gap(Dimens.spacing.sp8),
                    Expanded(
                      child: Column(
                        mainAxisSize: .min,
                        crossAxisAlignment: .start,
                        children: [
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Text(
                                l10n.milestoneCount(index + 1),
                                style: context.typo.bodyMedium.copyWith(
                                  fontWeight: AppFontWeights.regular,
                                  color: context.color.grey600,
                                ),
                              ),
                              Gap(Dimens.spacing.sp24),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(milestone.expectedReleaseDate),
                                style: context.typo.bodySmall.copyWith(
                                  color: context.color.grey600,
                                ),
                              ),
                            ],
                          ),
                          Gap(Dimens.spacing.sp2),
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  milestone.name,
                                  style: context.typo.bodyMedium.copyWith(
                                    fontWeight: AppFontWeights.regular,
                                  ),
                                  overflow: .ellipsis,
                                ),
                              ),
                              Gap(Dimens.spacing.sp24),
                              Text(
                                "${l10n.nairaSign}${NumberFormat('#,###.##').format(milestone.amount)}",
                                style: context.typo.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({
    required this.shortCode,
    required this.user,
    required this.previewAgreement,
    required this.isEligible,
    required this.onPrimaryButtonPressed,
    required this.handleDecline,
    required this.handleGuestRouting,
  });

  final String shortCode;
  final User? user;
  final AgreementPreview previewAgreement;
  final bool isEligible;
  final VoidCallback onPrimaryButtonPressed;
  final VoidCallback handleDecline;
  final Function(String actionIntent) handleGuestRouting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SliverFillRemaining(
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
                      padding: EdgeInsets.only(top: Dimens.padding.p3),
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
              onPressed: isEligible ? onPrimaryButtonPressed : null,
              child: Text(
                previewAgreement.initiatorRole == InitiatorRole.sender
                    ? l10n.acceptAgreement
                    : l10n.continueToPayment,
              ),
            ),
            Gap(Dimens.spacing.sp12),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: context.color.error),
              onPressed: isEligible
                  ? () {
                      if (user == null) {
                        handleGuestRouting('decline');
                      } else {
                        handleDecline();
                      }
                    }
                  : null,
              child: Text(l10n.declineAgreement),
            ),
            Gap(Dimens.spacing.sp20),
          ],
        ),
      ),
    );
  }
}
