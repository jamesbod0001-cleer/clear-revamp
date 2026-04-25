import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/app_back_button.dart';
import 'package:cleer/ui/core/ui/tiles/menu_action_tile.dart';
import 'package:cleer/ui/core/ui/menu_section_header.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
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
            Text(l10n.howCanWeHelpYou),
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
                  l10n.getQuickAnswersOrTalkToOurSupportTeam,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp40),

                MenuSectionHeader(title: l10n.talkToSupport),
                Row(
                  spacing: Dimens.spacing.sp8,
                  children: [
                    Expanded(
                      child: Container(
                        padding: .all(Dimens.padding.p8),
                        decoration: BoxDecoration(
                          color: context.color.grayComponent,
                          borderRadius: .circular(Dimens.radius.r8),
                          border: Border.all(color: context.color.blue200),
                        ),
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .start,
                          children: [
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.chatCenteredDots(.duotone),
                                  color: context.color.blue700,
                                  size: Dimens.size.s24,
                                ),
                                PhosphorIcon(
                                  PhosphorIcons.caretRight(
                                    PhosphorIconsStyle.bold,
                                  ),
                                  color: context.color.blue700,
                                  size: Dimens.size.s20,
                                ),
                              ],
                            ),
                            Gap(Dimens.spacing.sp12),
                            Text(
                              l10n.chatSupport,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: .all(Dimens.padding.p8),
                        decoration: BoxDecoration(
                          color: context.color.grayComponent,
                          borderRadius: .circular(Dimens.radius.r8),
                          border: Border.all(color: context.color.blue200),
                        ),
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .start,
                          children: [
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.mailbox(.duotone),
                                  color: context.color.blue700,
                                  size: Dimens.size.s24,
                                ),
                                PhosphorIcon(
                                  PhosphorIcons.caretRight(
                                    PhosphorIconsStyle.bold,
                                  ),
                                  color: context.color.blue700,
                                  size: Dimens.size.s20,
                                ),
                              ],
                            ),
                            Gap(Dimens.spacing.sp12),
                            Text(
                              l10n.emailSupport,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: .all(Dimens.padding.p8),
                        decoration: BoxDecoration(
                          color: context.color.grayComponent,
                          borderRadius: .circular(Dimens.radius.r8),
                          border: Border.all(color: context.color.blue200),
                        ),
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .start,
                          children: [
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.phone(.duotone),
                                  color: context.color.blue700,
                                  size: Dimens.size.s24,
                                ),
                                PhosphorIcon(
                                  PhosphorIcons.caretRight(
                                    PhosphorIconsStyle.bold,
                                  ),
                                  color: context.color.blue700,
                                  size: Dimens.size.s20,
                                ),
                              ],
                            ),
                            Gap(Dimens.spacing.sp12),
                            Text(
                              l10n.callSupport,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp40),

                MenuSectionHeader(title: l10n.quickHelp),
                MenuActionTile(
                  title: l10n.faqs,
                  icon: PhosphorIcons.questionMark(.duotone),
                  onTap: () {},
                ),
                Gap(Dimens.spacing.sp8),
                MenuActionTile(
                  title: l10n.howEscrowWorks,
                  icon: PhosphorIcons.fileText(.duotone),
                  onTap: () {},
                ),

                Gap(Dimens.spacing.sp8),
                MenuActionTile(
                  title: l10n.reportAnIssue,
                  icon: PhosphorIcons.notePencil(.duotone),
                  onTap: () {},
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
