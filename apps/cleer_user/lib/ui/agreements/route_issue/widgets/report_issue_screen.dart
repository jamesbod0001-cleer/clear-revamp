import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ReportIssueScreen extends StatelessWidget {
  const ReportIssueScreen({
    super.key,
    required this.agreementId,
    this.initialAgreement,
  });

  final String agreementId;
  final Agreement? initialAgreement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppOfflineBannerWrapper(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: Dimens.padding.p18,
          titleTextStyle: context.typo.headlineSmall,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: .start,
            children: [
              Gap(Dimens.spacing.sp12),
              AppBackButton(),
              Gap(Dimens.spacing.sp24),
              Text(l10n.reportAnIssue),
            ],
          ),
          toolbarHeight: 102,
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                top: Dimens.padding.p4,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    l10n.fundsWillRemainSecurelyHeldWhileWeInvestigateTheDispute,
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey600,
                    ),
                  ),
                  Gap(Dimens.spacing.sp40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
