import 'package:cleer/ui/agreements/report_issue/state/report_issue_state.dart';
import 'package:cleer/ui/agreements/report_issue/view_model/report_issue_view_model.dart';
import 'package:cleer/ui/agreements/report_issue/widgets/steps/report_issue_form_step.dart';
import 'package:cleer/ui/agreements/report_issue/widgets/steps/report_issue_success_step.dart';
import 'package:cleer/ui/core/widgets/app_offline_banner_wrapper.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReportIssueScreen extends ConsumerWidget {
  const ReportIssueScreen({
    super.key,
    required this.agreementId,
    this.initialAgreement,
  });

  final String agreementId;
  final Agreement? initialAgreement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportIssueViewModelProvider(agreementId));

    final currentStep = state.value?.currentStep ?? ReportIssueStep.form;

    Widget getCurrentStepWidget() {
      return switch (currentStep) {
        ReportIssueStep.form => ReportIssueFormStep(
          key: ValueKey(currentStep),
          agreementId: agreementId,
          initialAgreement: initialAgreement,
        ),
        ReportIssueStep.success => ReportIssueSuccessStep(
          key: ValueKey(currentStep),
          agreementId: agreementId,
        ),
      };
    }

    return AppOfflineBannerWrapper(
      child: Scaffold(
        body: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              getCurrentStepWidget(),
              if (state.isLoading)
                const Positioned.fill(
                  child: Material(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
