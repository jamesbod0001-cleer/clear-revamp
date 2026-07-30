import 'package:cleer/domain/providers/storage/file_url_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/extensions/string_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/images/app_image.dart';
import 'package:cleer_ui/widgets/images/blur_hash_widget.dart';
import 'package:cleer/ui/profile/account_security/view_model/account_security_view_model.dart';
import 'package:cleer_ui/widgets/menu_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountSecurityScreen extends HookConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProfileProvider).value;

    ref.watch(accountSecurityViewModelProvider);
    final viewModel = ref.read(accountSecurityViewModelProvider.notifier);

    final uploadProfilePictureCommand = viewModel.uploadProfilePicture;
    useEffect(() {
      void listener() {
        if (uploadProfilePictureCommand.errors.value != null) {
          debugPrint(
            "Command Error: ${uploadProfilePictureCommand.errors.value?.error}",
          );
        }
      }

      uploadProfilePictureCommand.errors.addListener(listener);
      return () => uploadProfilePictureCommand.errors.removeListener(listener);
    }, [uploadProfilePictureCommand]);
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
                ProfilePicture(),
                Gap(Dimens.spacing.sp40),
                MenuSectionHeader(title: l10n.personalInformation),
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
                MenuSectionHeader(title: l10n.contactDetails),
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
                      child: GestureDetector(
                        onTap:
                            (user?.email != null &&
                                user?.isEmailVerified == true)
                            ? null
                            : () {
                                if (user?.email == null) {
                                  AddEmailRoute().push(context);
                                } else {
                                  VerifyEmailRoute().push(context);
                                }
                              },
                        child: Visibility(
                          visible: user?.email != null,
                          replacement: Row(
                            mainAxisAlignment: .end,
                            children: [
                              Text(
                                l10n.addEmail,
                                style: context.typo.bodyLink.copyWith(
                                  color: context.color.blue700,
                                  decorationColor: context.color.blue700,
                                ),
                              ),
                              Gap(Dimens.spacing.sp8),
                              Material(
                                color: context.color.error,
                                borderRadius: .circular(Dimens.radius.r20),
                                child: Padding(
                                  padding: .symmetric(
                                    horizontal: Dimens.padding.p6,
                                    vertical: Dimens.padding.p2,
                                  ),
                                  child: Text(
                                    l10n.notAdded,
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
                          child: Row(
                            children: [
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
                              if (user?.isEmailVerified != true) ...[
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                MenuSectionHeader(title: l10n.passwordAndSecurity),
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
                Gap(Dimens.spacing.sp20),
              ]),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class ProfilePicture extends ConsumerWidget {
  const ProfilePicture({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Use watch for the command so the UI rebuilds when isRunning changes
    final uploadCommand = ref
        .watch(accountSecurityViewModelProvider.notifier)
        .uploadProfilePicture;
    final user = ref.watch(userProfileProvider).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => uploadCommand.runAsync(),
          child: Container(
            width: Dimens.radius.r80, // radius * 2
            height: Dimens.radius.r80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.color.grayComponent,
            ),
            child: ClipOval(
              child: ValueListenableBuilder<bool>(
                valueListenable: uploadCommand.isRunning,
                builder: (context, isUploading, _) {
                  // 1. Show Progress Loader if uploading
                  if (isUploading) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.color.blue700,
                      ),
                    );
                  }

                  // 2. No User/Picture? Show Placeholder
                  if (user?.profilePicture == null) {
                    return Center(
                      child: PhosphorIcon(
                        PhosphorIcons.user(),
                        size: Dimens.size.s32,
                        color: context.color.grey400,
                      ),
                    );
                  }

                  // 3. Show the Image with Cache Busting
                  final profileUrlAsync = ref.watch(
                    fileUrlProvider(user!.profilePicture!.key),
                  );

                  return profileUrlAsync.when(
                    data: (url) => AppImage(
                      imageUrl: url,
                      blurHash: user.profilePicture!.blurHash ?? '',
                      fit: BoxFit.cover,
                    ),
                    loading: () => BlurHashWidget(
                      hash: user.profilePicture!.blurHash ?? '',
                    ),
                    error: (_, _) => Center(
                      child: PhosphorIcon(PhosphorIcons.imageBroken()),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Gap(Dimens.spacing.sp8),
        Text(
          l10n.tapToChangeImage,
          style: context.typo.bodySmall.copyWith(color: context.color.grey600),
        ),
      ],
    );
  }
}
