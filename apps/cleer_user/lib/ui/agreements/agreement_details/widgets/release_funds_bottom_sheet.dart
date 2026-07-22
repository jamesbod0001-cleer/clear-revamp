import 'package:cleer/domain/providers/milestone/milestone_provider.dart';
import 'package:cleer/ui/agreements/agreement_details/view_model/release_funds_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ReleaseFundsBottomSheet extends ConsumerWidget {
  const ReleaseFundsBottomSheet({super.key, required this.agreement});

  final Agreement agreement;

  static Future<void> show(
    BuildContext context, {
    required Agreement agreement,
  }) {
    return CustomBottomSheet.show(
      context: context,
      child: ReleaseFundsBottomSheet(agreement: agreement),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // final state = ref.watch(releaseFundsViewModelProvider(agreement.id!));
    final viewModel = ref.read(
      releaseFundsViewModelProvider(agreement.id!).notifier,
    );

    late String title;
    late String subtitle;
    late String body;
    late String actionText;

    if (agreement.category == .physicalGoods) {
      title = "${l10n.releaseFunds}?";
      subtitle = l10n.releasePhysicalGoodsWarningSubtitle(
        '${l10n.nairaSign}${NumberFormat('#,###.##').format(agreement.amount)}',
        agreement.recipient?.fullName ?? l10n.theVendor,
      );
      body = l10n.releasePhysicalGoodsWarningBody;
      actionText = l10n.releaseFunds;
    } else {
      if (agreement.disbursementType == .milestones) {
        final milestones =
            ref.watch(agreementMilestonesProvider(agreement.id!)).value ?? [];
        final milestone = milestones.firstWhereOrNull(
          (m) => m.id == agreement.activeMilestoneId,
        );

        title = "${l10n.releaseMilestonePaymentTitle(milestone?.order ?? 1)}?";
        subtitle = l10n.releaseMilestoneWarningSubtitle(
          '${l10n.nairaSign}${NumberFormat('#,###.##').format(milestone?.amount ?? 0)}',
          agreement.recipient?.fullName ?? l10n.theProvider,
          milestone?.name ?? l10n.thisMilestone,
        );
        body = l10n.releaseMilestoneWarningBody;
        actionText = l10n.releasePayment;
      } else {
        title = "${l10n.releasePayment}?";
        subtitle = l10n.releaseServiceWarningSubtitle(
          '${l10n.nairaSign}${NumberFormat('#,###.##').format(agreement.amount)}',
          agreement.recipient?.fullName ?? l10n.theProvider,
        );
        body = l10n.releaseServiceWarningBody;
        actionText = l10n.releasePayment;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusCircleIcon(type: .unknown),
        Gap(Dimens.spacing.sp24),
        Text(title, style: context.typo.headlineSmall),
        Gap(Dimens.spacing.sp24),
        Text(
          subtitle,
          style: context.typo.bodyMedium.copyWith(
            color: context.color.grey800,
            fontWeight: AppFontWeights.regular,
          ),
        ),
        Gap(Dimens.spacing.sp24),
        Text(
          body,
          style: context.typo.bodyMedium.copyWith(
            color: context.color.grey800,
            fontWeight: AppFontWeights.regular,
          ),
        ),
        Gap(Dimens.spacing.sp24),
        PrimaryButton(
          onPressed: () {
            viewModel.releaseFunds();
            context.pop();
          },
          child: Text(actionText),
        ),
        Gap(Dimens.spacing.sp12),
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(l10n.cancel),
        ),
        Gap(Dimens.spacing.sp24),
      ],
    );
  }
}
