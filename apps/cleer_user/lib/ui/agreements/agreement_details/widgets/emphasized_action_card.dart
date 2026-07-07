import 'dart:ui';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';

class EmphasizedActionCard extends StatelessWidget {
  const EmphasizedActionCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.color.secondary,
        borderRadius: BorderRadius.circular(Dimens.radius.r12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: .55,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 4.0,
                  sigmaY: 4.0,
                  tileMode: TileMode.decal,
                ),
                child: Container(
                  width: Dimens.size.s110,
                  height: Dimens.size.s110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.color.blue900,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(Dimens.padding.p16),
            child: child,
          ),
        ],
      ),
    );
  }
}