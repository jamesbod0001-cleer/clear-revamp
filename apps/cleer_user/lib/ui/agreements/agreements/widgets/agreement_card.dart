import 'package:cleer_core/models/agreement/agreement.dart';
import 'package:cleer_core/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/agreements/extensions/agreement_ui_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/generated/assets.gen.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AgreementCard extends ConsumerWidget {
  const AgreementCard({
    super.key,
    required this.agreement,
    this.isLast = false,
    this.useCardStyle = false,
  });

  final Agreement agreement;
  final bool isLast;
  final bool useCardStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProfileProvider).value;

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton.replace(
          replacement: Bone.circle(size: Dimens.size.s48),
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.color.infoLight,
            ),
            child: SizedBox.square(
              dimension: Dimens.size.s48,
              child: Center(
                child: Assets.images.handshake.image(
                  height: Dimens.size.s18,
                  width: Dimens.size.s28,
                ),
              ),
            ),
          ),
        ),
        Gap(Dimens.spacing.sp10),
        Expanded(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agreement.getDisplayTitle(context, currentUser: user),
                        style: context.typo.bodyMedium.copyWith(
                          color: context.color.grey800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(Dimens.spacing.sp4),
                      Text(
                        l10n.dueDate(
                          agreement.dueDate != null
                              ? DateFormat('d MMM').format(agreement.dueDate!)
                              : '',
                        ),
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.grey600,
                        ),
                      ),
                      Gap(Dimens.spacing.sp4),
                      agreement.getActionWidget(context, currentUser: user),
                    ],
                  ),
                ),
                Gap(Dimens.spacing.sp24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.nairaSign}${NumberFormat('#,###.##').format(agreement.amount)}',
                      style: context.typo.titleMedium,
                    ),
                    Skeleton.replace(
                      replacement: Bone(
                        width: Dimens.size.s56,
                        height: Dimens.size.s22,
                        borderRadius: BorderRadius.circular(Dimens.radius.r20),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: agreement.getStatusPillColor(context),
                          borderRadius: BorderRadius.circular(
                            Dimens.radius.r20,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.padding.p6,
                          vertical: Dimens.padding.p3,
                        ),
                        child: Text(
                          agreement.getStatusText(context),
                          style: context.typo.bodySmall.copyWith(
                            color: agreement.getStatusTextColor(context),
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
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: useCardStyle ? context.color.white : context.color.transparent,
          borderRadius: BorderRadius.circular(Dimens.radius.r8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if ((agreement.status == AgreementStatus.awaitingRecipient ||
                      agreement.status == AgreementStatus.awaitingFunding) &&
                  agreement.initiator?.id != user?.id) {
                AcceptAgreementRoute(
                  shortCode: agreement.shortCode,
                ).push(context);
              } else {
                AgreementDetailsRoute(
                  id: agreement.id!,
                  $extra: agreement,
                ).go(context);
              }
            },
            child: Padding(
              padding: useCardStyle
                  ? EdgeInsets.all(Dimens.padding.p12)
                  : EdgeInsets.zero,
              child: content,
            ),
          ),
        ),
        if (!isLast) ...[
          Gap(Dimens.spacing.sp16),
          Row(
            children: [
              Gap(Dimens.spacing.sp58),
              Expanded(
                child: Divider(
                  color: context.color.outline,
                  thickness: Dimens.size.s1,
                  height: Dimens.size.s1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
