import 'dart:math';

import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/action_alerts/widgets/action_alerts_carousel.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/home/home/widgets/agreements_overview_section.dart';
import 'package:cleer/ui/home/home/widgets/quick_actions_section.dart';
import 'package:cleer/ui/home/home/widgets/secured_funds_overview.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final ongoingState = ref.watch(userOngoingAgreementsProvider);
    final needsActionList = ref.watch(needsActionAgreementsProvider);
    final readyForReleaseList = ref.watch(awaitingOtherPartyAgreementsProvider);

    final isLoading = ongoingState.isLoading;
    final isOngoingEmpty = (ongoingState.value ?? []).isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: Dimens.size.s126 - MediaQuery.of(context).padding.top,
        flexibleSpace: Container(
          height: Dimens.size.s126,
          alignment: .bottomCenter,
          padding: .symmetric(
            horizontal: Dimens.padding.p18,
            vertical: Dimens.padding.p22,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.appBarBackground.provider(),
              fit: BoxFit.cover,
            ),
          ),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                l10n.cleer,
                style: context.typo.headlineMedium.copyWith(
                  color: context.color.background,
                  fontWeight: AppFontWeights.bold,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => HelpSupportRoute().push(context),
                    child: LiquidGlass.withOwnLayer(
                      glassContainsChild: true,
                      settings: LiquidGlassSettings(
                        saturation: 1,
                        blur: 20,
                        thickness: 12,
                        lightIntensity: .8,
                        lightAngle: pi / 4,
                        refractiveIndex: 1.1,
                        glassColor: context.color.blue800.withAlpha(30),
                      ),
                      shape: LiquidRoundedRectangle(
                        borderRadius: Dimens.radius.r48,
                      ),
                      child: SizedBox(
                        width: Dimens.size.s70,
                        height: Dimens.size.s28,
                        child: Padding(
                          padding: .symmetric(
                            horizontal: Dimens.padding.p10,
                            vertical: Dimens.padding.p6,
                          ),
                          child: Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.headset(.duotone),
                                color: context.color.blue100,
                                size: Dimens.size.s16,
                              ),
                              Gap(Dimens.spacing.sp4),
                              Text(
                                l10n.help,
                                style: context.typo.bodyMedium.copyWith(
                                  height: 1,
                                  color: context.color.blue100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(Dimens.spacing.sp12),
                  LiquidGlass.withOwnLayer(
                    glassContainsChild: true,
                    settings: LiquidGlassSettings(
                      saturation: 1,
                      blur: 20,
                      thickness: 12,
                      lightIntensity: .8,
                      lightAngle: pi / 4,
                      refractiveIndex: 1.1,
                      glassColor: context.color.blue800.withAlpha(30),
                    ),
                    shape: LiquidRoundedRectangle(
                      borderRadius: Dimens.radius.r48,
                    ),
                    child: SizedBox(
                      width: Dimens.size.s70,
                      height: Dimens.size.s28,
                      child: Padding(
                        padding: .symmetric(
                          horizontal: Dimens.padding.p10,
                          vertical: Dimens.padding.p6,
                        ),
                        child: Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.lineSegments(.duotone),
                              color: context.color.blue100,
                              size: Dimens.size.s16,
                            ),
                            Gap(Dimens.spacing.sp4),
                            Text(
                              l10n.logs,
                              style: context.typo.bodyMedium.copyWith(
                                height: 1,
                                color: context.color.blue100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                top: Dimens.padding.p10,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Gap(Dimens.spacing.sp20),
                  SecuredFundsOverview(totalFunds: '₦0', trustScore: 100),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: ActionAlertsCarousel(topSpacing: Dimens.spacing.sp28),
            ),
            SliverPadding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Gap(Dimens.spacing.sp40),
                  if (isLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                    Gap(Dimens.spacing.sp40),
                  ] else  ...[
                    AgreementsOverviewSection(
                      isOngoingEmpty: isOngoingEmpty,
                      needsActionCount: needsActionList.length,
                      awaitingOtherPartyCount: readyForReleaseList.length,
                    ),
                    Gap(Dimens.spacing.sp40),
                  ],
                  QuickActionsSection(),
                  Gap(Dimens.spacing.sp40),
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        l10n.recentActivity,
                        style: context.typo.titleSmall.copyWith(
                          color: context.color.grey800,
                        ),
                      ),
                      Text(
                        l10n.viewAll,
                        style: context.typo.bodyLink.copyWith(
                          color: context.color.blue700,
                          decorationColor: context.color.blue700,
                        ),
                      ),
                    ],
                  ),
                  Gap(Dimens.spacing.sp16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
