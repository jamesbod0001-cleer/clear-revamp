import 'package:cleer/ui/action_alerts/extensions/action_alerts_ui_extensions.dart';
import 'package:cleer/ui/action_alerts/models/action_alert.dart';
import 'package:cleer/ui/action_alerts/view_model/action_alerts_view_model.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ActionAlertsCarousel extends ConsumerWidget {
  const ActionAlertsCarousel({super.key, required this.topSpacing});
  final double topSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(actionAlertsProvider);

    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: .min,
      children: [
        Gap(topSpacing),
        if (alerts.length == 1)
          Padding(
            padding: Dimens.mobile.edgeInsetsScreenHorizontal,
            child: _ActionAlertCard(alert: alerts.first, isSingleItem: true),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: Dimens.mobile.edgeInsetsScreenHorizontal,
            child: Row(
              children: [
                for (var i = 0; i < alerts.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: i < alerts.length - 1 ? Dimens.spacing.sp12 : 0,
                    ),
                    child: IntrinsicWidth(
                      child: _ActionAlertCard(
                        alert: alerts[i],
                        isSingleItem: false,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionAlertCard extends StatelessWidget {
  final ActionAlert alert;
  final bool isSingleItem;

  const _ActionAlertCard({required this.alert, required this.isSingleItem});

  @override
  Widget build(BuildContext context) {
    final ui = alert.getUIProperties(context);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = isSingleItem ? double.infinity : screenWidth * 0.75;

    return Material(
      color: ui.backgroundColor.withValues(alpha: .50),
      clipBehavior: .antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: .circular(Dimens.radius.r8),
        side: BorderSide(color: ui.contentColor.withValues(alpha: .12)),
      ),
      child: InkWell(
        onTap: ui.onTap,
        child: Container(
          width: cardWidth,
          padding: .fromLTRB(
            Dimens.padding.p8,
            Dimens.padding.p8,
            Dimens.padding.p8,
            Dimens.padding.p10,
          ),
          child: Row(
            children: [
              ui.leading,
              Gap(Dimens.spacing.sp12),
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      ui.title,
                      style: context.typo.bodyMedium.copyWith(
                        color: ui.contentColor,
                      ),
                    ),
                    Gap(Dimens.spacing.sp4),
                    Text(
                      ui.subtitle,
                      style: context.typo.bodySmall.copyWith(
                        color: ui.contentColor.withValues(alpha: .70),
                        decoration: .underline,
                        decorationStyle: .dotted,
                        decorationColor: ui.contentColor.withValues(alpha: .70),
                      ),
                    ),
                  ],
                ),
              ),
              PhosphorIcon(
                PhosphorIcons.caretRight(),
                color: ui.contentColor,
                size: Dimens.size.s20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
