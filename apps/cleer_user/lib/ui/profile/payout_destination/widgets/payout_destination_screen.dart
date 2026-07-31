import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/core/extensions/error_ui_extensions.dart';
import 'package:cleer_core/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/providers/payout_destination/payout_destination_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/app_empty_state.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer/ui/profile/payout_destination/view_model/payout_destination_view_model.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/add_bank_account_trigger.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/payout_destination_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PayoutDestinationScreen extends ConsumerWidget {
  const PayoutDestinationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.watch(payoutDestinationViewModelProvider);
    // final viewModel = ref.read(payoutDestinationViewModelProvider.notifier);

    final userPayoutDestinationsState = ref.watch(
      userPayoutDestinationsProvider,
    );

    bool isLoading =
        userPayoutDestinationsState.isLoading &&
        !userPayoutDestinationsState.isReloading;

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
              Text(l10n.payoutDestination),
            ],
          ),
          toolbarHeight: 102,
        ),
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                  top: Dimens.padding.p4,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      l10n.whereReleasedFundsWillBeSentAfterASuccessfulAgreement,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp32),
                    Builder(
                      builder: (BuildContext context) {
                        if (isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (userPayoutDestinationsState.hasError) {
                          return userPayoutDestinationsState.error!
                              .toErrorState(
                                ref,
                                onRetry: () => ref.invalidate(
                                  userPayoutDestinationsProvider,
                                ),
                              );
                        }
                        final payoutDestinations =
                            userPayoutDestinationsState.value;
                        if (payoutDestinations == null ||
                            payoutDestinations.isEmpty) {
                          return Center(
                            heightFactor: 2,
                            child: AppEmptyState(
                              icon: Assets.icons.bankOff.svg(
                                width: Dimens.size.s80,
                                height: Dimens.size.s80,
                                colorFilter: ColorFilter.mode(
                                  context.color.blue1000,
                                  BlendMode.srcIn,
                                ),
                              ),
                              title: l10n.noPayoutDestinationYet,
                              iconBottomSpacing: Dimens.spacing.sp32,
                              subtitle: AddBankAccountTrigger.button(),
                            ),
                          );
                        }

                        List<PayoutDestination> sortedList = List.from(
                          payoutDestinations,
                        )..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

                        return Column(
                          children: [
                            ...List.generate(sortedList.length, (int index) {
                              final payoutDestination = sortedList[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: (index == sortedList.length - 1)
                                      ? Dimens.padding.p0
                                      : Dimens.padding.p16,
                                ),
                                child: PayoutDestinationCard(
                                  payoutDestination: payoutDestination,
                                ),
                              );
                            }),
                            Gap(Dimens.spacing.sp32),
                            Center(child: AddBankAccountTrigger.button()),
                          ],
                        );
                      },
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
                      Gap(Dimens.spacing.sp40),
                      Container(
                        padding: .all(Dimens.padding.p8),
                        decoration: BoxDecoration(
                          color: context.color.grayComponent,
                          borderRadius: BorderRadius.circular(Dimens.radius.r8),
                        ),
                        child: Row(
                          crossAxisAlignment: .start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: PhosphorIcon(
                                PhosphorIcons.info(),
                                color: context.color.grey800,
                              ),
                            ),
                            Gap(Dimens.spacing.sp12),
                            Expanded(
                              child: Text(
                                l10n.fundsAreOnlyPaidOutToVerifiedBankAccountsInYourName,
                                style: context.typo.bodyMedium.copyWith(
                                  color: context.color.grey800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(Dimens.spacing.sp20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
