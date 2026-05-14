import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MenuActionTile extends StatelessWidget {
  final String title;
  final PhosphorIconData? icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const MenuActionTile({
    super.key,
    required this.title,
    this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(Dimens.radius.r8),
      color: context.color.grayComponent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(Dimens.padding.p8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      PhosphorIcon(
                        icon!,
                        color: iconColor ?? context.color.blue700,
                        size: Dimens.size.s20,
                      ),
                      Gap(Dimens.spacing.sp8),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: context.typo.bodyMedium.copyWith(
                          fontWeight: AppFontWeights.regular,
                          color: context.color.grey800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(Dimens.spacing.sp8),
              PhosphorIcon(
                PhosphorIcons.caretRight(),
                size: Dimens.size.s20,
                color: context.color.blue700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
