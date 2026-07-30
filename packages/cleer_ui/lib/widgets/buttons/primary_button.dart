import 'package:cleer_ui/generated/assets.gen.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';

/// Defines the visual variant styles for the primary application button.
enum PrimaryButtonVariant { primary, error }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.minimumSize,
    this.padding,
  }) : variant = PrimaryButtonVariant.primary;

  /// Named constructor specifically tailored for dangerous or error actions.
  const PrimaryButton.error({
    super.key,
    required this.onPressed,
    required this.child,
    this.minimumSize,
    this.padding,
  }) : variant = PrimaryButtonVariant.error;

  final Widget child;
  final VoidCallback? onPressed;
  final PrimaryButtonVariant variant;
  final Size? minimumSize;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final isError = variant == PrimaryButtonVariant.error;

    final resolvedFallbackBg = isError
        ? context.color.error
        : context.color.primary;
    final resolvedForegroundColor = isError
        ? context.color.background
        : context.color.grey1000;

    final resolvedAssetPath = isError
        ? Assets.images.liquidGlassButtonError
        : Assets.images.liquidGlassButtonPrimary;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        foregroundColor: resolvedForegroundColor,
        backgroundColor: Colors.transparent,
        disabledForegroundColor: context.color.grey500,
        disabledBackgroundColor: context.color.grey200,
        padding: padding,
        minimumSize: minimumSize,
        backgroundBuilder: (context, states, internalChild) {
          final bool isDisabled = states.contains(WidgetState.disabled);
          return SizedBox.fromSize(
            size: minimumSize ?? Dimens.mobile.buttonMinimumSize,
            child: Container(
              clipBehavior: .antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.radius.r8),
              ),

              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isDisabled)
                    Container(color: context.color.grey200)
                  else
                    resolvedAssetPath.image(
                      fit: .none,
                      width: double.infinity,
                      height: double.infinity,
                      frameBuilder:
                          (context, frameChild, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded || frame != null) {
                              return frameChild;
                            }
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              color: resolvedFallbackBg,
                            );
                          },
                    ),
                  ?internalChild,
                ],
              ),
            ),
          );
        },
      ),
      child: child,
    );
  }
}
