import 'package:cleer/ui/agreements/agreements/state/agreements_state.dart';
import 'package:cleer/ui/agreements/agreements/view_model/agreements_view_model.dart';
import 'package:cleer/ui/agreements/agreements/widgets/agreement_card.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OngoingAgreementsView extends ConsumerWidget {
  const OngoingAgreementsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const _OngoingFiltersRow(),
        Expanded(
          child: Builder(
            builder: (BuildContext context) {
              final filteredState = ref.watch(agreementsScreenListProvider);

              if (filteredState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final ongoingAgreements = filteredState.value;

              if (ongoingAgreements == null || ongoingAgreements.isEmpty) {
                /// TODO: Add empty state
                return SizedBox.shrink();
              }

              return ListView.separated(
                padding: .only(top: Dimens.padding.p24),
                itemBuilder: (BuildContext context, int index) {
                  final agreement = ongoingAgreements[index];
                  return AgreementCard(agreement: agreement);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: Dimens.spacing.sp16);
                },
                itemCount: ongoingAgreements.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OngoingFiltersRow extends ConsumerWidget {
  const _OngoingFiltersRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentFilter = ref.watch(
      agreementsViewModelProvider.select((state) => state.ongoingFilter),
    );
    return Container(
      color: context.color.background,
      child: Align(
        alignment: .centerLeft,
        child: SingleChildScrollView(
          scrollDirection: .horizontal,
          padding: .only(top: Dimens.padding.p24, bottom: Dimens.padding.p4),
          child: Row(
            mainAxisSize: .min,
            spacing: Dimens.spacing.sp8,
            children: OngoingAgreementFilter.values.map((filter) {
              final isSelected = filter == currentFilter;
              String getFilterText() {
                return switch (filter) {
                  OngoingAgreementFilter.all => l10n.all,
                  OngoingAgreementFilter.needsAction => l10n.needsYourAction,
                  OngoingAgreementFilter.waitingToRelease =>
                    l10n.readyToRelease,
                };
              }

              return ChoiceChip(
                label: Text(getFilterText()),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(agreementsViewModelProvider.notifier)
                      .setFilter(filter);
                },
                showCheckmark: false,
                padding: .symmetric(vertical: Dimens.padding.p4),
                materialTapTargetSize: .shrinkWrap,
                visualDensity: VisualDensity.compact,
                color: WidgetStateColor.resolveWith((state) {
                  if (state.contains(WidgetState.selected)) {
                    return context.color.blue200;
                  }
                  return context.color.background;
                }),
                shape: RoundedRectangleBorder(
                  borderRadius: .circular(Dimens.radius.r32),
                  side: BorderSide(
                    color: isSelected
                        ? context.color.blue700
                        : context.color.outline,
                  ),
                ),
                labelStyle: context.typo.bodyMedium.copyWith(
                  fontWeight: AppFontWeights.regular,
                  color: context.color.grey800,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
