import 'package:cleer/domain/providers/storage/file_url_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/ui/auth/log_out/view_model/log_out_view_model.dart';
import 'package:cleer/ui/auth/log_out/widgets/log_out_button.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/images/app_image.dart';
import 'package:cleer/ui/core/ui/images/blur_hash_widget.dart';
import 'package:cleer/ui/core/ui/trust_score_badge.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_menu_tile.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_section_header.dart';
import 'package:cleer/ui/profile/profile/widgets/user_performance_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider).value;

    final bool viewModelsLoading = ref.watch(logOutViewModelProvider).isLoading;

    final bool isRedirectingOrSyncing = ref
        .watch(authUseCaseProvider)
        .maybeWhen(
          data: (state) => state is SignedOut,
          loading: () => true,
          orElse: () => false,
        );

    bool isLoading =
        viewModelsLoading ||
        isRedirectingOrSyncing ||
        ref.watch(userProvider).isLoading;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        title: Container(
          height: Dimens.size.s54,
          alignment: .bottomLeft,
          child: Text(l10n.profile),
        ),
        toolbarHeight: Dimens.size.s70,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                  top: Dimens.padding.p10,
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                '${user?.firstName} ${user?.lastName}',
                                style: context.typo.headlineSmall.copyWith(
                                  fontWeight: AppFontWeights.medium,
                                  fontSize: AppFontSizes.s28,
                                  color: context.color.grey600,
                                ),
                              ),
                              TrustScoreBadge(score: 100),
                              Gap(Dimens.spacing.sp8),
                              Text(
                                l10n.memberSince(
                                  DateFormat(
                                    'd MMM, y',
                                  ).format(user!.createdAt!),
                                ),
                                style: context.typo.bodySmall.copyWith(
                                  color: context.color.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(Dimens.spacing.sp20),
                        Column(
                          children: [
                            Container(
                              width: Dimens.radius.r80, // radius * 2
                              height: Dimens.radius.r80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.color.grayComponent,
                              ),
                              child: ClipOval(
                                child: Builder(
                                  builder: (BuildContext context) {
                                    if (user.profilePicture == null) {
                                      return Center(
                                        child: PhosphorIcon(
                                          PhosphorIcons.user(),
                                          size: Dimens.size.s32,
                                          color: context.color.grey400,
                                        ),
                                      );
                                    }
                                    final profileUrlAsync = ref.watch(
                                      fileUrlProvider(user.profilePicture!.key),
                                    );
                                    return profileUrlAsync.when(
                                      data: (url) => AppImage(
                                        imageUrl: url,
                                        blurHash:
                                            user.profilePicture!.blurHash ?? '',
                                        fit: BoxFit.cover,
                                      ),
                                      loading: () => BlurHashWidget(
                                        hash:
                                            user.profilePicture!.blurHash ?? '',
                                      ),
                                      error: (_, _) => Center(
                                        child: PhosphorIcon(
                                          PhosphorIcons.imageBroken(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gap(Dimens.spacing.sp28),

                    UserPerformanceStatsCard(
                      successfulAgreements: 0,
                      disputeFreeAgreements: 0,
                      totalValueTransacted: '₦0',
                    ),
                    Gap(Dimens.spacing.sp28),

                    ProfileSectionHeader(title: l10n.payoutDestination),
                    ProfileMenuTile(
                      icon: PhosphorIcons.bank(.duotone),
                      title: l10n.payoutAccounts,
                      content:
                          l10n.manageTheBankAccountThatReceivesReleasedFunds,
                      onTap: () => PayoutDestinationRoute().go(context),
                      showBottomPadding: false,
                    ),
                    Gap(Dimens.spacing.sp40),

                    // PayoutDestinationCard(),
                    // Gap(Dimens.spacing.sp16),
                    // AddBankAccountButton(),
                    // Gap(Dimens.spacing.sp40),
                    ProfileSectionHeader(title: l10n.settings),
                    ProfileMenuTile(
                      icon: PhosphorIcons.key(.duotone),
                      title: l10n.accountAndSecurity,
                      content:
                          l10n.viewYourAccountDetailsAndChangeYourLoginPassword,
                      onTap: () => AccountSecurityRoute().go(context),
                    ),
                    ProfileMenuTile(
                      icon: PhosphorIcons.bell(.duotone),
                      title: l10n.manageNotifications,
                      content: l10n
                          .chooseHowYouReceiveAlertsForReleasesNewDealsAndStatusChanges,
                      onTap: () {},
                      showBottomPadding: false,
                    ),
                    Gap(Dimens.spacing.sp40),

                    ProfileSectionHeader(title: l10n.legalAndPolicies),
                    ProfileMenuTile(
                      icon: PhosphorIcons.scroll(.duotone),
                      title: l10n.termsAndPolicies,
                      content: l10n
                          .viewTheRulesAndAgreementsThatGovernYourUseOfTheCleerPlatform,
                      onTap: () {},
                    ),
                    ProfileMenuTile(
                      icon: PhosphorIcons.fileLock(.duotone),
                      title: l10n.dataUsageAndPrivacy,
                      content: l10n
                          .seeHowYourTransactionAndIdentityDataIsUsedToSecureYourDeals,
                      onTap: () {},
                      showBottomPadding: false,
                    ),
                    Gap(Dimens.spacing.sp40),

                    ProfileSectionHeader(title: l10n.assistanceAndFeedback),
                    ProfileMenuTile(
                      icon: PhosphorIcons.question(.duotone),
                      title: l10n.helpAndSupport,
                      content: l10n
                          .viewTheRulesAndAgreementsThatGovernYourUseOfTheCleerPlatform,
                      onTap: () {},
                    ),
                    ProfileMenuTile(
                      icon: PhosphorIcons.star(.duotone),
                      title: l10n.rateCleerOnPlayStore,
                      content:
                          l10n.shareYourExperienceAndHelpUsBuildABetterPlatform,
                      onTap: () {},
                      showBottomPadding: false,
                    ),

                    const Spacer(),
                    Gap(Dimens.spacing.sp70),
                    LogOutButton(),
                    Gap(Dimens.spacing.sp24),
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
