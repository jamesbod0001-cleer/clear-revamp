import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';

class OnboardingScreen extends HookWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final PageController pageController = usePageController();
    final currentPage = useState<int>(0);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Dimens.mobile.edgeInsetsScreenHorizontal,
          child: Column(
            children: [
              Gap(Dimens.spacing.sp40),
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(Dimens.radius.r48),
                backgroundColor: context.color.outline,
                color: context.color.blue700,
                value: (currentPage.value + 1) / 3,
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    List<String> titles = [
                      l10n.dontJustSendSecure,
                      l10n.inspectThenRelease,
                      l10n.zeroRiskTransactions,
                    ];
                    return Column(
                      mainAxisAlignment: .end,
                      children: [
                        Text(titles[index], style: context.typo.headlineSmall),
                        Gap(Dimens.spacing.sp12),
                        Text(
                          l10n.lockFundsSecurelyTheReceiverSeesTheMoneyButCantTouchItUntilYouSaySo,
                          textAlign: .center,
                          style: context.typo.bodyMedium.copyWith(
                            color: context.color.grey600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Gap(Dimens.spacing.sp65),
              FilledButton(
                onPressed: () => CreateAccountRoute().push(context),
                child: Text(l10n.getStarted),
              ),
              Gap(Dimens.spacing.sp12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.alreadyHaveAnAccount,
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                    TextSpan(text: ' '),
                    TextSpan(
                      text: l10n.logIn,
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.blue700,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(Dimens.spacing.sp8),
            ],
          ),
        ),
      ),
    );
  }
}
