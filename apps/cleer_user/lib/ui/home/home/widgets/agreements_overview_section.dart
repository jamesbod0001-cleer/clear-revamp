import 'package:cleer/routing/routes.dart'
    show CreateAgreementRoute, AgreementsRoute;
import 'package:cleer/ui/agreements/agreements/state/agreements_state.dart';
import 'package:cleer/ui/agreements/agreements/view_model/agreements_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementsOverviewSection extends ConsumerWidget {
  const AgreementsOverviewSection({
    super.key,
    required this.isOngoingEmpty,
    this.needsActionCount = 0,
    this.awaitingOtherPartyCount = 0,
  });

  final bool isOngoingEmpty;
  final int needsActionCount;
  final int awaitingOtherPartyCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // if (!isOngoingEmpty &&
    //     needsActionCount == 0 &&
    //     awaitingOtherPartyCount == 0) {
    //   return const SizedBox.shrink();
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activeAgreements,
          style: context.typo.titleSmall.copyWith(color: context.color.grey800),
        ),
        Gap(Dimens.spacing.sp12),
        if (isOngoingEmpty)
          const _AgreementsEmptyState()
        else
          Row(
            children: [
              Expanded(
                child: _AgreementSummaryCard(
                  label: l10n.needsYourAction,
                  count: needsActionCount,
                  onTap: () {
                    ref.read(agreementsViewModelProvider.notifier)
                      ..setTabIndex(0)
                      ..setFilter(OngoingAgreementFilter.needsAction);

                    AgreementsRoute().go(context);
                  },
                ),
              ),
              Gap(Dimens.spacing.sp8),
              Expanded(
                child: _AgreementSummaryCard(
                  label: l10n.awaitingOtherParty,
                  count: awaitingOtherPartyCount,
                  onTap: () {
                    ref.read(agreementsViewModelProvider.notifier)
                      ..setTabIndex(0)
                      ..setFilter(OngoingAgreementFilter.awaitingOtherParty);

                    AgreementsRoute().go(context);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _AgreementSummaryCard extends StatelessWidget {
  const _AgreementSummaryCard({
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
      child: Container(
        decoration: BoxDecoration(
          color: context.color.grayComponent,
          borderRadius: BorderRadius.circular(Dimens.radius.r8),
          border: Border.all(
            color: context.color.outline.withValues(alpha: .30),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.padding.p12,
          vertical: Dimens.padding.p8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.typo.bodyMedium.copyWith(
                color: context.color.grey800,
                fontWeight: AppFontWeights.regular,
              ),
            ),
            Gap(Dimens.spacing.sp8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: .symmetric(horizontal: Dimens.padding.p6),
                  decoration: BoxDecoration(
                    color: context.color.outline,
                    borderRadius: BorderRadius.circular(Dimens.radius.r80),
                  ),

                  child: Row(
                    children: [
                      Text(
                        l10n.view,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text(
                        count.toString(),
                        style: context.typo.bodyMedium.copyWith(
                          color: context.color.blue700,
                        ),
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text(
                        l10n.agreements,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                PhosphorIcon(
                  PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                  size: Dimens.size.s20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgreementsEmptyState extends StatelessWidget {
  const _AgreementsEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: context.color.grayComponent,
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.padding.p12,
          vertical: 17.5,
        ),
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.empty(PhosphorIconsStyle.duotone),
              color: context.color.grey800,
            ),
            Gap(Dimens.spacing.sp8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.youHaveNoActiveTransactions,
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey800,
                    ),
                  ),
                  Gap(Dimens.spacing.sp2),
                  RichText(
                    text: TextSpan(
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.grey600,
                      ),
                      children: [
                        _linkSpan(
                          context,
                          text: l10n.sendFunds,
                          onTap: () => _handleSendFunds(context),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: l10n.or),
                        const TextSpan(text: ' '),
                        _linkSpan(
                          context,
                          text: l10n.requestPayment,
                          onTap: () => _handleRequestPayment(context),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: l10n.toGetStarted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Private helper to style the links and avoid repeated code
  TextSpan _linkSpan(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
  }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: context.color.blue700,
        decorationColor: context.color.blue700,
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  void _handleSendFunds(BuildContext context) =>
      CreateAgreementRoute(type: .send).push(context);
  void _handleRequestPayment(BuildContext context) =>
      CreateAgreementRoute(type: .request).push(context);
}
