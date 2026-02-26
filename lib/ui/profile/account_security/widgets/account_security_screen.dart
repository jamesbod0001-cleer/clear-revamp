import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/extensions/string_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/app_back_button.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_section_header.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountSecurityScreen extends ConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider).value;

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
            Text(l10n.accountAndSecurity),
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
                  l10n.manageYourPersonalDetailsAndLoginSecurity,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp40),
                Column(
                  children: [
                    CircleAvatar(radius: Dimens.radius.r40),
                    Gap(Dimens.spacing.sp4),
                    Text(
                      l10n.tapToChangeImage,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp40),
                ProfileSectionHeader(title: l10n.personalInformation),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      l10n.firstName,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp24),
                    Expanded(
                      child: Text(
                        user?.firstName ?? '',
                        style: context.typo.titleSmall.copyWith(
                          color: context.color.grey800,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: .end,
                      ),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp24),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      l10n.lastName,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp24),
                    Expanded(
                      child: Text(
                        user?.lastName ?? '',
                        style: context.typo.titleSmall.copyWith(
                          color: context.color.grey800,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: .end,
                      ),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp40),
                ProfileSectionHeader(title: l10n.contactDetails),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      l10n.phoneNumber,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                    Gap(Dimens.spacing.sp24),
                    Expanded(
                      child: Text(
                        user?.phoneNumber.maskPhoneNumber ?? '',
                        style: context.typo.titleSmall.copyWith(
                          color: context.color.grey800,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: .end,
                      ),
                    ),
                  ],
                ),

                if (user?.email != null) ...[
                  Gap(Dimens.spacing.sp24),
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        l10n.emailAddress,
                        style: context.typo.bodyMedium.copyWith(
                          fontWeight: AppFontWeights.regular,
                          color: context.color.grey600,
                        ),
                      ),
                      Gap(Dimens.spacing.sp24),
                      Expanded(
                        child: Text(
                          user?.email?.maskEmail ?? '',
                          style: context.typo.titleSmall.copyWith(
                            color: context.color.grey800,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: .end,
                        ),
                      ),
                      Gap(Dimens.spacing.sp8),
                      Material(
                        color: context.color.warning,
                        borderRadius: .circular(Dimens.radius.r20),
                        child: Padding(
                          padding: .symmetric(
                            horizontal: Dimens.padding.p6,
                            vertical: Dimens.padding.p2,
                          ),
                          child: Text(
                            l10n.unverified,
                            style: context.typo.bodySmall.copyWith(
                              color: context.color.background,
                              fontStyle: .italic,
                            ),
                          ),
                        ),
                      ),
                      PhosphorIcon(
                        PhosphorIcons.caretRight(),
                        size: Dimens.size.s20,
                        color: context.color.blue700,
                      ),
                    ],
                  ),
                ],
                Gap(Dimens.spacing.sp40),
                Container(
                  padding: .all(Dimens.padding.p8),
                  decoration: BoxDecoration(
                    color: context.color.grayComponent,
                    borderRadius: .circular(Dimens.radius.r8),
                  ),
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.info(),
                        color: context.color.grey800,
                      ),
                      Gap(Dimens.spacing.sp12),
                      Expanded(
                        child: Text(
                          l10n.contactSupportToEditYourDetails,
                          style: context.typo.bodyMedium.copyWith(
                            color: context.color.grey800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(Dimens.spacing.sp40),
                ProfileSectionHeader(title: l10n.passwordAndSecurity),
                Material(
                  borderRadius: BorderRadius.circular(Dimens.radius.r4),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => ChangePasswordRoute().push(context),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.password(.duotone),
                          color: context.color.blue700,
                        ),
                        Gap(Dimens.spacing.sp12),
                        Expanded(
                          child: Text(
                            l10n.changePassword,
                            style: context.typo.bodyMedium.copyWith(
                              color: context.color.grey800,
                            ),
                          ),
                        ),
                        Gap(Dimens.spacing.sp8),
                        PhosphorIcon(
                          PhosphorIcons.caretRight(),
                          size: Dimens.size.s20,
                          color: context.color.blue700,
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
