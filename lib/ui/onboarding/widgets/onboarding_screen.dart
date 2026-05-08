import 'dart:async';

import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:flutter/gestures.dart';
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

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (pageController.hasClients) {
          // Check if we are not on the last page (index 2)
          if (currentPage.value < 2) {
            pageController.animateToPage(
              currentPage.value + 1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else {
            // We have reached the last page, so stop the timer
            timer.cancel();
          }
        }
      });

      // Cleanup the timer when the widget is disposed
      return timer.cancel;
    }, []);

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.onboardingBackground.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: context.color.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Gap(Dimens.spacing.sp40),
              Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                child: LinearProgressIndicator(
                  minHeight: Dimens.size.s8,
                  borderRadius: BorderRadius.circular(Dimens.radius.r48),
                  backgroundColor: Color(0xff4390FD).withValues(alpha: .4),
                  color: context.color.primaryBlue,
                  value: (currentPage.value + 1) / 3,
                ),
              ),
              Gap(Dimens.spacing.sp70),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: 3,
                  onPageChanged: (int index) {
                    currentPage.value = index;
                  },
                  itemBuilder: (BuildContext context, int index) {
                    List<String> titles = [
                      l10n.dontJustSendSecure,
                      l10n.inspectThenRelease,
                      l10n.tradeWithConfidence,
                    ];
                    List<String> descriptions = [
                      l10n.lockFundsSecurelyTheReceiverSeeThePaymentButCannotAccessItUntilYouApprove,
                      l10n.confirmDeliveryOrServiceTapReleaseToPayInstantlyOrRequestARefundIfSomethingIsWrong,
                      l10n.weHoldTheMoneySafelyAndReleaseItOnlyWhenYouApproveProtectingBothBuyersAndSellersFromScamsDelaysAndBadDeliveries,
                    ];
                    List<AssetGenImage> images = [
                      Assets.images.safeClose,
                      Assets.images.safeOpen,
                      Assets.images.handshake,
                    ];
                    return Column(
                      children: [
                        Padding(
                          padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                          child: Column(
                            children: [
                              Text(
                                titles[index],
                                style: context.typo.headlineMedium.copyWith(
                                  color: context.color.background,
                                ),
                              ),
                              Gap(Dimens.spacing.sp12),
                              Text(
                                descriptions[index],
                                textAlign: .center,
                                style: context.typo.bodyMedium.copyWith(
                                  color: context.color.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(flex: index == 2 ? 2 : 1),
                        images[index].image(
                          fit: BoxFit.cover,
                          width: index == 2 ? 285 : null,
                        ),
                        const Spacer(flex: 3),
                      ],
                    );
                  },
                ),
              ),
              Gap(Dimens.spacing.sp65),
              Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                child: Column(
                  children: [
                    PrimaryButton(
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
                              color: context.color.outline,
                            ),
                          ),
                          TextSpan(text: ' '),
                          TextSpan(
                            text: l10n.logIn,
                            style: context.typo.bodyLink.copyWith(
                              color: context.color.primaryBlue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => LoginRoute().push(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap(Dimens.spacing.sp20),
            ],
          ),
        ),
      ),
    );
  }
}
