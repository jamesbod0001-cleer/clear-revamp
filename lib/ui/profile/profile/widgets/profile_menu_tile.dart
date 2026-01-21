import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.onTap,
    this.showBottomPadding = true,
  });

  final IconData icon;
  final String title;
  final String content;
  final VoidCallback onTap;
  final bool showBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomPadding ? Dimens.padding.p24 : Dimens.padding.p0,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(Dimens.radius.r8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              PhosphorIcon(
                icon,
                color: context.color.blue700,
              ),
              Gap(Dimens.spacing.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      title,
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.grey800,
                      ),
                    ),
                    Gap(Dimens.spacing.sp2),
                    Text(
                      content,
                      style: context.typo.bodyMedium.copyWith(
                        fontWeight: AppFontWeights.regular,
                        color: context.color.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(Dimens.spacing.sp8),
              PhosphorIcon(
                PhosphorIcons.caretRight(),
                color: context.color.blue700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
