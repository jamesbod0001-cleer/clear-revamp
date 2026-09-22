import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ReportIssueScreen extends HookWidget {
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
    final isExpanded = useState(true);

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
                  Gap(Dimens.spacing.sp16),
                  CustomTextFormField(
                    // controller: categoryController,
                    labelText: l10n.reason,
                    readOnly: true,
                    // onTap: () => _showCategoryPickerBottomSheet(
                    //   context,
                    //   selectedCategory,
                    // ),
                    // suffixIcon: IconButton(
                    //   onPressed: () => _showCategoryPickerBottomSheet(
                    //     context,
                    //     selectedCategory,
                    //   ),
                    //   icon: PhosphorIcon(
                    //     PhosphorIcons.caretDown(),
                    //     color: context.color.blue700,
                    //   ),
                    // ),
                  ),
                  Gap(Dimens.spacing.sp24),
                  CustomTextFormField(
                    // controller: descriptionController,
                    label: RichText(
                      text: TextSpan(
                        style: context.typo.bodyMedium.copyWith(
                          color: context.color.grey600,
                        ),
                        children: [
                          TextSpan(text: l10n.describeExactlyWhatWentWrong),
                          TextSpan(text: ' '),
                          TextSpan(
                            text: l10n
                                .includeDatesTimesAndWhatSpecificAgreementTermsWereViolated,
                            style: TextStyle(
                              color: context.color.grey500,
                              fontStyle: .italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    maxLines: 6,
                    minLines: 6,
                    maxLength: 500,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return l10n.fieldRequired('description');
                    //   }
                    //   if (value.length <= 2) {
                    //     return l10n.fieldTooShort('Description', 3);
                    //   }
                    //   return null;
                    // },
                  ),
                  Gap(Dimens.spacing.sp24),
                  RichText(
                    text: TextSpan(
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                      children: [
                        TextSpan(
                          text: l10n.evidenceUpload,
                          style: TextStyle(fontWeight: AppFontWeights.semiBold),
                        ),
                        TextSpan(text: ' '),
                        TextSpan(
                          text: l10n
                              .photosScreenShotsDocumentsOrVideosThatCanHelpExplainTheIssue,
                        ),
                      ],
                    ),
                  ),
                  Gap(Dimens.spacing.sp8),
                  Text(
                    l10n.selectFileToUpload,
                    style: context.typo.bodyLink.copyWith(
                      color: context.color.blue700,
                      decorationColor: context.color.blue700,
                      decorationThickness: (17 / 100) * 14,
                    ),
                  ),
                  Gap(Dimens.spacing.sp32),
                  ExpansionTile(
                    backgroundColor: context.color.infoLight,
                    collapsedBackgroundColor: context.color.infoLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(Dimens.radius.r8),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: .circular(Dimens.radius.r8),
                    ),
                    childrenPadding: .fromLTRB(
                      Dimens.padding.p36,
                      Dimens.padding.p0,
                      Dimens.padding.p0,
                      Dimens.padding.p8,
                    ),
                    expandedAlignment: .centerLeft,
                    tilePadding: .symmetric(
                      horizontal: Dimens.padding.p12,
                      vertical: Dimens.padding.p4,
                    ),
                    minTileHeight: Dimens.size.s0,
                    initiallyExpanded: true,
                    onExpansionChanged: (value) => isExpanded.value = value,
                    title: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: Dimens.padding.p1),
                          child: PhosphorIcon(
                            PhosphorIcons.info(),
                            size: Dimens.size.s20,
                            color: context.color.info,
                          ),
                        ),
                        Gap(Dimens.spacing.sp8),
                        Text(
                          l10n.whatHappensNext,
                          style: context.typo.bodySmall.copyWith(
                            color: context.color.info,
                          ),
                        ),
                      ],
                    ),
                    trailing: PhosphorIcon(
                      isExpanded.value
                          ? PhosphorIcons.caretUp()
                          : PhosphorIcons.caretDown(),
                      color: context.color.blue700,
                    ),
                    children: [
                      Text(
                        l10n.whatHappensNextContent,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.info,
                        ),
                      ),
                    ],
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
                  mainAxisAlignment: .end,
                  children: [
                    Gap(Dimens.spacing.sp30),
                    PrimaryButton(onPressed: () {}, child: Text(l10n.submit)),
                    Gap(Dimens.spacing.sp20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
