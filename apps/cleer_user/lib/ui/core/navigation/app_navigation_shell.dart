import 'dart:ui';

import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/routing/routes.dart';
import 'package:cleer/ui/auth/log_out/widgets/log_out_button.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppNavigationShell extends HookWidget {
  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  const AppNavigationShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final uri = GoRouterState.of(context).uri;
    final currentPath = uri.path;

    // Check if we are on a root tab. Update this list if I have more root tabs.
    final isRootMobileTab =
        ['/home', '/agreements', '/profile', '/activity'].contains(currentPath);

    // --- SMART RESYNC LOGIC ---
    // This logic ensures that when the user resizes between Mobile and Desktop,
    // they land on the correct version of the feature for that device.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 1. From Desktop Activity Tab -> Mobile Activity Subroute
        if (isMobile && navigationShell.currentIndex == 3) {
          const ActivityTimelineRoute().go(context);
        }

        // 2. From Mobile Activity Subroute -> Desktop Activity Tab
        if (!isMobile &&
            navigationShell.currentIndex == 0 &&
            currentPath.contains('activity_timeline')) {
          navigationShell.goBranch(3);
        }

        // 3. From Mobile Profile Tab -> Desktop Home (Since Profile is no longer a tab)
        if (!isMobile && navigationShell.currentIndex == 2) {
          HomeRoute().go(context);
        }
      });
      return null;
    }, [isMobile]);

    // Map UI indices (0, 1, 2) to actual GoRouter branch indices
    // Mobile: 0->Home, 1->Agreements, 2->Profile
    // Desktop/Tablet: 0->Home, 1->Agreements, 2->Activity (Branch index 3)
    final visibleBranchIndices = isMobile ? [0, 1, 2] : [0, 1, 3];

    // Find which UI index corresponds to the currently active GoRouter branch
    final uiSelectedIndex = visibleBranchIndices.indexOf(
      navigationShell.currentIndex,
    );

    void onTabTapped(int uiIndex) {
      final actualBranchIndex = visibleBranchIndices[uiIndex];
      navigationShell.goBranch(
        actualBranchIndex,
        initialLocation: actualBranchIndex == navigationShell.currentIndex,
      );
    }

    if (isMobile) {
      return Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: child,
            );
          },
          child:
              isRootMobileTab
                  ? ClipRect(
                    key: const ValueKey('bottomNav'),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      child: NavigationBar(
                        backgroundColor: context.color.navbarBg.withValues(
                          alpha: 0.92,
                        ),
                        selectedIndex:
                            uiSelectedIndex != -1 ? uiSelectedIndex : 0,
                        onDestinationSelected: onTabTapped,
                        destinations: destinations,
                      ),
                    ),
                  )
                  : const SizedBox.shrink(key: ValueKey('emptyNav')),
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
                image:
                    isDesktop
                        ? Assets
                            .images
                            .navigationRailDesktopBackground
                            .provider()
                        : Assets
                            .images
                            .navigationRailTabletBackground
                            .provider(),
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
                      final isSelected = index == uiSelectedIndex;
                      final destination = destinations[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(Dimens.radius.r12),
                        onTap: () => onTabTapped(index),
                        child: Container(
                          padding: EdgeInsets.all(Dimens.padding.p12),
                          decoration: BoxDecoration(
                            color:
                                isSelected
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
                              Gap(
                                isDesktop
                                    ? Dimens.spacing.sp12
                                    : Dimens.spacing.sp8,
                              ),
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
                    // HELP BUTTON
                    _SidebarActionTile(
                      icon: PhosphorIcons.question(.duotone),
                      label: AppLocalizations.of(context)!.helpAndSupport,
                      onTap: () => HelpSupportRoute().push(context),
                      isDesktop: isDesktop,
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

/// Helper widget for the bottom sidebar buttons (Help, etc.)
class _SidebarActionTile extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDesktop;

  const _SidebarActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.radius.r12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(Dimens.padding.p12),
          child: Row(
            children: [
              PhosphorIcon(
                icon,
                color: context.color.background,
                size: Dimens.size.s20,
              ),
              Gap(isDesktop ? Dimens.spacing.sp12 : Dimens.spacing.sp8),
              Expanded(
                child: Text(
                  label,
                  style:
                      (isDesktop
                              ? context.typo.bodyMedium
                              : context.typo.bodySmall)
                          .copyWith(color: context.color.blue200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
