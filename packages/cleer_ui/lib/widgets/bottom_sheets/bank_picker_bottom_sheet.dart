import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/l10n/generated/ui_localizations.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/widgets/custom_text_form_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BankPickerBottomSheet extends HookConsumerWidget {
  const BankPickerBottomSheet({super.key, required this.banksAsync});

  final AsyncValue<List<Bank>> banksAsync;

  static Future<Bank?> show(
    BuildContext context, {
    required AsyncValue<List<Bank>> banksAsync,
  }) => CustomBottomSheet.show<Bank?>(
    context: context,
    isDismissible: true,
    child: BankPickerBottomSheet(banksAsync: banksAsync),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = UiLocalizations.of(context)!;
    final searchController = useTextEditingController();
    final searchQuery = useValueListenable(searchController);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectBank, style: context.typo.headlineSmall),
        Gap(Dimens.spacing.sp24),
        CustomTextFormField(
          controller: searchController,
          labelText: l10n.search,
        ),
        Gap(Dimens.spacing.sp24),
        Expanded(
          child: banksAsync.when(
            data: (List<Bank> list) {
              final filteredList =
                  list
                      .where(
                        (bank) => bank.name.toLowerCase().contains(
                          searchQuery.text.toLowerCase(),
                        ),
                      )
                      .toList()
                    ..sort(
                      (a, b) =>
                          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                    );

              if (filteredList.isEmpty) {
                return Row(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.x(.bold),
                      size: Dimens.size.s20,
                      color: context.color.grey600,
                    ),
                    Gap(Dimens.spacing.sp8),
                    Text(
                      l10n.searchNotFound,
                      style: context.typo.bodyLarge.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                  ],
                );
              }

              return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final bank = filteredList[index];
                  return Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      if (index == 0)
                        Divider(
                          color: context.color.outline,
                          height: Dimens.size.s1,
                          thickness: Dimens.size.s1,
                        ),
                      Material(
                        color: context.color.transparent,
                        child: InkWell(
                          onTap: () => context.pop(bank),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimens.padding.p8,
                              vertical: Dimens.padding.p12,
                            ),
                            child: Text(
                              bank.name,
                              style: context.typo.bodyLarge.copyWith(
                                color: context.color.grey800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index == filteredList.length - 1)
                        Divider(
                          color: context.color.outline,
                          height: Dimens.size.s1,
                          thickness: Dimens.size.s1,
                        ),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: context.color.outline,
                    height: Dimens.size.s1,
                    thickness: Dimens.size.s1,
                  );
                },
                itemCount: filteredList.length,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(err.toString())),
          ),
        ),
      ],
    );
  }
}
