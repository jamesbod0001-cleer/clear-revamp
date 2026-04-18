import 'package:cleer/domain/models/payout_destination/payout_destination.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/status_circle_icon.dart';
import 'package:cleer/ui/profile/payout_destination/view_model/payout_destination_view_model.dart';
import 'package:cleer/ui/profile/payout_destination/widgets/payout_destination_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:listen_it/listen_it.dart';

class RemoveBankAccountBottomSheet extends HookConsumerWidget {
  const RemoveBankAccountBottomSheet({
    super.key,
    required this.payoutDestination,
  });
  final PayoutDestination payoutDestination;

  static Future<void> show(
    BuildContext context,
    PayoutDestination payoutDestination,
  ) => CustomBottomSheet.show<void>(
    context: context,
    isDismissible: true,
    child: RemoveBankAccountBottomSheet(payoutDestination: payoutDestination),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.watch(payoutDestinationViewModelProvider);
    final viewModel = ref.read(payoutDestinationViewModelProvider.notifier);

    final deletePayoutDestinationCommand =
        viewModel.deletePayoutDestinationCommand;

    useEffect(() {
      deletePayoutDestinationCommand.clearErrors();
      deletePayoutDestinationCommand.value = null;
      return null;
    }, []);

    useEffect(() {
      deletePayoutDestinationCommand.listen((
        PayoutDestination? payoutDestination,
        _,
      ) {
        if (payoutDestination != null) {
          if (context.mounted) {
            context.pop();
          }
        }
      });
      return null;
    }, [deletePayoutDestinationCommand]);

    return Stack(
      children: [
        Column(
          mainAxisSize: .min,
          children: [
            StatusCircleIcon(type: .error),
            Gap(Dimens.spacing.sp48),
            Text(
              '${l10n.removeBankAccount}?',
              style: context.typo.headlineSmall,
            ),
            Gap(Dimens.spacing.sp12),
            Text(
              l10n.thisWillRemoveThisBankAccountsAsYourPayoutDestination,
              style: context.typo.bodyMedium.copyWith(
                color: context.color.grey600,
              ),
              textAlign: .center,
            ),
            Gap(Dimens.spacing.sp12),
            PayoutDestinationCard(payoutDestination: payoutDestination, showRemove: false,),
            Gap(Dimens.spacing.sp24),
            PrimaryButton(
              backgroundColor: context.color.error,
              foregroundColor: context.color.background,
              onPressed: () =>
                  deletePayoutDestinationCommand.run(payoutDestination),
              child: Text(l10n.removeAccount),
            ),
            Gap(Dimens.spacing.sp12),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: context.color.error),
              onPressed: () => context.pop(),
              child: Text(l10n.cancel),
            ),
            Gap(Dimens.spacing.sp20),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: deletePayoutDestinationCommand.isRunning,
          builder: (BuildContext context, bool isRunning, Widget? child) {
            if (isRunning) {
              return Positioned.fill(
                child: Material(
                  color: context.color.background,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            return ValueListenableBuilder(
              valueListenable: deletePayoutDestinationCommand,
              builder:
                  (
                    BuildContext context,
                    PayoutDestination? payoutDestination,
                    Widget? child,
                  ) {
                    if (payoutDestination != null) {
                      return Positioned.fill(
                        child: Material(
                          color: context.color.background,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
            );
          },
        ),
      ],
    );
  }
}
