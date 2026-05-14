import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.foregroundColor,
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback? onPressed;

  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        foregroundColor: foregroundColor ?? context.color.grey1000,
        backgroundColor: backgroundColor ?? context.color.primary,
        backgroundBuilder: (context, states, internalChild) {
          final bool isDisabled = states.contains(WidgetState.disabled);
          final bool isPressed = states.contains(WidgetState.pressed);

          return SizedBox.fromSize(
            size: Dimens.mobile.buttonMinimumSize,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.radius.r8),
                color: isDisabled
                    ? context.color.grey200
                    : backgroundColor ?? context.color.primary,
                boxShadow: isDisabled || isPressed
                    ? []
                    : [
                        BoxShadow(
                          offset: Offset(0, 0),
                          blurRadius: 2,
                          spreadRadius: 0,
                          color: context.color.green500.withValues(alpha: .10),
                        ),
                        BoxShadow(
                          offset: Offset(0, 1),
                          blurRadius: 8,
                          spreadRadius: 0,
                          color: context.color.green500.withValues(alpha: .12),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.radius.r8),
                child: Stack(
                  alignment: .center,
                  children: [
                    if (!isDisabled)
                      LiquidGlass.withOwnLayer(
                        settings: const LiquidGlassSettings(
                          saturation: 1,
                          blur: 2,
                        ),
                        shape: LiquidRoundedRectangle(
                          borderRadius: Dimens.radius.r8,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ?internalChild,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      child: child,
    );
  }
}
