import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/ui/agreements/agreements/widgets/agreement_card.dart';
import 'package:cleer/ui/agreements/agreements/widgets/agreement_card_skeleton_list.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/extensions/error_ui_extensions.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CompletedAgreementsView extends HookConsumerWidget {
  const CompletedAgreementsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final completedState = ref.watch(userCompletedAgreementsProvider);

    final scrollController = useScrollController();

    useEffect(() {
      void scrollListener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(userCompletedAgreementsProvider.notifier).loadMore();
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

    return completedState.when(
      skipLoadingOnReload: true,
      data: (paginatedList) {
        if (paginatedList.items.isEmpty) {
          return AppEmptyState(
            icon: Assets.icons.handshakeOff.svg(
              width: Dimens.size.s80,
              height: Dimens.size.s80,
              colorFilter: ColorFilter.mode(
                context.color.blue1000,
                BlendMode.srcIn,
              ),
            ),
            title: l10n.noCompletedAgreementsYet,
            iconBottomSpacing: Dimens.spacing.sp32,
            subtitle: Text(
              l10n.whenYourAgreementsAreCompletedTheyWillAppearHere,
              style: context.typo.bodyMedium.copyWith(
                color: context.color.grey800,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ResponsiveLayout(
          mobile: ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: Dimens.padding.p24,
              bottom: Dimens.padding.p32,
            ),
            itemBuilder: (BuildContext context, int index) {
              if (index < paginatedList.items.length) {
                final agreement = paginatedList.items[index];
                return AgreementCard(
                  isLast:
                      index == (paginatedList.items.length - 1) &&
                      !paginatedList.hasNextPage,
                  agreement: agreement,
                );
              } else {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(Dimens.padding.p16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: Dimens.spacing.sp16);
            },
            itemCount:
                paginatedList.items.length +
                (paginatedList.hasNextPage ? 1 : 0),
          ),
          desktop: LayoutBuilder(
            builder: (context, constraints) {
              final spacing = Dimens.spacing.sp20;
              const maxExtent = 450.0;

              int crossAxisCount =
                  (constraints.maxWidth / (maxExtent + spacing)).floor();
              if (crossAxisCount < 2) crossAxisCount = 2;

              final itemWidth =
                  (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                  crossAxisCount;

              return SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  top: Dimens.padding.p24,
                  bottom: Dimens.padding.p32,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: spacing,
                        runSpacing: spacing,
                        children: paginatedList.items.map((agreement) {
                          return SizedBox(
                            width: itemWidth,
                            child: AgreementCard(
                              agreement: agreement,
                              isLast: true,
                              useCardStyle: true,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (paginatedList.hasNextPage)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.padding.p24,
                        ),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.only(top: Dimens.padding.p24),
        child: AgreementCardSkeletonList(),
      ),
      error: (error, stack) => error.toErrorState(
        ref,
        onRetry: () => ref.invalidate(userCompletedAgreementsProvider),
      ),
    );
  }
}
