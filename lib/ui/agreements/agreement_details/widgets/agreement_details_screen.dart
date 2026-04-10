import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/milestone/milestone.dart';
import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/domain/providers/milestone/milestone_provider.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/ui/agreements/agreement_details/view_model/agreement_details_view_model.dart';
import 'package:cleer/ui/agreements/agreement_details/widgets/agreement_timeline.dart';
import 'package:cleer/ui/agreements/extensions/agreement_ui_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementDetailsScreen extends ConsumerWidget {
  const AgreementDetailsScreen({
    super.key,
    required this.agreementId,
    this.initialAgreement,
  });

  final String agreementId;
  final Agreement? initialAgreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider).value;

    final state = ref.watch(agreementDetailsViewModelProvider(agreementId));

    final agreement = state.value ?? initialAgreement;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: .start,
          children: [Gap(Dimens.spacing.sp15), AppBackButton()],
        ),
        toolbarHeight: 59,
      ),
      body: Builder(
        builder: (context) {
          if (agreement == null && state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (agreement == null && state.hasError) {
            /// TODO: Show proper error here
            return SizedBox.shrink();
          }

          Milestone? currentlyRunning;
          AsyncValue<List<Milestone>>? milestonesState;
          if (agreement!.disbursementType == .milestones) {
            milestonesState = ref.watch(
              agreementMilestonesProvider(agreement.id!),
            );
            currentlyRunning = milestonesState!.value?.currentlyRunning;
          }

          DateTime? dueDate = agreement.dueDate(
            currentlyRunning: currentlyRunning,
          );

          final agreementStatusHistoryState = ref.watch(
            agreementStatusHistoryProvider(agreement.id!),
          );

          return CustomScrollView(
            slivers: [
              PinnedHeaderSliver(
                child: Container(
                  color: context.color.background,
                  child: Padding(
                    padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                      bottom: Dimens.padding.p20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Gap(Dimens.spacing.sp2),
                              Text(
                                '${l10n.nairaSign}${NumberFormat('#,###.##').format(agreement.amount)}',
                                style: context.typo.headlineMedium.copyWith(
                                  color: context.color.grey800,
                                ),
                              ),
                              Gap(Dimens.spacing.sp6),
                              Text(
                                agreement.getDisplayTitle(
                                  context,
                                  currentUser: user,
                                ),
                                style: context.typo.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Gap(Dimens.spacing.sp12),
                              Row(
                                mainAxisSize: .min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: agreement.getStatusPillColor(
                                        context,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimens.radius.r20,
                                      ),
                                    ),
                                    padding: .symmetric(
                                      horizontal: Dimens.padding.p6,
                                      vertical: Dimens.padding.p3,
                                    ),
                                    child: Text(
                                      agreement.getStatusText(context),
                                      style: context.typo.bodySmall.copyWith(
                                        color: agreement.getStatusTextColor(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Gap(Dimens.spacing.sp8),
                                  Text(
                                    l10n.dueDate(
                                      dueDate != null
                                          ? DateFormat('d MMM').format(dueDate)
                                          : '',
                                    ),
                                    style: context.typo.bodySmall.copyWith(
                                      color: context.color.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Gap(Dimens.spacing.sp24),
                        Container(
                          width: Dimens.size.s100,
                          height: Dimens.size.s100,
                          alignment: .center,
                          decoration: BoxDecoration(
                            color: context.color.white,
                            shape: BoxShape.circle,
                            border: .all(
                              color: context.color.blue800.withValues(
                                alpha: .1,
                              ),
                              width: Dimens.size.s2,
                            ),
                          ),
                          child: Assets.images.handshake.image(
                            height: Dimens.size.s50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: Dimens.mobile.edgeInsetsScreenHorizontal,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Gap(Dimens.spacing.sp20),
                    if ([
                      AgreementStatus.awaitingFunding,
                      AgreementStatus.awaitingRecipient,
                    ].contains(agreement.status)) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              agreement.shareLink,
                              style: context.typo.labelMedium.copyWith(
                                color: context.color.blue700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Gap(Dimens.spacing.sp16),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Color(
                                0xFF99D2AE,
                              ).withValues(alpha: .20),
                              padding: .symmetric(
                                horizontal: Dimens.padding.p10,
                                vertical: Dimens.padding.p6,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minimumSize: .zero,
                            ),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: agreement.shareLink),
                              );
                            },
                            child: Row(
                              mainAxisSize: .min,
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.copySimple(.fill),
                                  color: context.color.green900,
                                  size: Dimens.size.s16,
                                ),
                                Gap(Dimens.spacing.sp4),
                                Text(
                                  l10n.copy,
                                  style: context.typo.bodyMedium.copyWith(
                                    color: context.color.green900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Gap(Dimens.spacing.sp16),
                    ],
                    agreementStatusHistoryState.when(
                      data: (history) => AgreementTimeline(
                        agreement: agreement,
                        statusHistory: history,
                        milestones:
                            agreement.disbursementType ==
                                DisbursementType.milestones
                            ? milestonesState!.value
                            : null,
                      ),
                      loading: () => Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.padding.p40,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                      /// TODO: Show proper error here
                      error: (error, stackTrace) => SizedBox.shrink(),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
