import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/domain/providers/payout_destination/payout_destination_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/add_bank_account_trigger.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/payout_destination_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LinkedBankAccountsBottomSheet extends HookConsumerWidget {
  const LinkedBankAccountsBottomSheet({super.key});

  static Future<PayoutDestination?> show(BuildContext context) =>
      CustomBottomSheet.show<PayoutDestination>(
        context: context,
        isDismissible: true,
        child: const LinkedBankAccountsBottomSheet(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final userPayoutDestinationsState = ref.watch(
      userPayoutDestinationsProvider,
    );

    List<PayoutDestination> sortedList = List.from(
      userPayoutDestinationsState.value ?? [],
    )..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    bool isLoading = userPayoutDestinationsState.isLoading;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text(l10n.linkedBankAccounts, style: context.typo.headlineSmall),
              Gap(Dimens.spacing.sp24),
              Column(
                children: List.generate(sortedList.length, (int index) {
                  final payoutDestination = sortedList[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: (index == sortedList.length - 1)
                          ? Dimens.padding.p0
                          : Dimens.padding.p16,
                    ),
                    child: GestureDetector(
                      onTap: () => context.pop(payoutDestination),
                      child: PayoutDestinationCard(
                        payoutDestination: payoutDestination,
                        showRemove: false,
                      ),
                    ),
                  );
                }),
              ),
              Gap(Dimens.spacing.sp16),
              AddBankAccountTrigger.button(
                onResult: (PayoutDestination payoutDestination) =>
                    context.pop(payoutDestination),
              ),
              Gap(Dimens.spacing.sp32),
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
        Visibility(
          visible: isLoading,
          child: Positioned.fill(
            child: Material(
              color: context.color.background,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }
}
