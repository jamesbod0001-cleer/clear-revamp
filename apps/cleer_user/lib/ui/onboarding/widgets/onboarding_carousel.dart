import 'dart:async';

import 'package:cleer/config/assets.gen.dart';
import 'package:cleer_ui/generated/assets.gen.dart' as ui_assets;
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';

class OnboardingCarousel extends HookWidget {
  const OnboardingCarousel({
    super.key,
    this.showBackground = true,
    this.footer,
  });

  final bool showBackground;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final PageController pageController = usePageController();
    final currentPage = useState<int>(0);

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (pageController.hasClients) {
          if (currentPage.value < 2) {
            pageController.animateToPage(
              currentPage.value + 1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else {
            timer.cancel();
          }
        }
      });
      return timer.cancel;
    }, []);

    Widget content = SafeArea(
      child: Column(
        children: [
          Gap(Dimens.spacing.sp40),
        Padding(
          padding: Dimens.of(context).edgeInsetsScreenHorizontal,
          child: LinearProgressIndicator(
            minHeight: Dimens.size.s8,
            borderRadius: BorderRadius.circular(Dimens.radius.r48),
            backgroundColor: const Color(0xff4390FD).withValues(alpha: .4),
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
              List<Widget> images = [
                Assets.images.safeClose.image(
                  fit: BoxFit.cover,
                  width: null,
                ),
                Assets.images.safeOpen.image(
                  fit: BoxFit.cover,
                  width: null,
                ),
                ui_assets.Assets.images.handshake.image(
                  fit: BoxFit.cover,
                  width: 285,
                ),
              ];
              return Column(
                children: [
                  Padding(
                    padding: Dimens.of(context).edgeInsetsScreenHorizontal,
                    child: Column(
                      children: [
                        Text(
                          titles[index],
                          textAlign: TextAlign.center,
                          style: context.typo.headlineMedium.copyWith(
                            color: context.color.background,
                          ),
                        ),
                        Gap(Dimens.spacing.sp12),
                        Text(
                          descriptions[index],
                          textAlign: TextAlign.center,
                          style: context.typo.bodyMedium.copyWith(
                            color: context.color.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(flex: index == 2 ? 2 : 1),
                  images[index],
                  const Spacer(flex: 3),
                ],
              );
            },
          ),
        ),
        if (footer != null) ...[
          Gap(Dimens.spacing.sp65),
          footer!,
          Gap(Dimens.spacing.sp20),
        ],
      ],
    ),
  );

    if (showBackground) {
      return DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.onboardingBackground.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: content,
      );
    }

    return content;
  }
}
