import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/add_email_address/view_model/add_email_address_view_model.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:cleer_core/utils/validators/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddEmailAddressScreen extends HookConsumerWidget {
  const AddEmailAddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(addEmailAddressViewModelProvider, (prev, next) {
      next.whenData((updateResult) {
        if (updateResult != null) {
          if (context.mounted) VerifyEmailRoute().pushReplacement(context);
        }
      });
    });

    final emailController = useTextEditingController();
    useListenable(emailController);

    final state = ref.watch(addEmailAddressViewModelProvider);
    final viewModel = ref.read(addEmailAddressViewModelProvider.notifier);

    if (state.isLoading) {
      return Material(child: Center(child: CircularProgressIndicator()));
    }

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
            Text(l10n.addEmailAddress),
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
                  l10n.usedToSecureYourAccountAndRecoverAccess,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp40),
                CustomTextFormField(
                  labelText: l10n.emailAddress,
                  controller: emailController,
                  textInputType: .emailAddress,
                  validator: context.emailValidator(),
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
                    onPressed: emailController.text.isValidEmailRequired
                        ? () => viewModel.addEmailAddress(emailController.text)
                        : null,
                    child: Text(l10n.continueText),
                  ),
                  Gap(Dimens.spacing.sp20),
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
