import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/custom_switch.dart';
import 'package:cleer_ui/widgets/menu_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';

class ManageNotificationsScreen extends HookWidget {
  const ManageNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.manageNotifications),
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
                  l10n.chooseHowAndWhenYouReceiveUpdates,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp40),
                MenuSectionHeader(title: l10n.deliveryChannels),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      l10n.pushNotifications,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    CustomSwitch(value: true, onChanged: (val) {}),
                  ],
                ),
                Gap(Dimens.spacing.sp24),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      l10n.emailNotifications,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    CustomSwitch(value: true, onChanged: (val) {}),
                  ],
                ),
                Gap(Dimens.spacing.sp24),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      l10n.sms,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    CustomSwitch(value: true, onChanged: (val) {}),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
