import 'package:cleer/domain/models/recipient_resolution/recipient_resolution.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RecipientIdentityTile extends ConsumerWidget {
  const RecipientIdentityTile({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(createAgreementViewModelProvider(type));
    final formData = state.value?.formData;

    bool isResolving = state.value!.isResolvingRecipientDetails;
    RecipientResolution? resolution = formData!.recipientResolution;

    if (isResolving) {
      return Padding(
        padding: EdgeInsets.only(top: Dimens.padding.p12),
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      if (resolution != null) {
        bool isRegisteredUser = resolution.isRegisteredUser;
        final joinDate = isRegisteredUser
            ? resolution.recipient!.createdAt!
            : DateTime.now();
        final formattedDate = DateFormat('MMM yyyy').format(joinDate);

        /// TODO: Implement trust score checker here.
        // final int trustScore = resolution.recipient?.trustScore ?? 100;
        final int trustScore = 100;
        final bool lowTrustScore = trustScore < 40;

        return Column(
          children: [
            Gap(Dimens.spacing.sp12),
            Row(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: Dimens.padding.p2),
                  child: PhosphorIcon(
                    PhosphorIcons.checkCircle(.fill),
                    size: Dimens.size.s16,
                    color: context.color.green850,
                  ),
                ),
                Gap(Dimens.spacing.sp4),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      resolution.accountName,
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp4),
                    Row(
                      children: [
                        Text(
                          l10n.memberSince(formattedDate),
                          style: context.typo.bodyMedium.copyWith(
                            color: context.color.grey600,
                          ),
                        ),
                        Gap(Dimens.spacing.sp8),
                        Visibility(
                          visible: isRegisteredUser,
                          replacement: Material(
                            color: context.color.blue100.withAlpha(50),
                            borderRadius: BorderRadius.circular(
                              Dimens.radius.r20,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.padding.p8,
                                vertical: Dimens.padding.p2,
                              ),
                              child: Text(
                                l10n.newText,
                                style: context.typo.bodySmall.copyWith(
                                  color: context.color.secondary,
                                ),
                              ),
                            ),
                          ),
                          child: Material(
                            color: lowTrustScore
                                ? context.color.errorLight.withAlpha(50)
                                : context.color.successLight,
                            borderRadius: BorderRadius.circular(
                              Dimens.radius.r20,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.padding.p8,
                                vertical: Dimens.padding.p2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PhosphorIcon(
                                    PhosphorIcons.shootingStar(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    color: lowTrustScore
                                        ? context.color.error
                                        : context.color.success,
                                    size: Dimens.size.s16,
                                  ),
                                  Gap(Dimens.spacing.sp4),
                                  Text(
                                    '$trustScore',
                                    style: context.typo.bodySmall.copyWith(
                                      color: lowTrustScore
                                          ? context.color.error
                                          : context.color.success,
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
              ],
            ),
            Gap(Dimens.spacing.sp12),
            Container(
              padding: .all(Dimens.padding.p12),
              decoration: BoxDecoration(
                color: context.color.warningLight,
                borderRadius: BorderRadius.circular(Dimens.radius.r8),
                border: Border.all(color: Color(0xFFC39E71)),
              ),
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.warning(.duotone),
                    size: Dimens.size.s28,
                    color: context.color.warning,
                  ),
                  Gap(Dimens.spacing.sp12),
                  Expanded(
                    child: Visibility(
                      visible: !isRegisteredUser,
                      replacement: Visibility(
                        visible: lowTrustScore,
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              l10n.lowTrustScoreAlert,
                              style: context.typo.titleSmall.copyWith(
                                color: context.color.warning,
                              ),
                            ),
                            Gap(Dimens.spacing.sp6),
                            Text(
                              l10n.lowTrustScoreWarning(trustScore),
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: AppFontWeights.regular,
                                color: context.color.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            l10n.newUserAlert,
                            style: context.typo.titleSmall.copyWith(
                              color: context.color.warning,
                            ),
                          ),
                          Gap(Dimens.spacing.sp6),
                          Text(
                            l10n.noHistoryWarning(resolution.accountName),
                            style: context.typo.bodyMedium.copyWith(
                              fontWeight: AppFontWeights.regular,
                              color: context.color.warning,
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
        );
      }
    }

    return SizedBox.shrink();
  }
}
