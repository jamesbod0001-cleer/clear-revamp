import 'package:cleer/domain/providers/agreement/agreement_provider.dart';
import 'package:cleer/ui/agreements/extensions/agreement_ui_extensions.dart';
import 'package:cleer/ui/agreements/report_issue/state/report_issue_state.dart';
import 'package:cleer/ui/agreements/report_issue/view_model/report_issue_view_model.dart';
import 'package:cleer/ui/agreements/report_issue/widgets/reason_picker_bottom_sheet.dart';
import 'package:cleer/ui/core/extensions/file_extensions.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_ui/cleer_ui.dart';
import 'package:cleer_ui/widgets/buttons/app_back_button.dart';
import 'package:cleer_ui/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ReportIssueFormStep extends HookConsumerWidget {
  const ReportIssueFormStep({
    super.key,
    required this.agreementId,
    this.initialAgreement,
  });

  final String agreementId;
  final Agreement? initialAgreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = useState(true);

    final state = ref.watch(reportIssueViewModelProvider(agreementId));
    final viewModel = ref.read(
      reportIssueViewModelProvider(agreementId).notifier,
    );

    final agreementDetailsState = ref.watch(
      agreementDetailsProvider(agreementId),
    );
    final activeAgreement = agreementDetailsState.value ?? initialAgreement;

    final formData = state.value?.formData ?? ReportIssueFormData.empty();

    final selectedReason = useState<DisputeReason?>(formData.reason);
    final reasonController = useTextEditingController(
      text: formData.reason?.getLabel(context) ?? '',
    );
    final descriptionController = useTextEditingController(
      text: formData.description,
    );

    useEffect(() {
      void listener() {
        viewModel.onDescriptionChanged(descriptionController.text);
      }

      descriptionController.addListener(listener);
      return () => descriptionController.removeListener(listener);
    }, [descriptionController]);

    final pickEvidenceFilesCommand = viewModel.pickEvidenceFilesCommand;
    useEffect(() {
      void listener() {
        if (pickEvidenceFilesCommand.errors.value != null) {
          debugPrint(
            "Command Error: ${pickEvidenceFilesCommand.errors.value?.error}",
          );
        }
      }

      pickEvidenceFilesCommand.errors.addListener(listener);
      return () => pickEvidenceFilesCommand.errors.removeListener(listener);
    }, [pickEvidenceFilesCommand]);

    final availableReasons =
        activeAgreement?.availableIssueReasons ?? DisputeReason.values;

    Future<void> openReasonPicker() async {
      final chosen = await ReasonPickerBottomSheet.show(
        context,
        reasons: availableReasons,
        selectedReason: selectedReason.value,
      );
      if (chosen != null && context.mounted) {
        selectedReason.value = chosen;
        reasonController.text = chosen.getLabel(context);
        viewModel.onReasonChanged(chosen);
      }
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Dimens.padding.p18,
        titleTextStyle: context.typo.headlineSmall,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: .start,
          children: [
            Gap(Dimens.spacing.sp12),
            AppBackButton(),
            Gap(Dimens.spacing.sp24),
            Text(l10n.reportAnIssue),
          ],
        ),
        toolbarHeight: 102,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
              top: Dimens.padding.p4,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  l10n.fundsWillRemainSecurelyHeldWhileWeInvestigateTheDispute,
                  style: context.typo.bodyMedium.copyWith(
                    fontWeight: AppFontWeights.regular,
                    color: context.color.grey600,
                  ),
                ),
                Gap(Dimens.spacing.sp16),
                CustomTextFormField(
                  controller: reasonController,
                  labelText: l10n.reason,
                  readOnly: true,
                  onTap: openReasonPicker,
                  suffixIcon: IconButton(
                    onPressed: openReasonPicker,
                    icon: PhosphorIcon(
                      PhosphorIcons.caretDown(),
                      color: context.color.blue700,
                    ),
                  ),
                ),
                Gap(Dimens.spacing.sp24),
                CustomTextFormField(
                  controller: descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  label: RichText(
                    text: TextSpan(
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.grey600,
                      ),
                      children: [
                        TextSpan(text: l10n.describeExactlyWhatWentWrong),
                        TextSpan(text: ' '),
                        TextSpan(
                          text: l10n
                              .includeDatesTimesAndWhatSpecificAgreementTermsWereViolated,
                          style: TextStyle(
                            color: context.color.grey500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  maxLines: 6,
                  minLines: 6,
                  maxLength: 500,
                ),
                Gap(Dimens.spacing.sp24),
                RichText(
                  text: TextSpan(
                    style: context.typo.bodyMedium.copyWith(
                      fontWeight: AppFontWeights.regular,
                      color: context.color.grey600,
                    ),
                    children: [
                      TextSpan(
                        text: l10n.evidenceUpload,
                        style: TextStyle(fontWeight: AppFontWeights.semiBold),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: l10n
                            .photosScreenShotsDocumentsOrVideosThatCanHelpExplainTheIssue,
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: viewModel.pickEvidenceFilesCommand.isRunning,
                  builder: (context, isRunning, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isRunning) ...[
                          Gap(Dimens.spacing.sp8),
                          LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(
                              Dimens.radius.r100,
                            ),
                            minHeight: Dimens.size.s2,
                          ),
                        ],
                        if (formData.evidenceFiles.isNotEmpty) ...[
                          Gap(Dimens.spacing.sp12),
                          Column(
                            children: formData.evidenceFiles
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final file = entry.value;
                                  final name = file.name;

                                  final icon = name.fileIcon;

                                  return Container(
                                    margin: EdgeInsets.only(
                                      bottom: Dimens.padding.p8,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.padding.p12,
                                      vertical: Dimens.padding.p8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.color.grey100,
                                      borderRadius: BorderRadius.circular(
                                        Dimens.radius.r8,
                                      ),
                                      border: Border.all(
                                        color: context.color.outline,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        PhosphorIcon(
                                          icon,
                                          color: context.color.blue700,
                                          size: Dimens.size.s20,
                                        ),
                                        Gap(Dimens.spacing.sp8),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: context.typo.bodySmall
                                                .copyWith(
                                                  color: context.color.grey800,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: PhosphorIcon(
                                            PhosphorIcons.x(),
                                            size: Dimens.size.s16,
                                            color: context.color.grey600,
                                          ),
                                          onPressed: isRunning
                                              ? null
                                              : () => viewModel
                                                    .removeEvidenceFile(index),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                        Gap(Dimens.spacing.sp8),
                        if (!formData.hasReachedMaxEvidence) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: isRunning
                                  ? null
                                  : () {
                                      if (formData.remainingFileAllowance > 0) {
                                        viewModel.pickEvidenceFilesCommand.run(
                                          formData.remainingFileAllowance,
                                        );
                                      }
                                    },
                              borderRadius: BorderRadius.circular(
                                Dimens.radius.r4,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Dimens.padding.p4,
                                ),
                                child: Text(
                                  l10n.selectFileToUpload,
                                  style: context.typo.bodyLink.copyWith(
                                    color: context.color.blue700,
                                    decorationColor: context.color.blue700,
                                    decorationThickness: (17 / 100) * 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                Gap(Dimens.spacing.sp32),
                ExpansionTile(
                  backgroundColor: context.color.infoLight,
                  collapsedBackgroundColor: context.color.infoLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: .circular(Dimens.radius.r8),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: .circular(Dimens.radius.r8),
                  ),
                  childrenPadding: .fromLTRB(
                    Dimens.padding.p36,
                    Dimens.padding.p0,
                    Dimens.padding.p0,
                    Dimens.padding.p8,
                  ),
                  expandedAlignment: .centerLeft,
                  tilePadding: .symmetric(
                    horizontal: Dimens.padding.p12,
                    vertical: Dimens.padding.p4,
                  ),
                  minTileHeight: Dimens.size.s0,
                  initiallyExpanded: true,
                  onExpansionChanged: (value) => isExpanded.value = value,
                  title: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: Dimens.padding.p1),
                        child: PhosphorIcon(
                          PhosphorIcons.info(),
                          size: Dimens.size.s20,
                          color: context.color.info,
                        ),
                      ),
                      Gap(Dimens.spacing.sp8),
                      Text(
                        l10n.whatHappensNext,
                        style: context.typo.bodySmall.copyWith(
                          color: context.color.info,
                        ),
                      ),
                    ],
                  ),
                  trailing: PhosphorIcon(
                    isExpanded.value
                        ? PhosphorIcons.caretUp()
                        : PhosphorIcons.caretDown(),
                    color: context.color.blue700,
                  ),
                  children: [
                    Text(
                      l10n.whatHappensNextContent,
                      style: context.typo.bodySmall.copyWith(
                        color: context.color.info,
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  Gap(Dimens.spacing.sp30),
                  PrimaryButton(
                    onPressed: formData.isValid && !state.isLoading
                        ? () {
                            viewModel.submitReportIssue();
                          }
                        : null,
                    child: Text(l10n.submit),
                  ),
                  Gap(Dimens.spacing.sp20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
