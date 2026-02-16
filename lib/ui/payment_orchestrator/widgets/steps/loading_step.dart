import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/step_header.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LoadingStep extends StatelessWidget {
  const LoadingStep({
    super.key,
    required this.title,
    required this.loadingMessage,
  });
  final String title;
  final String loadingMessage;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Column(
        children: [
          StepHeader(title: '$title...'),
          Gap(Dimens.spacing.sp80),
          SizedBox.square(
            dimension: Dimens.size.s80,
            child: CircularProgressIndicator(strokeWidth: Dimens.size.s8),
          ),
          Gap(Dimens.spacing.sp20),
          Text(
            loadingMessage,
            style: context.typo.bodyMedium.copyWith(
              fontWeight: AppFontWeights.regular,
              color: context.color.grey600,
            ),
            textAlign: .center,
          ),
        ],
      ),
    );
  }
}
