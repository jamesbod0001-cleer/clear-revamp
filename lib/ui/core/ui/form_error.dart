import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FormError extends StatelessWidget {
  const FormError({
    super.key,
    required this.hasError,
    required this.errorMessage,
  });
  final bool hasError;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: hasError,
      child: Column(
        mainAxisSize: .min,
        children: [
          Material(
            borderRadius: BorderRadius.circular(Dimens.radius.r8),
            color: context.color.errorLight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.padding.p12,
                vertical: Dimens.padding.p8,
              ),
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.warning(.bold),
                    color: context.color.error,
                    size: Dimens.size.s16,
                  ),
                  Gap(Dimens.spacing.sp6),
                  Flexible(
                    child: Text(
                      errorMessage ?? kEmpty,
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(Dimens.spacing.sp28),
        ],
      ),
    );
  }
}
