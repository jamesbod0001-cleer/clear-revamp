import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MenuSectionHeader extends StatelessWidget {
  const MenuSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimens.padding.p12),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            title,
            style: context.typo.titleSmall.copyWith(
              color: context.color.grey600,
            ),
          ),
          Gap(Dimens.spacing.sp8),
          Divider(
            color: context.color.outline,
            thickness: Dimens.size.s1,
            height: Dimens.size.s1,
          ),
        ],
      ),
    );
  }
}
