import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/providers/activity/activity_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/agreements/view_model/agreements_view_model.dart';
import 'package:cleer/ui/home/home/view_model/notification_permission_view_model.dart';
import 'package:cleer/ui/home/home/widgets/notification_permission_bottom_sheet.dart';
import 'package:cleer/ui/agreements/agreements/widgets/agreement_card.dart';
import 'package:cleer/ui/agreements/agreements/widgets/agreement_card_skeleton_list.dart';
import 'package:cleer/ui/core/widgets/user_profile_pill.dart';
import 'package:cleer/ui/home/home/widgets/escrow_summary_card.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/action_alerts/widgets/action_alerts_carousel.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/paginated_list/paginated_list.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer/ui/home/home/widgets/quick_actions_section.dart';
import 'package:cleer_ui/widgets/app_empty_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final viewModel =
            ref.read(notificationPermissionViewModelProvider.notifier);
        final shouldShow = await viewModel.checkAndShowNudge();

        if (shouldShow && context.mounted) {
          NotificationPermissionBottomSheet.show(context);
        }
      });
      return null;
    }, []);

    final user = ref.watch(userProfileProvider).value;

    final ongoingState = ref.watch(userOngoingAgreementsProvider);
    final ongoingAgreements = ongoingState.value;
    final needsActionList = ref.watch(needsActionAgreementsProvider);
    final awaitingOtherPartyList = ref.watch(
      awaitingOtherPartyAgreementsProvider,
    );
    final protectedAmountState = ref.watch(currentlyProtectedAmountProvider);
    final protectedAmount = protectedAmountState.value ?? 0.0;

    final isSummaryLoading =
        (ongoingState.isLoading && !ongoingState.isReloading) ||
        (protectedAmountState.isLoading && !protectedAmountState.isReloading);

    final activitiesState = ref.watch(userActivitiesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight:
            (context.isMobile ? Dimens.size.s126 : Dimens.size.s72) -
            MediaQuery.of(context).padding.top,
        flexibleSpace: ResponsiveLayout(
          mobile: Container(
            height: Dimens.size.s126,
            alignment: .bottomCenter,
            padding: .symmetric(
              horizontal: Dimens.mobile.paddingScreenHorizontal,
              vertical: Dimens.padding.p22,
            ),
            decoration: BoxDecoration(
              color: context.color.secondary,
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
                      child: Assets.images.helpButton.image(
                        height: Dimens.size.s28,
                        frameBuilder:
                            (
                              context,
                              frameChild,
                              frame,
                              wasSynchronouslyLoaded,
                            ) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return frameChild;
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: .circular(Dimens.radius.r40),
                                  color: context.color.blue800.withValues(
                                    alpha: .3,
                                  ),
                                ),
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
                              );
                            },
                      ),
                    ),
                    Gap(Dimens.spacing.sp12),
                    GestureDetector(
                      onTap: () => ActivityTimelineRoute().go(context),
                      child: Assets.images.activityButton.image(
                        height: Dimens.size.s28,
                        frameBuilder:
                            (
                              context,
                              frameChild,
                              frame,
                              wasSynchronouslyLoaded,
                            ) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return frameChild;
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: .circular(Dimens.radius.r40),
                                  color: context.color.blue800.withValues(
                                    alpha: .3,
                                  ),
                                ),
                                padding: .symmetric(
                                  horizontal: Dimens.padding.p10,
                                  vertical: Dimens.padding.p6,
                                ),
                                child: Row(
                                  children: [
                                    Assets.icons.rewindTime.svg(
                                      width: Dimens.size.s16,
                                      height: Dimens.size.s16,
                                      colorFilter: ColorFilter.mode(
                                        context.color.blue100,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    Gap(Dimens.spacing.sp4),
                                    Text(
                                      l10n.activity,
                                      style: context.typo.bodyMedium.copyWith(
                                        height: 1,
                                        color: context.color.blue100,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          desktop: Container(
            decoration: BoxDecoration(
              color: context.color.background,
              border: .all(
                color: context.color.outline,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            height: Dimens.size.s72,
            alignment: .center,
            padding: .symmetric(
              horizontal: context.isTablet
                  ? Dimens.tablet.paddingScreenHorizontal
                  : Dimens.desktop.paddingScreenHorizontal,
            ),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(l10n.home, style: context.typo.headlineSmall),
                UserProfilePill(
                  profile: user,
                  // onTap: () => ProfileRoute().go(context),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: Dimens.of(context).edgeInsetsScreenHorizontal,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Gap(
                    context.isMobile
                        ? Dimens.spacing.sp20
                        : Dimens.spacing.sp32,
                  ),
                  EscrowSummaryCard(
                    currentlyProtectedAmount: protectedAmount,
                    trustScore: 100,
                    needsActionCount: needsActionList.length,
                    awaitingOtherPartyCount: awaitingOtherPartyList.length,
                    isLoading: isSummaryLoading,
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: ActionAlertsCarousel(topSpacing: Dimens.spacing.sp28),
            ),
            SliverPadding(
              padding: Dimens.of(context).edgeInsetsScreenHorizontal.copyWith(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Gap(
                    context.isMobile
                        ? Dimens.spacing.sp40
                        : Dimens.spacing.sp32,
                  ),
                  QuickActionsSection(),
                  Gap(
                    context.isMobile
                        ? Dimens.spacing.sp40
                        : Dimens.spacing.sp32,
                  ),
                  if (!context.isDesktop) ...[
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              l10n.recentActivity,
                              style:
                                  (context.isMobile
                                          ? context.typo.titleSmall
                                          : context.typo.titleMedium)
                                      .copyWith(color: context.color.grey800),
                            ),
                            GestureDetector(
                              onTap: () => context.isMobile
                                  ? ActivityTimelineRoute().go(context)
                                  : ActivityTabRoute().go(context),
                              child: Text(
                                l10n.viewAll,
                                style: context.typo.bodyLink.copyWith(
                                  color: context.color.blue700,
                                  decorationColor: context.color.blue700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(
                          context.isMobile
                              ? Dimens.spacing.sp16
                              : Dimens.spacing.sp12,
                        ),

                        activitiesState.when(
                          skipLoadingOnReload: true,
                          data: (PaginatedList<Activity> activities) {
                            if (activities.items.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Dimens.spacing.sp32,
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.noRecentActivityYet,
                                    style: context.typo.bodyMedium.copyWith(
                                      color: context.color.grey600,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final recentActivities = activities.items
                                .take(3)
                                .toList();

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: recentActivities.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  ActivityCard(
                                    activity: recentActivities[index],
                                    showDayContext: true,
                                  ),
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Gap(Dimens.spacing.sp28),
                            );
                          },
                          error: (Object error, StackTrace stackTrace) {
                            /// TODO: Add proper error state here
                            return SizedBox.shrink();
                          },
                          loading: () => ActivityCardSkeletonList(itemCount: 3),
                        ),
                      ],
                    ),

                    Gap(
                      context.isMobile
                          ? Dimens.spacing.sp20
                          : Dimens.spacing.sp32,
                    ),
                  ],
                ]),
              ),
            ),
            if (context.isDesktop)
              SliverPadding(
                padding: Dimens.of(context).edgeInsetsScreenHorizontal.copyWith(
                  bottom:
                      MediaQuery.paddingOf(context).bottom + Dimens.padding.p32,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 680,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.color.white,
                                  borderRadius: .circular(Dimens.radius.r12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      color: context.color.transparent,
                                      padding: .symmetric(
                                        horizontal: Dimens.padding.p18,
                                        vertical: 14.5,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            l10n.recentActivity,
                                            style: context.typo.titleMedium
                                                .copyWith(
                                                  color: context.color.grey800,
                                                ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                ActivityTabRoute().go(context),
                                            child: Text(
                                              l10n.viewAll,
                                              style: context.typo.bodyLink
                                                  .copyWith(
                                                    color:
                                                        context.color.blue700,
                                                    decorationColor:
                                                        context.color.blue700,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    activitiesState.when(
                                      skipLoadingOnReload: true,
                                      data:
                                          (PaginatedList<Activity> activities) {
                                            if (activities.items.isEmpty) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: Dimens.spacing.sp32,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    l10n.noRecentActivityYet,
                                                    style: context
                                                        .typo
                                                        .bodyMedium
                                                        .copyWith(
                                                          color: context
                                                              .color
                                                              .grey600,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }

                                            final recentActivities = activities
                                                .items
                                                .take(4)
                                                .toList();

                                            return Padding(
                                              padding: EdgeInsets.all(
                                                Dimens.padding.p12,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  for (
                                                    int i = 0;
                                                    i < recentActivities.length;
                                                    i++
                                                  ) ...[
                                                    ActivityCard(
                                                      activity:
                                                          recentActivities[i],
                                                      showDayContext: true,
                                                    ),
                                                    if (i <
                                                        recentActivities
                                                                .length -
                                                            1)
                                                      Gap(Dimens.spacing.sp28),
                                                  ],
                                                ],
                                              ),
                                            );
                                          },
                                      error:
                                          (
                                            Object error,
                                            StackTrace stackTrace,
                                          ) {
                                            /// TODO: Add proper error state here
                                            return SizedBox.shrink();
                                          },
                                      loading: () => ActivityCardSkeletonList(
                                        itemCount: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Gap(Dimens.spacing.sp20),
                            Expanded(
                              flex: 412,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.color.white,
                                  borderRadius: .circular(Dimens.radius.r12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      color: context.color.transparent,
                                      padding: .symmetric(
                                        horizontal: Dimens.padding.p18,
                                        vertical: 14.5,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                l10n.ongoingAgreements,
                                                style: context.typo.titleMedium
                                                    .copyWith(
                                                      color:
                                                          context.color.grey800,
                                                    ),
                                              ),
                                              if (ongoingAgreements != null &&
                                                  ongoingAgreements
                                                      .isNotEmpty) ...[
                                                Gap(Dimens.spacing.sp6),
                                                Container(
                                                  padding: .symmetric(
                                                    horizontal:
                                                        Dimens.padding.p5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        context.color.blue100,
                                                  ),
                                                  child: Text(
                                                    ongoingAgreements.length
                                                        .toString(),
                                                    style: context
                                                        .typo
                                                        .bodySmall
                                                        .copyWith(
                                                          color: context
                                                              .color
                                                              .grey600,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              ref.read(
                                                  agreementsViewModelProvider
                                                      .notifier,
                                                )
                                                ..setTabIndex(0)
                                                ..setFilter(.all);
                                              AgreementsRoute().go(context);
                                            },
                                            child: Text(
                                              l10n.viewAll,
                                              style: context.typo.bodyLink
                                                  .copyWith(
                                                    color:
                                                        context.color.blue700,
                                                    decorationColor:
                                                        context.color.blue700,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ongoingState.when(
                                      skipLoadingOnReload: true,
                                      data: (List<Agreement> ongoingAgreements) {
                                        if (ongoingAgreements.isEmpty) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: Dimens.padding.p12,
                                              vertical: Dimens.padding.p40,
                                            ),
                                            child: AppEmptyState(
                                              icon: Assets.icons.handshakeOff
                                                  .svg(
                                                    width: Dimens.size.s80,
                                                    height: Dimens.size.s80,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                          context
                                                              .color
                                                              .blue1000,
                                                          BlendMode.srcIn,
                                                        ),
                                                  ),
                                              title:
                                                  l10n.noOngoingAgreementsYet,
                                              iconBottomSpacing:
                                                  Dimens.spacing.sp32,
                                              subtitle: RichText(
                                                text: TextSpan(
                                                  style: context.typo.bodyMedium
                                                      .copyWith(
                                                        color: context
                                                            .color
                                                            .grey800,
                                                      ),
                                                  children: [
                                                    TextSpan(
                                                      text: l10n.sendFunds,
                                                      style: context
                                                          .typo
                                                          .bodyLink
                                                          .copyWith(
                                                            color: context
                                                                .color
                                                                .blue700,
                                                            decorationColor:
                                                                context
                                                                    .color
                                                                    .blue700,
                                                          ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () =>
                                                                CreateAgreementRoute(
                                                                  type: .send,
                                                                ).go(context),
                                                    ),
                                                    const TextSpan(text: ' '),
                                                    TextSpan(text: l10n.or),
                                                    const TextSpan(text: ' '),
                                                    TextSpan(
                                                      text: l10n.requestPayment,
                                                      style: context
                                                          .typo
                                                          .bodyLink
                                                          .copyWith(
                                                            color: context
                                                                .color
                                                                .blue700,
                                                            decorationColor:
                                                                context
                                                                    .color
                                                                    .blue700,
                                                          ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () =>
                                                                CreateAgreementRoute(
                                                                  type:
                                                                      .request,
                                                                ).go(context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        final recentOngoingAgreements =
                                            ongoingAgreements.take(3).toList();

                                        return Material(
                                          color: context.color.transparent,
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              Dimens.padding.p12,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                for (
                                                  int i = 0;
                                                  i <
                                                      recentOngoingAgreements
                                                          .length;
                                                  i++
                                                ) ...[
                                                  AgreementCard(
                                                    isLast:
                                                        i ==
                                                        (recentOngoingAgreements
                                                                .length -
                                                            1),
                                                    agreement:
                                                        recentOngoingAgreements[i],
                                                  ),
                                                  if (i <
                                                      recentOngoingAgreements
                                                              .length -
                                                          1)
                                                    Gap(Dimens.spacing.sp16),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      error:
                                          (
                                            Object error,
                                            StackTrace stackTrace,
                                          ) {
                                            /// TODO: Add proper error state here
                                            return SizedBox.shrink();
                                          },
                                      loading: () => Padding(
                                        padding: EdgeInsets.all(
                                          Dimens.padding.p12,
                                        ),
                                        child: AgreementCardSkeletonList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
