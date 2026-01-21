import 'package:flutter/material.dart';

class FixedWidthIndicatorShape extends OutlinedBorder {
  final double width;
  final double height;
  final double borderRadius;

  const FixedWidthIndicatorShape({
    this.width = 56.0,
    this.height = 32.0,
    this.borderRadius = 16.0,
    super.side,
  });

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // Centers the 56px indicator within the available tab space
    final double left = rect.center.dx - (width / 2);
    final double top = rect.center.dy - (height / 2);

    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        Radius.circular(borderRadius),
      ),
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  ShapeBorder scale(double t) => this;
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
  @override
  FixedWidthIndicatorShape copyWith({BorderSide? side}) => this;
}
