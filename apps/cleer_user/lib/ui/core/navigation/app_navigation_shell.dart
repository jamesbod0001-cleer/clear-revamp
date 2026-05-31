import 'dart:ui';

import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/log_out/widgets/log_out_button.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  const AppNavigationShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: NavigationBar(
              backgroundColor: context.color.navbarBg.withValues(alpha: 0.92),
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (int index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: destinations,
            ),
          ),
        ),
      );
    }

    final isDesktop = context.isDesktop;

    return Scaffold(
      body: Row(
        children: [
          // 1. The Sidebar Container
          Container(
            width: isDesktop ? Dimens.size.s248 : Dimens.size.s166,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: isDesktop
                    ? Assets.images.navigationRailDesktopBackground.provider()
                    : Assets.images.navigationRailTabletBackground.provider(),
                fit: BoxFit.cover,
              ),
            ),
            padding: .symmetric(
              horizontal: isDesktop ? Dimens.padding.p16 : Dimens.padding.p12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(Dimens.spacing.sp32),
                Row(
                  children: [
                    Assets.icons.cleerIcon.svg(width: Dimens.size.s24),
                    Gap(Dimens.spacing.sp8),
                    Text(
                      AppLocalizations.of(context)!.cleer,
                      style: context.typo.headlineSmall.copyWith(
                        color: context.color.background,
                      ),
                    ),
                  ],
                ),

                Gap(Dimens.spacing.sp44),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == navigationShell.currentIndex;
                      final destination = destinations[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(Dimens.radius.r12),
                        onTap: () {
                          navigationShell.goBranch(
                            index,
                            initialLocation:
                                index == navigationShell.currentIndex,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(Dimens.padding.p12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.color.white.withValues(alpha: .12)
                                : context.color.transparent,
                            borderRadius: BorderRadius.circular(
                              Dimens.radius.r12,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              IconTheme(
                                data: IconThemeData(
                                  size: Dimens.size.s20,
                                  color: context.color.outline,
                                ),
                                child: destination.icon,
                              ),
                              Gap(isDesktop ? Dimens.spacing.sp12 : Dimens.spacing.sp8),
                              Expanded(
                                child: Text(
                                  destination.label,
                                  style:
                                      (isDesktop
                                              ? context.typo.bodyMedium
                                              : context.typo.bodySmall)
                                          .copyWith(
                                            color: context.color.blue200,
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Column(
                  children: [
                    Material(
                      color: context.color.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(Dimens.radius.r12),
                        onTap: () => HelpSupportRoute().push(context),
                        child: Container(
                          padding: EdgeInsets.all(Dimens.padding.p12),
                          decoration: BoxDecoration(
                            color: context.color.transparent,
                            borderRadius: BorderRadius.circular(
                              Dimens.radius.r12,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              PhosphorIcon(
                                PhosphorIcons.question(.duotone),
                                color: context.color.background,
                                size: Dimens.size.s20,
                              ),
                              Gap(isDesktop ? Dimens.spacing.sp12 : Dimens.spacing.sp8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.helpAndSupport,
                                  style:
                                      (isDesktop
                                              ? context.typo.bodyMedium
                                              : context.typo.bodySmall)
                                          .copyWith(
                                            color: context.color.blue200,
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    LogOutButton(),
                  ],
                ),
                Gap(isDesktop ? Dimens.spacing.sp40 : Dimens.spacing.sp20),
              ],
            ),
          ),

          // Main Content Area
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
