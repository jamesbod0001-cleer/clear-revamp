import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/tiles/menu_action_tile.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.dataUsageAndPrivacy),
          ],
        ),
        toolbarHeight: 102,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
              top: Dimens.padding.p4,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  l10n.understandHowYourDataIsCollectedUsedAndProtected,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp40),
                MenuActionTile(title: l10n.dataWeCollect, onTap: () {}),
                Gap(Dimens.spacing.sp8),
                MenuActionTile(title: l10n.howWeUseYourData, onTap: () {}),

                Gap(Dimens.spacing.sp8),
                MenuActionTile(title: l10n.dataProtection, onTap: () {}),
              ]),
            ),
          ),
        ],
      ),
    ),
  );
}
}
