import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/agreements/widgets/agreement_card.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AgreementsScreen extends ConsumerWidget {
  const AgreementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(userProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
              SliverFillRemaining(
                child: Padding(
                  padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      Gap(Dimens.spacing.sp4),
                      _TabBar(l10n: l10n),
                      Gap(Dimens.spacing.sp28),
                      Expanded(
                        child: TabBarView(
                          children: [
                            Builder(
                              builder: (BuildContext context) {

                                final userOngoingAgreementsState = ref.watch(userOngoingAgreementsProvider);

                                bool isLoading =
                                    userOngoingAgreementsState.isLoading;

                                if (isLoading) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final ongoingAgreements = userOngoingAgreementsState.value;

                                if (ongoingAgreements == null ||
                                    ongoingAgreements.isEmpty) {
                                  return SizedBox.shrink();
                                }

                                return ListView.separated(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final agreement =
                                            ongoingAgreements[index];
                                        return AgreementCard(
                                          agreement: agreement,
                                        );
                                      },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                        return SizedBox(
                                          height: Dimens.spacing.sp16,
                                        );
                                      },
                                  itemCount: ongoingAgreements.length,
                                );
                              },
                            ),
                            SingleChildScrollView(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBar extends ConsumerWidget {
  const _TabBar({required this.l10n});

  final AppLocalizations l10n;

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
