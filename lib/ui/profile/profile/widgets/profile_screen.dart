import 'package:cleer/domain/providers/user_provider.dart';
import 'package:cleer/domain/use_cases/auth/auth_use_case.dart';
import 'package:cleer/ui/auth/auth_state.dart';
import 'package:cleer/ui/auth/log_out/view_model/log_out_view_model.dart';
import 'package:cleer/ui/auth/log_out/widgets/log_out_button.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider).value;

    final bool viewModelsLoading = ref.watch(logOutViewModelProvider).isLoading;

    final bool isRedirectingOrSyncing = ref
        .watch(authUseCaseProvider)
        .maybeWhen(
          data: (state) => state is SignedOut,
          loading: () => true,
          orElse: () => false,
        );

    bool isLoading =
        viewModelsLoading ||
        isRedirectingOrSyncing ||
        ref.watch(userProvider).isLoading;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        title: Container(
          height: Dimens.size.s54,
          alignment: .bottomLeft,
          child: Text(l10n.profile),
        ),
        toolbarHeight: Dimens.size.s70,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                  top: Dimens.padding.p10,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                '${user?.firstName} ${user?.lastName}',
                                style: context.typo.headlineSmall.copyWith(
                                  fontWeight: AppFontWeights.medium,
                                  fontSize: 28,
                                  color: context.color.grey600,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${l10n.trustScore}:',
                                    style: context.typo.bodySmall.copyWith(
                                      color: context.color.grey600,
                                    ),
                                  ),
                                  Gap(Dimens.spacing.sp4),
                                  Material(
                                    color: context.color.successLight,
                                    borderRadius: BorderRadius.circular(
                                      Dimens.radius.r20,
                                    ),
                                    child: Padding(
                                      padding: .symmetric(
                                        horizontal: Dimens.padding.p8,
                                        vertical: Dimens.padding.p2,
                                      ),
                                      child: Row(
                                        mainAxisSize: .min,
                                        children: [
                                          PhosphorIcon(
                                            PhosphorIcons.shootingStar(
                                              .duotone,
                                            ),
                                            color: context.color.success,
                                            size: Dimens.size.s16,
                                          ),
                                          Gap(Dimens.spacing.sp4),
                                          Text(
                                            '99',
                                            style: context.typo.bodySmall
                                                .copyWith(
                                                  fontWeight:
                                                      AppFontWeights.regular,
                                                  letterSpacing: 0,
                                                  height: 1.5,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Gap(Dimens.spacing.sp8),
                              Text(
                                '${l10n.memberSince} ${DateFormat('d MMM, y').format(user!.createdAt!)}',
                                style: context.typo.bodySmall.copyWith(
                                  color: context.color.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(Dimens.spacing.sp20),
                        Column(
                          children: [CircleAvatar(radius: Dimens.radius.r48)],
                        ),
                      ],
                    ),
                    LogOutButton(),
                    Gap(Dimens.spacing.sp28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
