import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

class FundsSecuredStep extends ConsumerWidget {
  const FundsSecuredStep({super.key, required this.type});
  final AgreementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(createAgreementViewModelProvider(type));
    // final viewModel = ref.read(createAgreementViewModelProvider(type).notifier);

    return PopScope(
      canPop: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: Dimens.mobile.edgeInsetsScreenHorizontal,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Gap(Dimens.spacing.sp35),
                Align(
                  alignment: .centerRight,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: .zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {},
                    icon: PhosphorIcon(
                      PhosphorIcons.x(.bold),
                      color: context.color.grey800,
                    ),
                  ),
                ),
                Gap(Dimens.spacing.sp84),
                Container(
                  width: Dimens.size.s100,
                  height: Dimens.size.s100,
                  alignment: .center,
                  decoration: BoxDecoration(
                    color: context.color.white,
                    shape: BoxShape.circle,
                    border: .all(
                      color: context.color.blue800.withValues(alpha: .1),
                      width: Dimens.size.s2,
                    ),
                  ),
                  child: Assets.images.shield.image(height: Dimens.size.s60),
                ),
                Gap(Dimens.spacing.sp48),
                Text(
                  l10n.fundsSecured,
                  style: context.typo.headlineSmall,
                  textAlign: .center,
                ),
                Gap(Dimens.spacing.sp12),
                Text(
                  l10n.shareThisLinkWithTheRecipientToAcceptTheAgreementFundsWillBeReleasedOnlyWhenYouConfirm,
                  style: context.typo.bodyMedium.copyWith(
                    color: context.color.grey600,
                  ),
                  textAlign: .center,
                ),
                Gap(Dimens.spacing.sp80),
                Text(
                  l10n.copy,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp4),
                Container(
                  padding: .fromLTRB(
                    Dimens.padding.p12,
                    Dimens.padding.p8,
                    Dimens.padding.p8,
                    Dimens.padding.p7,
                  ),
                  decoration: BoxDecoration(
                    color: context.color.grayComponent,
                    borderRadius: BorderRadius.circular(Dimens.radius.r12),
                    border: .all(color: context.color.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.value!.agreement!.shareLink,
                          style: context.typo.bodyLarge.copyWith(
                            height: 1,
                            letterSpacing: 0.16,
                          ),
                          overflow: .ellipsis,
                        ),
                      ),
                      Gap(Dimens.spacing.sp2),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Color(
                            0xFF99D2AE,
                          ).withValues(alpha: .20),
                          padding: .symmetric(
                            horizontal: Dimens.padding.p10,
                            vertical: Dimens.padding.p6,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: .zero,
                        ),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: state.value!.agreement!.shareLink,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: .min,
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.copySimple(.fill),
                              color: Color(0xFF013717),
                              size: Dimens.size.s16,
                            ),
                            Gap(Dimens.spacing.sp4),
                            Text(
                              l10n.copy,
                              style: context.typo.bodyMedium.copyWith(
                                color: context.color.green900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                  Gap(Dimens.spacing.sp30),
                  PrimaryButton(
                    onPressed: () async {
                      await SharePlus.instance.share(
                        ShareParams(
                          text:
                              "Hey! I've secured our ₦500,000 agreement on Cleer. Click the link to view the terms and accept: ${state.value!.agreement!.shareLink}",
                        ),
                      );
                    },
                    child: Text(l10n.sendLink),
                  ),
                  Gap(Dimens.spacing.sp20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
