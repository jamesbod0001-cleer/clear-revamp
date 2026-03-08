import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/providers/payout_destination/payout_destination_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/app_back_button.dart';
import 'package:cleer/ui/profile/payout_destination/view_model/payout_destination_view_model.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/add_bank_account.dart';
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

    final state = ref.watch(payoutDestinationViewModelProvider);
    // final viewModel = ref.read(payoutDestinationViewModelProvider.notifier);

    final userPayoutDestinationsState = ref.watch(
      userPayoutDestinationsProvider,
    );

    bool isLoading = userPayoutDestinationsState.isLoading;

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
                        return const Center(child: CircularProgressIndicator());
                      }
                      final payoutDestinations =
                          userPayoutDestinationsState.value;
                      if (payoutDestinations == null ||
                          payoutDestinations.isEmpty) {
                        return AddBankAccountTrigger.card();
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
    );
  }
}
