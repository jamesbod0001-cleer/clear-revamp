import 'package:cleer_ui/generated/assets.gen.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';

enum StatusIconType {
  error,
  errorFlag,
  secured,
  success,
  successOutlined,
  handshake,
  bellRinging,
}

class StatusCircleIcon extends StatelessWidget {
  const StatusCircleIcon({super.key, required this.type, this.dimension});

  final StatusIconType type;
  final double? dimension;

  @override
  Widget build(BuildContext context) {
    // Resolve styling based on the type
    final double defaultDim = dimension ?? Dimens.size.s100;

    // Handshake uses s50 (50%), others use s60 (60%)
    final double iconScale = type == StatusIconType.handshake
        ? 0.5
        : type == .errorFlag
        ? 0.8
        : 0.6;
    final double iconDim = (defaultDim * iconScale);

    return Container(
      width: defaultDim,
      height: defaultDim,
      alignment: Alignment.center,
      decoration: _getDecoration(context),
      child: _getIcon(iconDim),
    );
  }

  BoxDecoration _getDecoration(BuildContext context) {
    switch (type) {
      case StatusIconType.error:
        return BoxDecoration(
          color: const Color(0xFFF11010).withValues(alpha: .07),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF933B3B).withValues(alpha: .1),
            width: Dimens.size.s2,
          ),
        );
      case StatusIconType.errorFlag:
        return BoxDecoration(
          color: context.color.errorLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFEED8D8),
            width: Dimens.size.s1,
          ),
        );
      case StatusIconType.secured:
      case StatusIconType.handshake: // Grouped: Blue Border/White Fill
        return BoxDecoration(
          color: context.color.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.color.blue800.withValues(alpha: .1),
            width: Dimens.size.s2,
          ),
        );
      case StatusIconType.success:
        return const BoxDecoration(
          color: Color(0xFF007443),
          shape: BoxShape.circle,
        );
      case StatusIconType.successOutlined: // The new one!
        return BoxDecoration(
          color: context.color.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.color.green700.withValues(alpha: .1),
            width: Dimens.size.s2,
          ),
        );
      case StatusIconType.bellRinging:
        return BoxDecoration(
          color: context.color.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.color.green700.withValues(alpha: .10),
            width: Dimens.size.s2,
          ),
        );
    }
  }

  Widget _getIcon(double size) {
    switch (type) {
      case StatusIconType.error:
        return Assets.images.x.image(height: size);
      case StatusIconType.errorFlag:
        return Assets.images.errorFlag.image(height: size);
      case StatusIconType.secured:
        return Assets.images.shield.image(height: size);
      case StatusIconType.success:
      case StatusIconType.successOutlined:
        return Assets.images.checkmark.image(height: size);
      case StatusIconType.handshake:
        return Assets.images.handshake.image(height: size);
      case StatusIconType.bellRinging:
        return Assets.images.bellRinging.image(height: size);
    }
  }
}
