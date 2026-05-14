import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.isDismissible = true,
    this.showCancelIcon = true,
  });

  final Widget child;
  final bool isDismissible;
  final bool showCancelIcon;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool showCancelIcon = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: context.color.transparent,
      barrierColor: context.color.black.withValues(alpha: 0.3),
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      enableDrag: isDismissible,
      isDismissible: isDismissible,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (BuildContext context) {
        return CustomBottomSheet(
          isDismissible: isDismissible,
          showCancelIcon: showCancelIcon,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: context.color.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius.r32),
          topRight: Radius.circular(Dimens.radius.r32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        Dimens.padding.p18,
        Dimens.padding.p24,
        Dimens.padding.p18,
        bottomInset,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCancelIcon) ...[
            IconButton(
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              onPressed: () => context.pop(),
              icon: PhosphorIcon(PhosphorIcons.x()),
            ),
            Gap(Dimens.spacing.sp24),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }
}
