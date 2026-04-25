import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Trigger the callback with the toggled value
        widget.onChanged(!widget.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: Dimens.size.s64,
        height: Dimens.size.s28,
        padding: EdgeInsets.all(Dimens.padding.p2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.radius.r100),
          color: context.color.success,
        ),
        child: Stack(
          children: [
            // OFF Icon ('O') - Positioned on the right
            Positioned(
              right: 5.5,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: Dimens.size.s10,
                  height: Dimens.size.s10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.color.white,
                      width: Dimens.size.s1,
                    ),
                  ),
                ),
              ),
            ),

            // ON Icon ('|') - Positioned on the left
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: Dimens.size.s1,
                  height: Dimens.size.s10,
                  color: context.color.white,
                ),
              ),
            ),

            // The sliding pill-shaped thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              // Slide right when true (ON), left when false (OFF)
              alignment: widget.value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: Dimens.size.s39,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.radius.r100),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
