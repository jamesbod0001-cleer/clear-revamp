import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/agreements/view_model/agreements_view_model.dart';
import 'package:cleer/ui/agreements/agreements/widgets/ongoing_agreements_view.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AgreementsScreen extends HookConsumerWidget {
  const AgreementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(userProfileProvider);

    final initialTabIndex = ref
        .read(agreementsViewModelProvider)
        .selectedTabIndex;

    final tabController = useTabController(
      initialLength: 2,
      initialIndex: initialTabIndex,
    );

    useEffect(() {
      void handleTabChange() {
        final currentRiverpodIndex = ref
            .read(agreementsViewModelProvider)
            .selectedTabIndex;

        if (tabController.index != currentRiverpodIndex) {
          ref
              .read(agreementsViewModelProvider.notifier)
              .setTabIndex(tabController.index);
        }
      }

      tabController.addListener(handleTabChange);
      return () => tabController.removeListener(handleTabChange);
    }, [tabController]);

    ref.listen(
      agreementsViewModelProvider.select((state) => state.selectedTabIndex),
      (previous, next) {
        if (tabController.index != next) {
          tabController.animateTo(next);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        title: Container(
          height: Dimens.size.s54,
          alignment: .bottomLeft,
          child: Text(l10n.agreements),
        ),
        toolbarHeight: Dimens.size.s70,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            PinnedHeaderSliver(
              child: Container(
                color: context.color.background,
                padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                  top: Dimens.padding.p4,
                  bottom: Dimens.padding.p4,
                ),
                child: _TabBar(controller: tabController, l10n: l10n),
              ),
            ),
            SliverFillRemaining(
              child: Padding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: TabBarView(
                  controller: tabController,
                  children: [OngoingAgreementsView(), SingleChildScrollView()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends ConsumerWidget {
  const _TabBar({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final TabController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userOngoingAgreementsState = ref.watch(userOngoingAgreementsProvider);

    final ongoingAgreements = userOngoingAgreementsState.value;

    return Container(
      height: Dimens.size.s44,
      decoration: BoxDecoration(
        color: context.color.outline,
        borderRadius: BorderRadius.circular(Dimens.radius.r80),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.radius.r48),
          color: context.color.background,
        ),
        splashBorderRadius: BorderRadius.circular(Dimens.radius.r48),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: Dimens.size.s0,
        indicatorPadding: EdgeInsets.all(Dimens.padding.p4),
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        labelStyle: context.typo.bodyMedium,
        unselectedLabelStyle: context.typo.bodyMedium.copyWith(
          color: context.color.grey800,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: .min,
              children: [
                Text(l10n.ongoing),
                if (ongoingAgreements != null &&
                    ongoingAgreements.isNotEmpty) ...[
                  Gap(Dimens.spacing.sp6),
                  Container(
                    padding: .symmetric(horizontal: Dimens.padding.p5),
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: context.color.blue100,
                    ),
                    child: Text(
                      ongoingAgreements.length.toString(),
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(text: l10n.completed),
        ],
      ),
    );
  }
}
