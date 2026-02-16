import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return  Column(
      children: [
        Text(title, style: context.typo.headlineSmall),
        Gap(Dimens.spacing.sp12),
        Row(
          mainAxisAlignment: .center,
          children: [
            PhosphorIcon(
              PhosphorIcons.lockKey(.duotone),
              color: context.color.grey600,
              size: Dimens.size.s16,
            ),
            Gap(Dimens.spacing.sp4),
            Text(
              l10n.securedBy,
              style: context.typo.bodySmall.copyWith(
                color: context.color.grey600,
              ),
            ),
            Gap(Dimens.spacing.sp8),
            Assets.images.flutterwaveLogoWordmark.image(
              height: Dimens.size.s16,
              width: Dimens.size.s101,
            ),
          ],
        ),
      ],
    );
  }
}
