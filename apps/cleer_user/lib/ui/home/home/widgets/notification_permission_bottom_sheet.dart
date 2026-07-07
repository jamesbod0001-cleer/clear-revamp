import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/home/home/view_model/notification_permission_view_model.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/utils/keys.dart';
import 'package:cleer_ui/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NotificationPermissionBottomSheet extends ConsumerWidget {
  const NotificationPermissionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final rootContext = cleerNavigatorKey.currentContext ?? context;
    return CustomBottomSheet.show(
      context: rootContext,
      child: const NotificationPermissionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = ref.watch(
      notificationPermissionViewModelProvider.notifier,
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && result != true) {
          viewModel.skipForNow();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusCircleIcon(type: .bellRinging),
          Gap(Dimens.spacing.sp24),
          Text(
            l10n.wellLetYouKnowWhenItMatters,
            style: context.typo.headlineSmall,
          ),
          Gap(Dimens.spacing.sp24),
          Text(
            l10n.noSpamJustImportantUpdatesAboutYourAgreementsPaymentsDeliveriesAndDisputes,
            style: context.typo.bodyMedium.copyWith(
              fontWeight: AppFontWeights.regular,
              color: context.color.grey600,
            ),
          ),
          Gap(Dimens.spacing.sp24),
          PrimaryButton(
            onPressed: () async {
              await viewModel.requestPermissions();
              if (context.mounted) context.pop(true);
            },
            child: Text(l10n.enableNotifications),
          ),
          Gap(Dimens.spacing.sp12),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.skipForNow),
          ),
          Gap(Dimens.spacing.sp24),
        ],
      ),
    );
  }
}
