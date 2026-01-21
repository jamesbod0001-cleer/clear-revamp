import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    this.currentStep = 1,
    this.totalSteps = 3,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimens.size.s52,
      child: Row(
        spacing: Dimens.spacing.sp2,
        children: List.generate(totalSteps, (index) {
          final bool isCompleted = index < currentStep - 1;
          final bool isActive = index == currentStep - 1;

          // Target value: 1.0 if completed or active, 0.0 otherwise
          final double targetWidth = (isCompleted || isActive) ? 1.0 : 0.0;

          return Expanded(
            child: Container(
              height: Dimens.size.s6,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.color.outline,
                borderRadius: BorderRadius.circular(Dimens.radius.r48),
              ),
              child: TweenAnimationBuilder<double>(
                // For the active step, we animate from 0 to 1.
                // For completed steps, we just stay at 1.
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(
                  begin: isCompleted ? 1.0 : 0.0,
                  end: targetWidth,
                ),
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.color.primaryBlue,
                        borderRadius: BorderRadius.circular(Dimens.radius.r48),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
